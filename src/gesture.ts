import { Neovim } from "neovim";

export class Gesture {
  protected userVirtualEdit: string | null = null;

  constructor(protected readonly vim: Neovim) {}

  public async execute(): Promise<void> {
    if (this.userVirtualEdit === null) {
      this.userVirtualEdit = (await this.vim.getOption(
        "virtualedit"
      )) as string;
    }

    await this.vim.setOption("virtualedit", "all");

    // recognize a gesture command

    // show lines
  }

  public async finish(): Promise<void> {
    if (this.userVirtualEdit !== null) {
      await this.vim.setOption("virtualedit", this.userVirtualEdit);
      this.userVirtualEdit = null;
    }

    // execute a gesture command

    // remove lines

    // initialize
  }
}
