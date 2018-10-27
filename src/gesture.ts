import { Neovim } from "neovim";

export class Gesture {
  protected userVirtualEdit = "";
  protected userScrollOff = 0;
  protected userSideScrollOff = 0;
  protected started = false;

  constructor(protected readonly vim: Neovim) {}

  public async execute(): Promise<void> {
    if (!this.started) {
      this.userVirtualEdit = (await this.vim.getOption(
        "virtualedit"
      )) as string;
      this.userScrollOff = (await this.vim.getOption("scrolloff")) as number;
      this.userSideScrollOff = (await this.vim.getOption(
        "sidescrolloff"
      )) as number;
      this.started = true;
    }

    await Promise.all([
      this.vim.setOption("virtualedit", "all"),
      this.vim.setOption("scrolloff", 0),
      this.vim.setOption("sidescrolloff", 0),
    ]);

    // recognize a gesture command

    // show lines
  }

  public async finish(): Promise<void> {
    if (this.started) {
      await Promise.all([
        this.vim.setOption("virtualedit", this.userVirtualEdit),
        this.vim.setOption("scrolloff", this.userScrollOff),
        this.vim.setOption("sidescrolloff", this.userSideScrollOff),
      ]);
    }

    // remove lines

    // initialize

    // execute a gesture command
  }
}
