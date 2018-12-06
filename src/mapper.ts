import { Neovim } from "neovim";
import { Action } from "./command";
import { GestureLine } from "./line";
import { Logger, getLogger } from "./logger";

export class GestureMapper {
  protected actions: Action[] = [];

  protected readonly logger: Logger;

  constructor(protected readonly vim: Neovim) {
    this.logger = getLogger("mapper");
  }

  public async initialize() {
    this.actions = (await this.vim.call("gesture#get")) as Action[];
  }

  public async getAction(
    gestureLines: ReadonlyArray<GestureLine>
  ): Promise<Action | null> {
    const gesturedDirections = gestureLines
      .map(gestureLine => gestureLine.direction)
      .join("");

    const candidates = this.actions.filter(action => {
      return action.directions.join("") === gesturedDirections;
    });

    if (candidates.length === 0) {
      return null;
    }

    return candidates[0];
  }

  public async getNoWaitAction(
    gestureLines: ReadonlyArray<GestureLine>
  ): Promise<Action | null> {
    const gesturedDirections = gestureLines
      .map(gestureLine => gestureLine.direction)
      .join("");

    const candidates = this.actions.filter(action => {
      return action.nowait && action.directions.join("") === gesturedDirections;
    });

    if (candidates.length === 0) {
      return null;
    }

    return candidates[0];
  }
}
