import { Neovim, Buffer } from "neovim";
import { Logger, getLogger } from "./logger";

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

  protected readonly logger: Logger;

  constructor(protected readonly vim: Neovim) {
    this.logger = getLogger("gesture");
  }

  public async execute(): Promise<void> {
    await this.initialize();

    // recognize a gesture command

    // show lines
  }

  public async finish(): Promise<void> {
    if (!this.started) {
      return;
    }

    const buffer = await this.vim.window.buffer;

    if (this.changedInfo !== null) {
      const buffer = this.changedInfo.buffer;
      await buffer.remove(this.changedInfo.start, this.changedInfo.end, false);
      this.changedInfo = null;
    }

    await Promise.all([
      this.vim.setOption("virtualedit", this.savedOptions["virtualedit"]),
      this.vim.setOption("scrolloff", this.savedOptions["scrolloff"]),
      this.vim.setOption("sidescrolloff", this.savedOptions["sidescrolloff"]),
      buffer.setOption("modified", this.savedBufferOptions["modified"]),
      buffer.setOption("modifiable", this.savedBufferOptions["modifiable"]),
      buffer.setOption("readonly", this.savedBufferOptions["readonly"]),
    ]);

    this.started = false;

    // remove lines

    // execute a gesture command
  }

  public async initialize() {
    if (this.started) {
      return;
    }

    this.savedOptions["virtualedit"] = (await this.vim.getOption(
      "virtualedit"
    )) as string;
    this.savedOptions["scrolloff"] = (await this.vim.getOption(
      "scrolloff"
    )) as number;
    this.savedOptions["sidescrolloff"] = (await this.vim.getOption(
      "sidescrolloff"
    )) as number;

    const currentWindow = await this.vim.window;
    const buffer = await currentWindow.buffer;

    this.savedBufferOptions["modified"] = (await buffer.getOption(
      "modified"
    )) as boolean;
    this.savedBufferOptions["modifiable"] = (await buffer.getOption(
      "modifiable"
    )) as boolean;
    this.savedBufferOptions["readonly"] = (await buffer.getOption(
      "readonly"
    )) as boolean;

    this.started = true;

    await Promise.all([
      this.vim.setOption("virtualedit", "all"),
      this.vim.setOption("scrolloff", 0),
      this.vim.setOption("sidescrolloff", 0),
      buffer.setOption("modifiable", true),
      buffer.setOption("readonly", false),
    ]);

    const windowHeight = await currentWindow.height;
    const cursorLineNumber = (await currentWindow.cursor)[0];
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

      await buffer.append(Array(emptyLineCount).fill(""));
    }
  }
}
