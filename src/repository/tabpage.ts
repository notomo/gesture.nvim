import { Neovim } from "neovim";
import { Logger, getLogger } from "../logger";

export class TabpageRepository {
  protected readonly logger: Logger;

  constructor(protected readonly vim: Neovim) {
    this.logger = getLogger("repository.option");
  }

  public async getGlobalPosition(): Promise<{ x: number; y: number }> {
    const window = await this.vim.window;
    const [offsets, xInWindow, yInWindow] = (await this.vim.callAtomic([
      ["nvim_call_function", ["win_screenpos", [window.id]]],
      ["nvim_call_function", ["wincol", []]],
      ["nvim_call_function", ["winline", []]],
    ]))[0];

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
