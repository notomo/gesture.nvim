import { Neovim, Buffer, Window } from "neovim";
import {
  OptionStore,
  BufferOptionStore,
  BufferOptionStoreFactory,
} from "./option";

export class GestureBuffer {
  protected started = false;

  protected changedInfo: {
    buffer: Buffer;
    start: number;
    end: number;
  } | null = null;

  protected startPointWindow: Window | null = null;

  protected bufferOptionStore: BufferOptionStore | null = null;

  constructor(
    protected readonly vim: Neovim,
    protected readonly optionStore: OptionStore,
    protected readonly bufferOptionStoreFactory: BufferOptionStoreFactory
  ) {}

  public async setup() {
    await this.optionStore.set();

    this.started = true;

    this.startPointWindow = await this.vim.window;
    const buffer = await this.startPointWindow.buffer;

    const windowHeight = await this.startPointWindow.height;
    const cursorLineNumber = (await this.startPointWindow.cursor)[0];
    const topLineNumberInWindow =
      cursorLineNumber - ((await this.vim.call("winline")) as number) + 1;
    const bufferLineCount = await buffer.length;
    const hasEmptyLine =
      bufferLineCount < topLineNumberInWindow + windowHeight - 1;

    if (hasEmptyLine) {
      const lineCountInWindow = bufferLineCount - topLineNumberInWindow + 1;
      const emptyLineCount = windowHeight - lineCountInWindow;

      this.changedInfo = {
        buffer: buffer,
        start: bufferLineCount,
        end: bufferLineCount + emptyLineCount,
      };

      this.bufferOptionStore = this.bufferOptionStoreFactory.create(buffer);
      await this.bufferOptionStore.set();

      await buffer.append(Array(emptyLineCount).fill(""));
    }
  }

  public async restore() {
    if (!this.started) {
      return;
    }

    if (this.changedInfo !== null) {
      const buffer = this.changedInfo.buffer;
      await buffer.remove(this.changedInfo.start, this.changedInfo.end, false);
      this.changedInfo = null;

      if (this.bufferOptionStore !== null) {
        await this.bufferOptionStore.restore();
      }
    }

    await this.optionStore.restore();

    this.started = false;
  }

  public async validate(): Promise<boolean> {
    const currentWindow = await this.vim.window;
    return (
      this.startPointWindow !== null &&
      this.startPointWindow.id === currentWindow.id
    );
  }

  public async getCursor(): Promise<{ x: number; y: number }> {
    if (!this.validate()) {
      return { x: -1, y: -1 };
    }
    const x = (await this.vim.call("virtcol", ".")) as number;
    const y = (await (this.startPointWindow as Window).cursor)[0];
    return { x: x, y: y };
  }

  public get isStarted(): boolean {
    return this.started;
  }
}
