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

  public async setup(enabledBufferFill: boolean) {
    await this.optionStore.set();

    this.started = true;

    this.startPointTabpage = await this.vim.tabpage;
    this.startPointWindow = await this.vim.window;

    if (!enabledBufferFill) {
      return;
    }
    const cursor = await this.startPointWindow.cursor;

    const bufferMaxEmptyLineCounts: Map<
      number,
      { emptyLineCount: number; buffer: Buffer }
    > = new Map();
    for (const window of await this.startPointTabpage.windows) {
      const buffer = await window.buffer;

      const emptyLineCount = await this.getEmptyLineCount(window, buffer);
      const info = bufferMaxEmptyLineCounts.get(buffer.id);
      if (
        (info === undefined || emptyLineCount > info.emptyLineCount) &&
        emptyLineCount !== 0
      ) {
        bufferMaxEmptyLineCounts.set(buffer.id, {
          emptyLineCount: emptyLineCount,
          buffer: buffer,
        });
      }
    }

    for (const info of bufferMaxEmptyLineCounts.values()) {
      const buffer = info.buffer;
      const bufferOptionStore = this.bufferOptionStoreFactory.create(buffer);
      await bufferOptionStore.set();

      await buffer.append(Array(info.emptyLineCount).fill(""));
      this.bufferOptionStores.push(bufferOptionStore);
    }

    await (this.startPointWindow.cursor = cursor);
    await this.vim.setWindow(this.startPointWindow);
  }

  protected async getEmptyLineCount(
    window: Window,
    buffer: Buffer
  ): Promise<number> {
    const [modifiable, readonlyOption] = await Promise.all([
      (await buffer.getOption("modifiable")) as Promise<boolean>,
      (await buffer.getOption("readonly")) as Promise<boolean>,
    ]);
    if (!modifiable || readonlyOption) {
      return 0;
    }

    const windowHeight = await window.height;
    const cursorLineNumber = (await window.cursor)[0];

    await this.vim.setWindow(window);
    const topLineNumberInWindow =
      cursorLineNumber - ((await this.vim.call("winline")) as number) + 1;

    const bufferLineCount = await buffer.length;
    const hasEmptyLine =
      bufferLineCount < topLineNumberInWindow + windowHeight - 1;

    if (!hasEmptyLine) {
      return 0;
    }

    const lineCountInWindow = bufferLineCount - topLineNumberInWindow + 1;
    return windowHeight - lineCountInWindow;
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
      (await this.startPointTabpage.valid) &&
      (await this.startPointTabpage.number) === (await currentTabpage.number)
    );
  }

  public isStarted(): boolean {
    return this.started;
  }
}
