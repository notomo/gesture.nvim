import { Neovim, Window } from "neovim";
import { DirectionRecognizer } from "./recognizer";
import { PointFactory, Point } from "./point";
import { ConfigRepository } from "./repository/config";
import { TabpageRepository } from "./repository/tabpage";
import { InputKind, InputLineArgument, InputTextArgument } from "./input";
import { Direction } from "./direction";

describe("DirectionRecognizer", () => {
  const bufferId = 1;
  const windowId = 2;
  let vim: Neovim;

  let recognizer: DirectionRecognizer;

  let calculate: jest.Mock;
  const infoLeft = {
    direction: Direction.LEFT,
    length: 10,
  };
  const infoRight = {
    direction: Direction.RIGHT,
    length: 10,
  };
  const infoShortLength = {
    direction: Direction.UP,
    length: 3,
  };

  let pointFactory: PointFactory;
  let create: jest.Mock;
  let createForInitialize: jest.Mock;

  let configRepository: ConfigRepository;
  let getMinLengthByDirection: jest.Mock;

  let tabpageRepository: TabpageRepository;
  let getGlobalPosition: jest.Mock;

  const inputLineArgument: InputLineArgument = {
    kind: InputKind.DIRECTION,
    value: null,
  };

  const inputTextArgument: InputTextArgument = {
    kind: InputKind.TEXT,
    value: "inputText",
  };

  beforeEach(() => {
    const BufferClass = jest.fn<Buffer>(() => ({
      id: bufferId,
    }));
    const buf = new BufferClass();

    const buffer = jest.fn().mockImplementation(async () => {
      return buf;
    })();

    const WindowClass = jest.fn<Window>(() => ({
      id: windowId,
      buffer: buffer,
    }));
    const win = new WindowClass();

    const window = jest.fn().mockImplementation(async () => {
      return win;
    })();

    const NeovimClass = jest.fn<Neovim>(() => ({
      window: window,
    }));
    vim = new NeovimClass();

    calculate = jest.fn().mockReturnValue(infoLeft);
    const PointClass = jest.fn<Point>(() => ({
      calculate: calculate,
    }));
    const point = new PointClass();

    create = jest.fn().mockReturnValue(point);
    createForInitialize = jest.fn().mockReturnValue(point);
    const PointFactoryClass = jest.fn<PointFactory>(() => ({
      create: create,
      createForInitialize: createForInitialize,
    }));
    pointFactory = new PointFactoryClass();

    getMinLengthByDirection = jest.fn().mockReturnValue(8);
    const ConfigRepositoryClass = jest.fn<ConfigRepository>(() => ({
      getMinLengthByDirection: getMinLengthByDirection,
    }));
    configRepository = new ConfigRepositoryClass();

    getGlobalPosition = jest.fn().mockReturnValue({ x: 1, y: 1 });
    const TabpageRepositoryClass = jest.fn<TabpageRepository>(() => ({
      getGlobalPosition: getGlobalPosition,
    }));
    tabpageRepository = new TabpageRepositoryClass();

    recognizer = new DirectionRecognizer(
      vim,
      pointFactory,
      tabpageRepository,
      configRepository
    );
  });

  it("update by the same direction", async () => {
    await recognizer.update(inputLineArgument);

    const gestureLines1 = recognizer.getInputs();

    expect(gestureLines1[0]).toEqual({
      kind: InputKind.DIRECTION,
      length: infoLeft.length,
      value: infoLeft.direction,
    });

    await recognizer.update(inputLineArgument);

    const gestureLines2 = recognizer.getInputs();

    expect(gestureLines2[0]).toEqual({
      kind: InputKind.DIRECTION,
      length: infoLeft.length * 2,
      value: infoLeft.direction,
    });
  });

  it("update by different direction", async () => {
    calculate = jest
      .fn()
      .mockReturnValueOnce(infoLeft)
      .mockReturnValueOnce(infoRight);
    const PointClass = jest.fn<Point>(() => ({
      calculate: calculate,
    }));
    const point = new PointClass();

    create = jest.fn().mockReturnValue(point);
    const PointFactoryClass = jest.fn<PointFactory>(() => ({
      create: create,
      createForInitialize: createForInitialize,
    }));
    pointFactory = new PointFactoryClass();

    recognizer = new DirectionRecognizer(
      vim,
      pointFactory,
      tabpageRepository,
      configRepository
    );

    await recognizer.update(inputLineArgument);
    await recognizer.update(inputLineArgument);

    const gestureLines = recognizer.getInputs();

    expect(gestureLines).toEqual([
      {
        kind: InputKind.DIRECTION,
        length: infoLeft.length,
        value: infoLeft.direction,
      },
      {
        kind: InputKind.DIRECTION,
        length: infoRight.length,
        value: infoRight.direction,
      },
    ]);
  });

  it("update is filters line when the length is short", async () => {
    calculate = jest.fn().mockReturnValue(infoShortLength);
    const PointClass = jest.fn<Point>(() => ({
      calculate: calculate,
    }));
    const point = new PointClass();

    create = jest.fn().mockReturnValue(point);
    const PointFactoryClass = jest.fn<PointFactory>(() => ({
      create: create,
      createForInitialize: createForInitialize,
    }));
    pointFactory = new PointFactoryClass();

    recognizer = new DirectionRecognizer(
      vim,
      pointFactory,
      tabpageRepository,
      configRepository
    );

    await recognizer.update(inputLineArgument);

    const gestureLines = recognizer.getInputs();

    expect(gestureLines).toEqual([]);
  });

  it("update by the same text", async () => {
    await recognizer.update(inputTextArgument);

    const input1 = recognizer.getInputs();

    expect(input1[0]).toEqual({
      kind: InputKind.TEXT,
      value: inputTextArgument.value,
      count: 1,
    });

    await recognizer.update(inputTextArgument);

    const input2 = recognizer.getInputs();

    expect(input2[0]).toEqual({
      kind: InputKind.TEXT,
      value: inputTextArgument.value,
      count: 2,
    });

    await recognizer.update(inputLineArgument);

    const input3 = recognizer.getInputs();

    expect(input3).toEqual([
      {
        kind: InputKind.TEXT,
        value: inputTextArgument.value,
        count: 2,
      },
      {
        kind: InputKind.DIRECTION,
        length: infoLeft.length,
        value: infoLeft.direction,
      },
    ]);
  });

  it("clear", async () => {
    await recognizer.update(inputLineArgument);

    const context = await recognizer.getContext();
    expect(context).toEqual({
      windows: [{ id: windowId, bufferId: bufferId }],
    });

    const gestureLines = recognizer.getInputs();

    await recognizer.clear();

    expect(await recognizer.getContext()).toEqual({ windows: [] });
    expect(recognizer.getInputs()).toEqual([]);
    expect(gestureLines).toEqual([
      {
        kind: InputKind.DIRECTION,
        length: infoLeft.length,
        value: infoLeft.direction,
      },
    ]);
  });
});
