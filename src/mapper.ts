import { Neovim } from "neovim";
import { Action } from "./command";
import { InputKind, Input, InputLine, InputText } from "./input";
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
    gestureLines: ReadonlyArray<Input>
  ): Promise<Action | null> {
    const gesturedDirections = gestureLines
      .map(gestureLine => gestureLine.value)
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
    gestureLines: ReadonlyArray<Input>
  ): Promise<Action | null> {
    const gesturedDirections = gestureLines
      .map(gestureLine => gestureLine.value)
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
    inputs: ReadonlyArray<Input>
  ): boolean {
    let i = 0;
    for (const inputDefinition of action.inputs) {
      const input = inputs[i];
      switch (inputDefinition.kind) {
        case InputKind.DIRECTION:
          const inputLine = input as InputLine;
          if (
            (typeof inputDefinition.max_length === "number" &&
              inputDefinition.max_length < inputLine.length) ||
            (typeof inputDefinition.min_length === "number" &&
              inputDefinition.min_length > inputLine.length)
          ) {
            return false;
          }
          break;
        case InputKind.TEXT:
          const inputText = input as InputText;
          if (
            (typeof inputDefinition.max_count === "number" &&
              inputDefinition.max_count < inputText.count) ||
            (typeof inputDefinition.min_count === "number" &&
              inputDefinition.min_count > inputText.count)
          ) {
            return false;
          }
          break;
      }
      i++;
    }

    return true;
  }
}
