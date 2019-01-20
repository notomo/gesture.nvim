import { Neovim } from "neovim";

export class CursorRepository {
  constructor(protected readonly vim: Neovim) {}

  public async getVirtualColumn(): Promise<number> {
    return (await this.vim.call("virtcol", ".")) as number;
  }

  public async getWord(): Promise<string> {
    return (await this.vim.call("expand", "<cword>")) as string;
  }
}
