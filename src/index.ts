import { NvimPlugin } from "neovim";
import { Gesture } from "./gesture";
import { Reporter } from "./reporter";
import { Di } from "./di";
import { Command } from "./command";
import { GestureLine } from "./line";

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

    plugin.registerFunction("_gesture_lines", [this, this.getGestureLines], {
      sync: true,
    });
  }

  public async initialize(args: []): Promise<void> {
    await this.gesture.initialize().catch(e => this.reporter.error(e));
  }

  public async execute(args: []): Promise<Command | null> {
    return await this.gesture.execute().catch(e => {
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

  public getGestureLines(args: []): ReadonlyArray<GestureLine> {
    return this.gesture.getGestureLines();
  }
}

const newPlugin = (plugin: NvimPlugin) => new GesturePlugin(plugin);
export default newPlugin;
