import { NvimPlugin } from "neovim";
import { Gesture } from "./gesture";
import { Reporter } from "./reporter";
import { Di } from "./di";

export class GesturePlugin {
  protected readonly gesture: Gesture;
  protected readonly reporter: Reporter;

  constructor(protected readonly plugin: NvimPlugin) {
    const vim = plugin.nvim;
    this.gesture = Di.get("Gesture", vim);
    this.reporter = Di.get("Reporter", vim);

    plugin.setOptions({ dev: false, alwaysInit: false });

    plugin.registerFunction("_gesture_execute", [this, this.execute], {
      sync: true,
    });

    plugin.registerFunction("_gesture_finish", [this, this.finish], {
      sync: true,
    });
  }

  public async execute(args: string[]): Promise<void> {
    await this.gesture.execute().catch(e => this.reporter.error(e));
  }

  public async finish(args: string[]): Promise<void> {
    await this.gesture.finish().catch(e => this.reporter.error(e));
  }
}

const newPlugin = (plugin: NvimPlugin) => new GesturePlugin(plugin);
export default newPlugin;
