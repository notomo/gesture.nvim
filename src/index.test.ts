import { NvimPlugin, Neovim } from "neovim";
import { GesturePlugin } from "./index";
import { Gesture } from "./gesture";
import { Reporter } from "./reporter";
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
  let getGestureLines: jest.Mock;

  let error: jest.Mock;

  beforeEach(() => {
    const NeovimClass = jest.fn<Neovim>(() => ({}));
    const nvim = new NeovimClass();

    setOptions = jest.fn();
    registerFunction = jest.fn();
    const NvimPluginClass = jest.fn<NvimPlugin>(() => ({
      nvim: nvim,
      setOptions: setOptions,
      registerFunction: registerFunction,
    }));
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
    getGestureLines = jest.fn().mockReturnValue([]);
    const GestureClass = jest.fn<Gesture>(() => ({
      initialize: initialize,
      execute: execute,
      finish: finish,
      getGestureLines: getGestureLines,
    }));
    const gesture = new GestureClass();
    Di.set("Gesture", gesture);

    error = jest.fn();
    const ReporterClass = jest.fn<Reporter>(() => ({
      error: error,
    }));
    const reporter = new ReporterClass();
    Di.set("Reporter", reporter);

    gesturePlugin = new GesturePlugin(plugin);
  });

  it("initialize", async () => {
    await gesturePlugin.initialize([]);

    expect(initialize).toHaveBeenCalled();
  });

  it("initialize reports error on error", async () => {
    initialize = jest.fn().mockImplementation(async () => {
      throw new Error("");
    });

    const GestureClass = jest.fn<Gesture>(() => ({
      initialize: initialize,
    }));
    const gesture = new GestureClass();
    Di.set("Gesture", gesture);

    gesturePlugin = new GesturePlugin(plugin);

    await gesturePlugin.initialize([]);

    expect(error).toHaveBeenCalled();
  });

  it("execute", async () => {
    const result = await gesturePlugin.execute([]);

    expect(result).toBeNull();
  });

  it("execute reports error on error", async () => {
    execute = jest.fn().mockImplementation(async () => {
      throw new Error("");
    });

    const GestureClass = jest.fn<Gesture>(() => ({
      execute: execute,
    }));
    const gesture = new GestureClass();
    Di.set("Gesture", gesture);

    gesturePlugin = new GesturePlugin(plugin);

    const result = await gesturePlugin.execute([]);

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

    const GestureClass = jest.fn<Gesture>(() => ({
      finish: finish,
    }));
    const gesture = new GestureClass();
    Di.set("Gesture", gesture);

    gesturePlugin = new GesturePlugin(plugin);

    const result = await gesturePlugin.finish([]);

    expect(error).toHaveBeenCalled();
    expect(result).toBeNull();
  });

  it("getGestureLines", () => {
    const result = gesturePlugin.getGestureLines([]);

    expect(result).toEqual([]);
  });

  it("newPlugin", () => {
    newPlugin(plugin);
  });
});
