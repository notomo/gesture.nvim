import { Neovim } from "neovim";
import { Direction } from "../direction";

export class ConfigRepository {
  constructor(protected readonly vim: Neovim) {}

  public async getMinLengthByDirection(direction: Direction): Promise<number> {
    switch (direction) {
      case Direction.UP:
      case Direction.DOWN:
        return (await this.vim.call(
          "gesture#get_custom",
          "y_length_threshold"
        )) as number;
      case Direction.LEFT:
      case Direction.RIGHT:
        return (await this.vim.call(
          "gesture#get_custom",
          "x_length_threshold"
        )) as number;
    }
  }
}