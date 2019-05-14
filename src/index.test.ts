import { NvimPlugin, Neovim } from "neovim";
import { GesturePlugin } from "./index";
import { Gesture } from "./gesture";
import { Reporter } from "./reporter";
import { InputKind } from "./input";
import { Di } from "./di";
import newPlugin from "./index";

describe("GesturePlugin", () => {
  let plugin: NvimPlugin;
  let setOptions: jest.Mock;
  let registerFunction: jest.Mock;

  let gesturePlugin: GesturePlugin;

  let initialize: jest.Mock;
  let execute: jest.Mock;
  let finish: jest.Mock;
  let getInputs: jest.Mock;
  let isStarted: jest.Mock;

  let error: jest.Mock;

  beforeEach(() => {
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({})) as any;
    const nvim = new NeovimClass();

    setOptions = jest.fn();
    registerFunction = jest.fn();
    const NvimPluginClass: jest.Mock<NvimPlugin> = jest.fn(() => ({
      nvim: nvim,
      setOptions: setOptions,
      registerFunction: registerFunction,
    })) as any;
    plugin = new NvimPluginClass();

    initialize = jest.fn().mockImplementation(async () => {
      return;
    });
    execute = jest.fn().mockImplementation(async () => {
      return null;
    });
    finish = jest.fn().mockImplementation(async () => {
      return null;
    });
    getInputs = jest.fn().mockReturnValue([]);
    isStarted = jest.fn().mockReturnValue(false);
    const GestureClass: jest.Mock<Gesture> = jest.fn(() => ({
      initialize: initialize,
      execute: execute,
      finish: finish,
      getInputs: getInputs,
      isStarted: isStarted,
    })) as any;
    const gesture = new GestureClass();
    Di.set("Gesture", gesture);

    error = jest.fn();
    const ReporterClass: jest.Mock<Reporter> = jest.fn(() => ({
      error: error,
    })) as any;
    const reporter = new ReporterClass();
    Di.set("Reporter", reporter);

    gesturePlugin = new GesturePlugin(plugin);
  });

  it("initialize", async () => {
    await gesturePlugin.initialize([true]);

    expect(initialize).toHaveBeenCalled();
  });

  it("initialize reports error on error", async () => {
    initialize = jest.fn().mockImplementation(async () => {
      throw new Error("");
    });

    const GestureClass: jest.Mock<Gesture> = jest.fn(() => ({
      initialize: initialize,
    })) as any;
    const gesture = new GestureClass();
    Di.set("Gesture", gesture);

    gesturePlugin = new GesturePlugin(plugin);

    await gesturePlugin.initialize([true]);

    expect(error).toHaveBeenCalled();
  });

  it("execute", async () => {
    const result = await gesturePlugin.execute([InputKind.DIRECTION, null]);

    expect(result).toBeNull();
  });

  it("execute reports error on error", async () => {
    execute = jest.fn().mockImplementation(async () => {
      throw new Error("");
    });

    const GestureClass: jest.Mock<Gesture> = jest.fn(() => ({
      execute: execute,
    })) as any;
    const gesture = new GestureClass();
    Di.set("Gesture", gesture);

    gesturePlugin = new GesturePlugin(plugin);

    const result = await gesturePlugin.execute([InputKind.DIRECTION, null]);

    expect(error).toHaveBeenCalled();
    expect(result).toBeNull();
  });

  it("finish", async () => {
    const result = await gesturePlugin.finish([]);

    expect(result).toBeNull();
  });

  it("finish reports error on error", async () => {
    finish = jest.fn().mockImplementation(async () => {
      throw new Error("");
    });

    const GestureClass: jest.Mock<Gesture> = jest.fn(() => ({
      finish: finish,
    })) as any;
    const gesture = new GestureClass();
    Di.set("Gesture", gesture);

    gesturePlugin = new GesturePlugin(plugin);

    const result = await gesturePlugin.finish([]);

    expect(error).toHaveBeenCalled();
    expect(result).toBeNull();
  });

  it("getInputs", () => {
    const result = gesturePlugin.getInputs([]);

    expect(result).toEqual([]);
  });

  it("isStarted", () => {
    const result = gesturePlugin.isStarted([]);

    expect(result).toEqual(false);
  });

  it("newPlugin", () => {
    newPlugin(plugin);
  });
});
