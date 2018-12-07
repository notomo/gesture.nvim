import { Neovim } from "neovim";
import { GestureMapper } from "./mapper";
import { Direction } from "./direction";

describe("GestureMapper", () => {
  let mapper: GestureMapper;

  let call: jest.Mock;
  let buffer1: jest.Mock;

  let buffer2: jest.Mock;

  beforeEach(() => {
    const BufferClass1 = jest.fn<Buffer>(() => ({
      id: 1,
    }));
    const buf1 = new BufferClass1();

    const BufferClass2 = jest.fn<Buffer>(() => ({
      id: 2,
    }));
    const buf2 = new BufferClass2();

    buffer1 = jest.fn().mockImplementation(async () => {
      return buf1;
    })();

    buffer2 = jest.fn().mockImplementation(async () => {
      return buf2;
    })();

    call = jest.fn().mockReturnValue({
      "LEFT,RIGHT": {
        global: {
          nowait: false,
          directions: [Direction.LEFT, Direction.RIGHT],
        },
        buffer: {
          2: {
            nowait: false,
            directions: [Direction.LEFT, Direction.RIGHT],
            buffer: true,
          },
        },
      },
      LEFT: {
        global: { nowait: true, directions: [Direction.LEFT] },
        buffer: {
          2: { nowait: true, directions: [Direction.LEFT], buffer: true },
        },
      },
      RIGHT: {
        global: { nowait: false, directions: [Direction.RIGHT] },
        buffer: {
          2: { nowait: false, directions: [Direction.RIGHT] },
        },
      },
    });
    const NeovimClass = jest.fn<Neovim>(() => ({
      call: call,
      buffer: buffer1,
    }));
    const vim = new NeovimClass();

    mapper = new GestureMapper(vim);
  });

  it("initialize", async () => {
    await mapper.initialize();

    expect(call).toHaveBeenCalled();
  });

  it("getAction", async () => {
    await mapper.initialize();

    const result = await mapper.getAction([
      { direction: Direction.LEFT, length: 10 },
      { direction: Direction.RIGHT, length: 10 },
    ]);

    const expected = {
      nowait: false,
      directions: [Direction.LEFT, Direction.RIGHT],
    };
    expect(result).toEqual(expected);
  });

  it("getAction returns a buffer local action", async () => {
    const NeovimClass = jest.fn<Neovim>(() => ({
      call: call,
      buffer: buffer2,
    }));
    const vim = new NeovimClass();

    mapper = new GestureMapper(vim);

    await mapper.initialize();

    const result = await mapper.getAction([
      { direction: Direction.LEFT, length: 10 },
      { direction: Direction.RIGHT, length: 10 },
    ]);

    const expected = {
      nowait: false,
      directions: [Direction.LEFT, Direction.RIGHT],
      buffer: true,
    };
    expect(result).toEqual(expected);
  });

  it("getAction returns null when the gesture does not matched", async () => {
    const result = await mapper.getAction([
      { direction: Direction.LEFT, length: 10 },
    ]);

    expect(result).toBeNull();
  });

  it("getNoWaitAction", async () => {
    await mapper.initialize();

    const result = await mapper.getNoWaitAction([
      { direction: Direction.LEFT, length: 10 },
    ]);

    const expected = {
      nowait: true,
      directions: [Direction.LEFT],
    };
    expect(result).toEqual(expected);
  });

  it("getNoWaitAction returns a buffer local action", async () => {
    const NeovimClass = jest.fn<Neovim>(() => ({
      call: call,
      buffer: buffer2,
    }));
    const vim = new NeovimClass();

    mapper = new GestureMapper(vim);

    await mapper.initialize();

    const result = await mapper.getNoWaitAction([
      { direction: Direction.LEFT, length: 10 },
    ]);

    const expected = {
      nowait: true,
      directions: [Direction.LEFT],
      buffer: true,
    };
    expect(result).toEqual(expected);
  });

  it("getNoWaitAction returns null when the gesture does not matched", async () => {
    const result = await mapper.getNoWaitAction([
      { direction: Direction.LEFT, length: 10 },
    ]);

    expect(result).toBeNull();
  });

  it("getNoWaitAction returns null when the gesture does not matched nowait", async () => {
    await mapper.initialize();

    const result = await mapper.getNoWaitAction([
      { direction: Direction.RIGHT, length: 10 },
    ]);

    expect(result).toBeNull();
  });
});
