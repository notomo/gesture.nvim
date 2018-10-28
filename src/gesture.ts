import { Neovim, Buffer, Window } from "neovim";
import { Logger, getLogger } from "./logger";
import { DirectionRecognizer } from "./recognizer";
import { GestureMapper } from "./mapper";

export class Gesture {
  protected readonly savedOptions = {
    virtualedit: "",
    scrolloff: 0,
    sidescrolloff: 0,
  };

  protected readonly savedBufferOptions = {
    modified: false,
    modifiable: false,
    readonly: false,
  };

  protected started = false;
  protected changedInfo: {
    buffer: Buffer;
    start: number;
    end: number;
  } | null = null;

  protected currentWindow: Window | null = null;

  protected readonly logger: Logger;

  constructor(
    protected readonly vim: Neovim,
    protected readonly recognizer: DirectionRecognizer,
    protected readonly mapper: GestureMapper
  ) {
    this.logger = getLogger("gesture");
  }

  public async execute(): Promise<void> {
    await this.initialize();

    const win = await this.vim.window;
    if (this.currentWindow !== null && this.currentWindow.id !== win.id) {
      await this.finish();
      return;
    }

    const x = (await this.vim.call("virtcol", ".")) as number;
    const y = (await win.cursor)[0];
    this.recognizer.add(x, y);

    // show lines
  }

  public async finish(): Promise<void> {
    if (!this.started) {
      return;
    }

    if (this.changedInfo !== null) {
      const buffer = this.changedInfo.buffer;
      await buffer.remove(this.changedInfo.start, this.changedInfo.end, false);
      this.changedInfo = null;

      await Promise.all([
        buffer.setOption("modified", this.savedBufferOptions["modified"]),
        buffer.setOption("modifiable", this.savedBufferOptions["modifiable"]),
        buffer.setOption("readonly", this.savedBufferOptions["readonly"]),
      ]);
    }

    await Promise.all([
      this.vim.setOption("virtualedit", this.savedOptions["virtualedit"]),
      this.vim.setOption("scrolloff", this.savedOptions["scrolloff"]),
      this.vim.setOption("sidescrolloff", this.savedOptions["sidescrolloff"]),
    ]);

    this.started = false;

    // remove lines

    const directions = this.recognizer.getDirections();
    await this.mapper.execute(directions);
  }

  public async initialize() {
    if (this.started) {
      return;
    }

    this.recognizer.clear();

    this.savedOptions["virtualedit"] = (await this.vim.getOption(
      "virtualedit"
    )) as string;
    this.savedOptions["scrolloff"] = (await this.vim.getOption(
      "scrolloff"
    )) as number;
    this.savedOptions["sidescrolloff"] = (await this.vim.getOption(
      "sidescrolloff"
    )) as number;

    this.currentWindow = await this.vim.window;
    const buffer = await this.currentWindow.buffer;

    this.started = true;

    await Promise.all([
      this.vim.setOption("virtualedit", "all"),
      this.vim.setOption("scrolloff", 0),
      this.vim.setOption("sidescrolloff", 0),
    ]);

    const windowHeight = await this.currentWindow.height;
    const cursorLineNumber = (await this.currentWindow.cursor)[0];
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

      this.savedBufferOptions["modified"] = (await buffer.getOption(
        "modified"
      )) as boolean;
      this.savedBufferOptions["modifiable"] = (await buffer.getOption(
        "modifiable"
      )) as boolean;
      this.savedBufferOptions["readonly"] = (await buffer.getOption(
        "readonly"
      )) as boolean;

      await Promise.all([
        buffer.setOption("modifiable", true),
        buffer.setOption("readonly", false),
      ]);

      await buffer.append(Array(emptyLineCount).fill(""));
    }
  }
}
