import { Neovim } from "neovim";

export class OptionRepository {
  constructor(protected readonly vim: Neovim) {}

  public async get(...names: string[]): Promise<any[]> {
    const calls = names.map(name => {
      return ["nvim_get_option", [name]];
    });
    return (await this.vim.callAtomic(calls))[0];
  }

  public async set(...keyValues: [string, any][]): Promise<void> {
    const calls = keyValues.map(keyValue => {
      return ["nvim_set_option", keyValue];
    });
    await this.vim.callAtomic(calls);
  }
}
