import { Neovim } from "neovim";
import { DirectionRecognizer } from "./recognizer";
import { GestureMapper } from "./mapper";
import { GestureBuffer } from "./buffer";
import { CommandFactory, Command, Action } from "./command";
import { Context } from "./context";
import { Gesture } from "./gesture";
import { InputView } from "./view";
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

  let inputView: InputView;

  let gesture: Gesture;

  let gestureBuffer: GestureBuffer;
  let setup: jest.Mock;
  let isStarted: jest.Mock;
  let restore: jest.Mock;
  let validate: jest.Mock;

  let inputArgument: InputArgument;

  beforeEach(() => {
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({})) as any;
    vim = new NeovimClass();

    const GestureLineClass: jest.Mock<Input> = jest.fn(() => ({})) as any;
    const gestureLine = new GestureLineClass();
    inputs = [gestureLine];

    const ContextClass: jest.Mock<Context> = jest.fn(() => ({})) as any;
    context = new ContextClass();

    clear = jest.fn();
    getInputs = jest.fn().mockReturnValue(inputs);
    getContext = jest.fn().mockReturnValue(context);
    update = jest.fn();
    const DirectionRecognizerClass: jest.Mock<DirectionRecognizer> = jest.fn(
      () => ({
        clear: clear,
        getInputs: getInputs,
        getContext: getContext,
        update: update,
      })
    ) as any;
    directionRecognizer = new DirectionRecognizerClass();

    const ActionClass: jest.Mock<Action> = jest.fn(() => ({})) as any;
    action = new ActionClass();

    initialize = jest.fn();
    getAction = jest.fn().mockReturnValue(action);
    getNoWaitAction = jest.fn().mockReturnValue(action);
    const GestureMapperClass: jest.Mock<GestureMapper> = jest.fn(() => ({
      initialize: initialize,
      getAction: getAction,
      getNoWaitAction: getNoWaitAction,
    })) as any;
    gestureMapper = new GestureMapperClass();

    setup = jest.fn();
    isStarted = jest
      .fn()
      .mockReturnValueOnce(false)
      .mockReturnValueOnce(true);
    restore = jest.fn();
    validate = jest.fn().mockReturnValue(true);
    const GestureBufferClass: jest.Mock<GestureBuffer> = jest.fn(() => ({
      setup: setup,
      isStarted: isStarted,
      restore: restore,
      validate: validate,
    })) as any;
    gestureBuffer = new GestureBufferClass();

    const CommandClass: jest.Mock<Command> = jest.fn(() => ({})) as any;
    command = new CommandClass();

    create = jest.fn().mockReturnValue(command);
    const CommandFactoryClass: jest.Mock<CommandFactory> = jest.fn(() => ({
      create: create,
    }));
    commandFactory = new CommandFactoryClass();

    const render = jest.fn();
    const destroy = jest.fn();
    const InputViewClass: jest.Mock<InputView> = jest.fn(() => ({
      render: render,
      destroy: destroy,
    })) as any;
    inputView = new InputViewClass();

    gesture = new Gesture(
      vim,
      directionRecognizer,
      gestureMapper,
      gestureBuffer,
      commandFactory,
      inputView
    );

    const InputArgumentClass: jest.Mock<InputArgument> = jest.fn(
      () => ({})
    ) as any;
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
    const GestureBufferClass: jest.Mock<GestureBuffer> = jest.fn(() => ({
      restore: restore,
      validate: validate,
    })) as any;
    gestureBuffer = new GestureBufferClass();

    gesture = new Gesture(
      vim,
      directionRecognizer,
      gestureMapper,
      gestureBuffer,
      commandFactory,
      inputView
    );

    const result = await gesture.execute(inputArgument);

    expect(result).toBeNull();
    expect(restore).toHaveBeenCalledTimes(1);
  });

  it("execute returns null when the gesture is not matched with nowait", async () => {
    initialize = jest.fn();
    getNoWaitAction = jest.fn().mockReturnValue(null);
    const GestureMapperClass: jest.Mock<GestureMapper> = jest.fn(() => ({
      initialize: initialize,
      getNoWaitAction: getNoWaitAction,
    })) as any;
    gestureMapper = new GestureMapperClass();

    gesture = new Gesture(
      vim,
      directionRecognizer,
      gestureMapper,
      gestureBuffer,
      commandFactory,
      inputView
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
    const GestureMapperClass: jest.Mock<GestureMapper> = jest.fn(() => ({
      initialize: initialize,
      getAction: getAction,
    })) as any;
    gestureMapper = new GestureMapperClass();

    gesture = new Gesture(
      vim,
      directionRecognizer,
      gestureMapper,
      gestureBuffer,
      commandFactory,
      inputView
    );

    await gesture.initialize(true);

    const result = await gesture.finish();

    expect(result).toBeNull();
    expect(restore).toHaveBeenCalledTimes(1);
    expect(create).not.toHaveBeenCalled();
  });

  it("finish returns null when the buffer is invalid", async () => {
    isStarted = jest.fn().mockReturnValueOnce(true);
    restore = jest.fn();
    validate = jest.fn().mockReturnValue(false);
    const GestureBufferClass: jest.Mock<GestureBuffer> = jest.fn(() => ({
      isStarted: isStarted,
      restore: restore,
      validate: validate,
    })) as any;
    gestureBuffer = new GestureBufferClass();

    gesture = new Gesture(
      vim,
      directionRecognizer,
      gestureMapper,
      gestureBuffer,
      commandFactory,
      inputView
    );
    const result = await gesture.finish();

    expect(result).toBeNull();
    expect(restore).toHaveBeenCalledTimes(1);
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
