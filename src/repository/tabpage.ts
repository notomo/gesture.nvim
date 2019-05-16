import { Neovim } from "neovim";

export class TabpageRepository {
  constructor(protected readonly vim: Neovim) {}

  public async getGlobalPosition(): Promise<{ x: number; y: number }> {
    const window = await this.vim.window;
    const offsets = (await this.vim.call("win_screenpos", window.id)) as [
      number,
      number
    ];

    const [xInWindow, yInWindow] = await Promise.all([
      this.vim.call("wincol") as Promise<number>,
      this.vim.call("winline") as Promise<number>,
    ]);

    return { x: xInWindow + offsets[1], y: yInWindow + offsets[0] };
  }

  public async getSize(): Promise<{ width: number; height: number }> {
    const results = (await this.vim.callAtomic([
      ["nvim_get_option", ["columns"]],
      ["nvim_get_option", ["lines"]],
    ]))[0];
    return {
      width: results[0],
      height: results[1],
    };
  }
}
