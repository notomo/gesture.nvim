import { Neovim, Window } from "neovim";
import { DirectionRecognizer } from "./recognizer";
import { PointFactory, Point } from "./point";
import { ConfigRepository } from "./repository/config";
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

    recognizer = new DirectionRecognizer(vim, pointFactory, configRepository);
  });

  it("add the same direction", async () => {
    await recognizer.add(1, 1);

    const gestureLines1 = recognizer.getGestureLines();

    await recognizer.add(1, 1);

    const gestureLines2 = recognizer.getGestureLines();

    expect(gestureLines1).toEqual([infoLeft]);
    expect(gestureLines2[0].length).toEqual(infoLeft.length * 2);
  });

  it("add different direction", async () => {
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

    recognizer = new DirectionRecognizer(vim, pointFactory, configRepository);

    await recognizer.add(1, 1);
    await recognizer.add(1, 1);

    const gestureLines = recognizer.getGestureLines();

    expect(gestureLines).toEqual([infoLeft, infoRight]);
  });

  it("add is filtered when the length is short", async () => {
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

    recognizer = new DirectionRecognizer(vim, pointFactory, configRepository);

    await recognizer.add(1, 1);

    const gestureLines = recognizer.getGestureLines();

    expect(gestureLines).toEqual([]);
  });

  it("clear", async () => {
    await recognizer.add(1, 1);

    const context = await recognizer.getContext();
    expect(context).toEqual({
      windows: [{ id: windowId, bufferId: bufferId }],
    });

    const gestureLines = recognizer.getGestureLines();

    await recognizer.clear();

    expect(await recognizer.getContext()).toEqual({ windows: [] });
    expect(recognizer.getGestureLines()).toEqual([]);
    expect(gestureLines).toEqual([infoLeft]);
  });
});
