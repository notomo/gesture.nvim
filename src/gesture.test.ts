import { Neovim } from "neovim";
import { DirectionRecognizer } from "./recognizer";
import { GestureMapper } from "./mapper";
import { GestureBuffer } from "./buffer";
import { CommandFactory, Command, Context, Action } from "./command";
import { Gesture } from "./gesture";
import { Input, InputArgument } from "./input";

describe("Gesture", () => {
  let vim: Neovim;

  let directionRecognizer: DirectionRecognizer;
  let clear: jest.Mock;
  let getInputs: jest.Mock;
  let inputs: Input[];
  let context: Context;
  let getContext: jest.Mock;
  let update: jest.Mock;

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

  let inputArgument: InputArgument;

  beforeEach(() => {
    const NeovimClass = jest.fn<Neovim>(() => ({}));
    vim = new NeovimClass();

    const GestureLineClass = jest.fn<Input>(() => ({}));
    const gestureLine = new GestureLineClass();
    inputs = [gestureLine];

    const ContextClass = jest.fn<Context>(() => ({}));
    context = new ContextClass();

    clear = jest.fn();
    getInputs = jest.fn().mockReturnValue(inputs);
    getContext = jest.fn().mockReturnValue(context);
    update = jest.fn();
    const DirectionRecognizerClass = jest.fn<DirectionRecognizer>(() => ({
      clear: clear,
      getInputs: getInputs,
      getContext: getContext,
      update: update,
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
    const GestureBufferClass = jest.fn<GestureBuffer>(() => ({
      setup: setup,
      isStarted: isStarted,
      restore: restore,
      validate: validate,
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

    const InputArgumentClass = jest.fn<InputArgument>(() => ({}));
    inputArgument = new InputArgumentClass();
  });

  it("initialize", async () => {
    await gesture.initialize(true);
    await gesture.initialize(true);

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

    const result = await gesture.execute(inputArgument);

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

    const result = await gesture.execute(inputArgument);

    expect(result).toBeNull();
    expect(restore).not.toHaveBeenCalled();
  });

  it("execute", async () => {
    const result = await gesture.execute(inputArgument);

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

    await gesture.initialize(true);

    const result = await gesture.finish();

    expect(result).toBeNull();
    expect(restore).toHaveBeenCalledTimes(1);
    expect(create).not.toHaveBeenCalled();
  });

  it("finish", async () => {
    await gesture.initialize(true);

    const result = await gesture.finish();

    expect(result).toEqual(command);
    expect(restore).toHaveBeenCalledTimes(1);
    expect(create).toHaveBeenCalledWith(action, context);
  });

  it("getInputs returns empty when the gesture is not started", async () => {
    const result = await gesture.getInputs();

    expect(result).toEqual([]);
  });

  it("getInputs", async () => {
    await gesture.initialize(true);

    const result = await gesture.getInputs();

    expect(result).toEqual(inputs);
  });

  it("isStarted", async () => {
    const result = await gesture.isStarted();

    expect(result).toEqual(false);
  });
});
