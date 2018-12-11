import { Neovim, Window, Tabpage, Buffer } from "neovim";
import {
  OptionStore,
  BufferOptionStore,
  BufferOptionStoreFactory,
} from "./option";
import { Logger, getLogger } from "./logger";

export class GestureBuffer {
  protected started = false;

  protected startPointTabpage: Tabpage | null = null;
  protected startPointWindow: Window | null = null;

  protected readonly bufferOptionStores: BufferOptionStore[] = [];

  protected readonly logger: Logger;

  constructor(
    protected readonly vim: Neovim,
    protected readonly optionStore: OptionStore,
    protected readonly bufferOptionStoreFactory: BufferOptionStoreFactory
  ) {
    this.logger = getLogger("buffer");
  }

  public async setup() {
    await this.optionStore.set();

    this.started = true;

    this.startPointTabpage = await this.vim.tabpage;
    this.startPointWindow = await this.vim.window;
    const bufferIds: number[] = [];
    for (const window of await this.startPointTabpage.windows) {
      const buffer = await window.buffer;
      if (bufferIds.indexOf(buffer.id) >= 0) {
        continue;
      }
      bufferIds.push(buffer.id);

      const bufferOptionStore = await this.fillBuffer(window, buffer);
      if (bufferOptionStore !== null) {
        this.bufferOptionStores.push(bufferOptionStore);
      }
    }
  }

  protected async fillBuffer(
    window: Window,
    buffer: Buffer
  ): Promise<BufferOptionStore | null> {
    const currentWindow = await this.vim.window;

    const windowHeight = await window.height;
    const cursorLineNumber = (await window.cursor)[0];
    const topLineNumberInWindow =
      cursorLineNumber - ((await this.vim.call("winline")) as number) + 1;
    const bufferLineCount = await buffer.length;
    const hasEmptyLine =
      bufferLineCount < topLineNumberInWindow + windowHeight - 1;

    // FIXME: add module for edit buffer only when the buffer is modifiable
    const [modifiable, readonlyOption] = await Promise.all([
      (await buffer.getOption("modifiable")) as Promise<boolean>,
      (await buffer.getOption("readonly")) as Promise<boolean>,
    ]);
    if (hasEmptyLine && modifiable && !readonlyOption) {
      const bufferOptionStore = this.bufferOptionStoreFactory.create(buffer);
      await bufferOptionStore.set();

      const lineCountInWindow = bufferLineCount - topLineNumberInWindow + 1;
      const emptyLineCount = windowHeight - lineCountInWindow;
      await buffer.append(Array(emptyLineCount).fill(""));

      await this.vim.setWindow(currentWindow);
      return bufferOptionStore;
    }

    await this.vim.setWindow(currentWindow);

    return null;
  }

  public async restore() {
    if (!this.started) {
      return;
    }

    for (const bufferOptionStore of this.bufferOptionStores) {
      await bufferOptionStore.restore();
    }
    this.bufferOptionStores.length = 0;

    await this.optionStore.restore();

    this.startPointTabpage = null;
    this.startPointWindow = null;
    this.started = false;
  }

  public async validate(): Promise<boolean> {
    const currentTabpage = await this.vim.tabpage;
    return (
      this.startPointTabpage !== null &&
      (await this.startPointTabpage.number) === (await currentTabpage.number)
    );
  }

  public async getCursor(): Promise<{ x: number; y: number }> {
    const window = await this.vim.window;

    const offsets = (await this.vim.call("win_screenpos", window.id)) as [
      number,
      number
    ];

    // FIXME: remove tabline and ruler offsets

    const xInWindow = (await this.vim.call("virtcol", ".")) as number;
    const yInWindow = (await window.cursor)[0];
    return { x: xInWindow + offsets[1] - 1, y: yInWindow + offsets[0] - 1 };
  }

  public isStarted(): boolean {
    return this.started;
  }
}
