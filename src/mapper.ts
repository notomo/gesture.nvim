import { Neovim } from "neovim";
import { Action } from "./command";
import { GestureLine } from "./line";
import { Logger, getLogger } from "./logger";

type Actions = { [index: string]: { global: Action } };

export class GestureMapper {
  protected actions: Actions = {};

  protected readonly logger: Logger;

  constructor(protected readonly vim: Neovim) {
    this.logger = getLogger("mapper");
  }

  public async initialize() {
    this.actions = (await this.vim.call("gesture#get")) as Actions;
  }

  public async getAction(
    gestureLines: ReadonlyArray<GestureLine>
  ): Promise<Action | null> {
    const gesturedDirections = gestureLines
      .map(gestureLine => gestureLine.direction)
      .join(",");

    if (!(gesturedDirections in this.actions)) {
      return null;
    }

    return this.actions[gesturedDirections].global;
  }

  public async getNoWaitAction(
    gestureLines: ReadonlyArray<GestureLine>
  ): Promise<Action | null> {
    const gesturedDirections = gestureLines
      .map(gestureLine => gestureLine.direction)
      .join(",");

    if (!(gesturedDirections in this.actions)) {
      return null;
    }

    const action = this.actions[gesturedDirections].global;

    if (!action.nowait) {
      return null;
    }

    return action;
  }
}
