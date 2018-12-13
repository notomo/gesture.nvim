import { Direction } from "./direction";

export interface Action {
  lines: {
    direction: Direction;
    max_length?: number;
    min_length?: number;
  }[];
  nowait: boolean;
  silent: boolean;
  noremap: boolean;
  is_func: boolean;
  rhs: string;
}

export interface Context {
  windows: {
    id: number;
    bufferId: number;
  }[];
}

export interface Command {
  action: Action;
  command: string;
  context: Context;
}

export class CommandFactory {
  public create(action: Action, context: Context): Command {
    const parts: string[] = [];

    if (action.is_func) {
      return { action: action, command: "", context: context };
    }

    if (action.silent) {
      parts.push("silent");
    }

    let normalCommand: string;
    if (action.noremap) {
      normalCommand = "normal!";
    } else {
      normalCommand = "normal";
    }
    parts.push(normalCommand);

    parts.push(action.rhs);

    const command = parts.join(" ");

    return {
      action: action,
      command: command,
      context: context,
    };
  }
}
