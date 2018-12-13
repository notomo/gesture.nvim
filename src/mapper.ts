import { Neovim } from "neovim";
import { Action } from "./command";
import { GestureLine } from "./line";
import { Logger, getLogger } from "./logger";

type Actions = {
  [index: string]: {
    global: Action[];
    buffer: { [index: number]: Action[] };
  };
};

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

    const bufferId = (await this.vim.buffer).id;
    if (bufferId in this.actions[gesturedDirections].buffer) {
      const bufferLocalActions = this.actions[gesturedDirections].buffer[
        bufferId
      ].filter(action => this.filterAction(action, gestureLines));
      if (bufferLocalActions.length !== 0) {
        return bufferLocalActions[0];
      }
    }

    const actions = this.actions[gesturedDirections].global.filter(action =>
      this.filterAction(action, gestureLines)
    );
    return actions.length === 0 ? null : actions[0];
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

    const bufferId = (await this.vim.buffer).id;
    if (bufferId in this.actions[gesturedDirections].buffer) {
      const bufferLocalActions = this.actions[gesturedDirections].buffer[
        bufferId
      ].filter(
        action => action.nowait && this.filterAction(action, gestureLines)
      );
      if (bufferLocalActions.length !== 0) {
        return bufferLocalActions[0];
      }
    }

    const actions = this.actions[gesturedDirections].global.filter(
      action => action.nowait && this.filterAction(action, gestureLines)
    );
    return actions.length === 0 ? null : actions[0];
  }

  protected filterAction(
    action: Action,
    gestureLines: ReadonlyArray<GestureLine>
  ): boolean {
    let i = 0;
    for (const line of action.lines) {
      const gestureLine = gestureLines[i];
      if (
        (typeof line.max_length === "number" &&
          line.max_length < gestureLine.length) ||
        (typeof line.min_length === "number" &&
          line.min_length > gestureLine.length)
      ) {
        return false;
      }
      i++;
    }

    return true;
  }
}
