import { Neovim } from "neovim";
import { Direction } from "./direction";

export class GestureMapper {
  constructor(protected readonly vim: Neovim) {}

  public async execute(directions: Direction[]) {
    const serialized = directions.join(",");
    const action = await this.vim.call("gesture#get_action", serialized);

    if (action === null) {
      return;
    }

    await this.vim.command(`execute "normal ${action}"`);
  }
}
