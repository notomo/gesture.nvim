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
        global: [
          {
            nowait: false,
            lines: [
              { direction: Direction.LEFT },
              { direction: Direction.RIGHT },
            ],
          },
        ],
        buffer: {
          2: [
            {
              nowait: false,
              lines: [
                { direction: Direction.LEFT },
                { direction: Direction.RIGHT },
              ],
              buffer: true,
            },
          ],
        },
      },
      LEFT: {
        global: [
          {
            nowait: true,
            lines: [{ direction: Direction.LEFT, min_length: 8 }],
          },
        ],
        buffer: {
          2: [
            {
              nowait: true,
              lines: [{ direction: Direction.LEFT }],
              buffer: true,
            },
          ],
        },
      },
      RIGHT: {
        global: [{ nowait: false, lines: [{ direction: Direction.RIGHT }] }],
        buffer: {
          2: [{ nowait: false, lines: [{ direction: Direction.RIGHT }] }],
        },
      },
      DOWN: {
        global: [
          {
            nowait: false,
            lines: [{ direction: Direction.DOWN, max_length: 20 }],
          },
        ],
        buffer: {},
      },
      UP: {
        global: [],
        buffer: {
          2: [
            {
              nowait: false,
              lines: [{ direction: Direction.UP, min_length: 10 }],
            },
          ],
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
      lines: [{ direction: Direction.LEFT }, { direction: Direction.RIGHT }],
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
      lines: [{ direction: Direction.LEFT }, { direction: Direction.RIGHT }],
      buffer: true,
    };
    expect(result).toEqual(expected);
  });

  it("getAction returns null when the gesture is filtered buffer local action by min_length", async () => {
    const NeovimClass = jest.fn<Neovim>(() => ({
      call: call,
      buffer: buffer2,
    }));
    const vim = new NeovimClass();

    mapper = new GestureMapper(vim);

    await mapper.initialize();

    const result = await mapper.getAction([
      { direction: Direction.UP, length: 7 },
    ]);

    expect(result).toBeNull();
  });

  it("getAction returns null when the gesture does not matched", async () => {
    const result = await mapper.getAction([
      { direction: Direction.LEFT, length: 10 },
    ]);

    expect(result).toBeNull();
  });

  it("getAction returns null when the gesture is filtered by min_length", async () => {
    await mapper.initialize();

    const result = await mapper.getAction([
      { direction: Direction.LEFT, length: 7 },
    ]);

    expect(result).toBeNull();
  });

  it("getAction returns null when the gesture is filtered by max_length", async () => {
    await mapper.initialize();

    const result = await mapper.getAction([
      { direction: Direction.DOWN, length: 30 },
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
      lines: [{ direction: Direction.LEFT, min_length: 8 }],
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
      lines: [{ direction: Direction.LEFT }],
      buffer: true,
    };
    expect(result).toEqual(expected);
  });

  it("getNoWaitAction returns null when the gesture is filtered buffer local action by min_length", async () => {
    const NeovimClass = jest.fn<Neovim>(() => ({
      call: call,
      buffer: buffer2,
    }));
    const vim = new NeovimClass();

    mapper = new GestureMapper(vim);

    await mapper.initialize();

    const result = await mapper.getNoWaitAction([
      { direction: Direction.UP, length: 7 },
    ]);

    expect(result).toBeNull();
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
