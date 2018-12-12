import { Neovim } from "neovim";
import { DirectionRecognizer } from "./recognizer";
import { GestureMapper } from "./mapper";
import { GestureBuffer } from "./buffer";
import { CommandFactory, Command, Context, Action } from "./command";
import { Gesture } from "./gesture";
import { GestureLine } from "./line";

describe("Gesture", () => {
  let vim: Neovim;

  let directionRecognizer: DirectionRecognizer;
  let clear: jest.Mock;
  let getGestureLines: jest.Mock;
  let gestureLines: GestureLine[];
  let context: Context;
  let getContext: jest.Mock;
  let add: jest.Mock;

  let action: Action;
  let gestureMapper: GestureMapper;
  let initialize: jest.Mock;
  let getAction: jest.Mock;
  let getNoWaitAction: jest.Mock;

  let command: Command;
  let commandFactory: CommandFactory;
  let create: jest.Mock;

  let gesture: Gesture;

  let gestureBuffer: GestureBuffer;
  let setup: jest.Mock;
  let isStarted: jest.Mock;
  let restore: jest.Mock;
  let validate: jest.Mock;
  let getCursor: jest.Mock;

  beforeEach(() => {
    const NeovimClass = jest.fn<Neovim>(() => ({}));
    vim = new NeovimClass();

    const GestureLineClass = jest.fn<GestureLine>(() => ({}));
    const gestureLine = new GestureLineClass();
    gestureLines = [gestureLine];

    const ContextClass = jest.fn<Context>(() => ({}));
    context = new ContextClass();

    clear = jest.fn();
    getGestureLines = jest.fn().mockReturnValue(gestureLines);
    getContext = jest.fn().mockReturnValue(context);
    add = jest.fn();
    const DirectionRecognizerClass = jest.fn<DirectionRecognizer>(() => ({
      clear: clear,
      getGestureLines: getGestureLines,
      getContext: getContext,
      add: add,
    }));
    directionRecognizer = new DirectionRecognizerClass();

    const ActionClass = jest.fn<Action>(() => ({}));
    action = new ActionClass();

    initialize = jest.fn();
    getAction = jest.fn().mockReturnValue(action);
    getNoWaitAction = jest.fn().mockReturnValue(action);
    const GestureMapperClass = jest.fn<GestureMapper>(() => ({
      initialize: initialize,
      getAction: getAction,
      getNoWaitAction: getNoWaitAction,
    }));
    gestureMapper = new GestureMapperClass();

    setup = jest.fn();
    isStarted = jest
      .fn()
      .mockReturnValueOnce(false)
      .mockReturnValueOnce(true);
    restore = jest.fn();
    validate = jest.fn().mockReturnValue(true);
    getCursor = jest.fn().mockReturnValue({ x: 1, y: 1 });
    const GestureBufferClass = jest.fn<GestureBuffer>(() => ({
      setup: setup,
      isStarted: isStarted,
      restore: restore,
      validate: validate,
      getCursor: getCursor,
    }));
    gestureBuffer = new GestureBufferClass();

    const CommandClass = jest.fn<Command>(() => ({}));
    command = new CommandClass();

    create = jest.fn().mockReturnValue(command);
    const CommandFactoryClass = jest.fn<CommandFactory>(() => ({
      create: create,
    }));
    commandFactory = new CommandFactoryClass();

    gesture = new Gesture(
      vim,
      directionRecognizer,
      gestureMapper,
      gestureBuffer,
      commandFactory
    );
  });

  it("initialize", async () => {
    await gesture.initialize();
    await gesture.initialize();

    expect(clear).toHaveBeenCalledTimes(1);
    expect(initialize).toHaveBeenCalledTimes(1);
    expect(setup).toHaveBeenCalledTimes(1);
  });

  it("execute returns null when the gesture is invalid", async () => {
    restore = jest.fn();
    validate = jest.fn().mockReturnValue(false);
    const GestureBufferClass = jest.fn<GestureBuffer>(() => ({
      restore: restore,
      validate: validate,
    }));
    gestureBuffer = new GestureBufferClass();

    gesture = new Gesture(
      vim,
      directionRecognizer,
      gestureMapper,
      gestureBuffer,
      commandFactory
    );

    const result = await gesture.execute();

    expect(result).toBeNull();
    expect(restore).toHaveBeenCalledTimes(1);
  });

  it("execute returns null when the gesture is not matched with nowait", async () => {
    initialize = jest.fn();
    getNoWaitAction = jest.fn().mockReturnValue(null);
    const GestureMapperClass = jest.fn<GestureMapper>(() => ({
      initialize: initialize,
      getNoWaitAction: getNoWaitAction,
    }));
    gestureMapper = new GestureMapperClass();

    gesture = new Gesture(
      vim,
      directionRecognizer,
      gestureMapper,
      gestureBuffer,
      commandFactory
    );

    const result = await gesture.execute();

    expect(result).toBeNull();
    expect(restore).not.toHaveBeenCalled();
  });

  it("execute", async () => {
    const result = await gesture.execute();

    expect(result).toEqual(command);
    expect(restore).toHaveBeenCalledTimes(1);
    expect(create).toHaveBeenCalledWith(action, context);
  });

  it("finish returns null when the gesture is not started", async () => {
    const result = await gesture.finish();

    expect(result).toBeNull();
  });

  it("finish returns null when the gesture is not matched", async () => {
    initialize = jest.fn();
    getAction = jest.fn().mockReturnValue(null);
    const GestureMapperClass = jest.fn<GestureMapper>(() => ({
      initialize: initialize,
      getAction: getAction,
    }));
    gestureMapper = new GestureMapperClass();

    gesture = new Gesture(
      vim,
      directionRecognizer,
      gestureMapper,
      gestureBuffer,
      commandFactory
    );

    await gesture.initialize();

    const result = await gesture.finish();

    expect(result).toBeNull();
    expect(restore).toHaveBeenCalledTimes(1);
    expect(create).not.toHaveBeenCalled();
  });

  it("finish", async () => {
    await gesture.initialize();

    const result = await gesture.finish();

    expect(result).toEqual(command);
    expect(restore).toHaveBeenCalledTimes(1);
    expect(create).toHaveBeenCalledWith(action, context);
  });

  it("getGestureLines returns empty when the gesture is not started", async () => {
    const result = await gesture.getGestureLines();

    expect(result).toEqual([]);
  });

  it("getGestureLines", async () => {
    await gesture.initialize();

    const result = await gesture.getGestureLines();

    expect(result).toEqual(gestureLines);
  });
});
