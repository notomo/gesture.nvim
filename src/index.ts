import { NvimPlugin } from "neovim";
import { Gesture } from "./gesture";
import { Reporter } from "./reporter";
import { Di } from "./di";
import { Command } from "./command";
import { Input, InputKind, InputArgument } from "./input";

export class GesturePlugin {
  protected readonly gesture: Gesture;
  protected readonly reporter: Reporter;

  constructor(protected readonly plugin: NvimPlugin) {
    const vim = plugin.nvim;
    this.gesture = Di.get("Gesture", vim);
    this.reporter = Di.get("Reporter", vim);

    plugin.setOptions({ dev: false, alwaysInit: false });

    plugin.registerFunction("_gesture_initialize", [this, this.initialize], {
      sync: true,
    });

    plugin.registerFunction("_gesture_execute", [this, this.execute], {
      sync: true,
    });

    plugin.registerFunction("_gesture_finish", [this, this.finish], {
      sync: true,
    });

    plugin.registerFunction("_gesture_get_inputs", [this, this.getInputs], {
      sync: true,
    });
  }

  public async initialize(args: []): Promise<void> {
    await this.gesture.initialize().catch(e => this.reporter.error(e));
  }

  public async execute(
    args: [InputKind.DIRECTION, null] | [InputKind.TEXT, string]
  ): Promise<Command | null> {
    const inputArgument = {
      kind: args[0],
      value: args[1],
    } as InputArgument;
    return await this.gesture.execute(inputArgument).catch(e => {
      this.reporter.error(e);
      return null;
    });
  }

  public async finish(args: []): Promise<Command | null> {
    return await this.gesture.finish().catch(e => {
      this.reporter.error(e);
      return null;
    });
  }

  public getInputs(args: []): ReadonlyArray<Input> {
    return this.gesture.getInputs();
  }
}

const newPlugin = (plugin: NvimPlugin) => new GesturePlugin(plugin);
export default newPlugin;
