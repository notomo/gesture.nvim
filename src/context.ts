import { Neovim } from "neovim";
import { CursorRepository } from "./repository/cursor";

export interface Context {
  windows: {
    id: number;
    bufferId: number;
  }[];
  start: PointContext | null;
}

export interface PointContext {
  row: number;
  column: number;
  text: string;
}

export class PointContextFactory {
  constructor(
    protected readonly vim: Neovim,
    protected readonly cursorRepository: CursorRepository
  ) {}

  public async create(): Promise<PointContext> {
    const window = await this.vim.window;
    const row = (await window.cursor)[0];
    const column = await this.cursorRepository.getVirtualColumn();
    const text = await this.cursorRepository.getWord();
    return {
      row: row,
      column: column,
      text: text,
    };
  }
}
