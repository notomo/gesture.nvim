import { Direction } from "./direction";

export interface Action {
  directions: Direction[];
  nowait: boolean;
  silent: boolean;
  noremap: boolean;
  rhs: string;
}

export interface Command {
  action: Action;
  command: string;
}

export class CommandFactory {
  public create(action: Action): Command {
    const parts: string[] = [];

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
    };
  }
}
