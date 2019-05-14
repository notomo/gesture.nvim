import { Neovim } from "neovim";
import { GestureMapper } from "./mapper";
import { Direction } from "./direction";
import { InputKind } from "./input";

describe("GestureMapper", () => {
  let mapper: GestureMapper;

  let call: jest.Mock;
  let buffer1: jest.Mock;

  let buffer2: jest.Mock;

  beforeEach(() => {
    const BufferClass1: jest.Mock<Buffer> = jest.fn(() => ({
      id: 1,
    })) as any;
    const buf1 = new BufferClass1();

    const BufferClass2: jest.Mock<Buffer> = jest.fn(() => ({
      id: 2,
    })) as any;
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
            inputs: [
              { kind: InputKind.DIRECTION, value: Direction.LEFT },
              { kind: InputKind.DIRECTION, value: Direction.RIGHT },
            ],
          },
        ],
        buffer: {
          2: [
            {
              nowait: false,
              inputs: [
                { kind: InputKind.DIRECTION, value: Direction.LEFT },
                { kind: InputKind.DIRECTION, value: Direction.RIGHT },
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
            inputs: [
              {
                kind: InputKind.DIRECTION,
                value: Direction.LEFT,
                min_length: 8,
              },
            ],
          },
        ],
        buffer: {
          2: [
            {
              nowait: true,
              inputs: [{ kind: InputKind.DIRECTION, value: Direction.LEFT }],
              buffer: true,
            },
          ],
        },
      },
      RIGHT: {
        global: [
          {
            nowait: false,
            inputs: [{ kind: InputKind.DIRECTION, value: Direction.RIGHT }],
          },
        ],
        buffer: {
          2: [
            {
              nowait: false,
              inputs: [{ kind: InputKind.DIRECTION, value: Direction.RIGHT }],
            },
          ],
        },
      },
      DOWN: {
        global: [
          {
            nowait: false,
            inputs: [
              {
                kind: InputKind.DIRECTION,
                value: Direction.DOWN,
                max_length: 20,
              },
            ],
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
              inputs: [
                {
                  kind: InputKind.DIRECTION,
                  value: Direction.UP,
                  min_length: 10,
                },
              ],
            },
          ],
        },
      },
      inputText: {
        global: [
          {
            nowait: false,
            inputs: [
              {
                kind: InputKind.TEXT,
                value: "inputText",
              },
            ],
          },
        ],
        buffer: {},
      },
      inputText2: {
        global: [
          {
            nowait: false,
            inputs: [
              {
                kind: InputKind.TEXT,
                value: "inputText2",
                min_count: 3,
              },
            ],
          },
        ],
        buffer: {},
      },
      inputText3: {
        global: [
          {
            nowait: false,
            inputs: [
              {
                kind: InputKind.TEXT,
                value: "inputText3",
                max_count: 5,
              },
            ],
          },
        ],
        buffer: {},
      },
    });
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      call: call,
      buffer: buffer1,
    })) as any;
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
      { kind: InputKind.DIRECTION, value: Direction.LEFT, length: 10 },
      { kind: InputKind.DIRECTION, value: Direction.RIGHT, length: 10 },
    ]);

    const expected = {
      nowait: false,
      inputs: [
        { kind: InputKind.DIRECTION, value: Direction.LEFT },
        { kind: InputKind.DIRECTION, value: Direction.RIGHT },
      ],
    };
    expect(result).toEqual(expected);
  });

  it("getAction with inputText", async () => {
    await mapper.initialize();

    const result = await mapper.getAction([
      { kind: InputKind.TEXT, value: "inputText", count: 1 },
    ]);

    const expected = {
      nowait: false,
      inputs: [{ kind: InputKind.TEXT, value: "inputText" }],
    };
    expect(result).toEqual(expected);
  });

  it("getAction with inputText returns null when the gesture is filtered by min_count", async () => {
    await mapper.initialize();

    const result = await mapper.getAction([
      { kind: InputKind.TEXT, value: "inputText2", count: 1 },
    ]);

    expect(result).toBeNull();
  });

  it("getAction with inputText returns null when the gesture is filtered by max_count", async () => {
    await mapper.initialize();

    const result = await mapper.getAction([
      { kind: InputKind.TEXT, value: "inputText3", count: 10 },
    ]);

    expect(result).toBeNull();
  });

  it("getAction returns a buffer local action", async () => {
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      call: call,
      buffer: buffer2,
    })) as any;
    const vim = new NeovimClass();

    mapper = new GestureMapper(vim);

    await mapper.initialize();

    const result = await mapper.getAction([
      { kind: InputKind.DIRECTION, value: Direction.LEFT, length: 10 },
      { kind: InputKind.DIRECTION, value: Direction.RIGHT, length: 10 },
    ]);

    const expected = {
      nowait: false,
      inputs: [
        { kind: InputKind.DIRECTION, value: Direction.LEFT },
        { kind: InputKind.DIRECTION, value: Direction.RIGHT },
      ],
      buffer: true,
    };
    expect(result).toEqual(expected);
  });

  it("getAction returns null when the gesture is filtered buffer local action by min_length", async () => {
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      call: call,
      buffer: buffer2,
    })) as any;
    const vim = new NeovimClass();

    mapper = new GestureMapper(vim);

    await mapper.initialize();

    const result = await mapper.getAction([
      { kind: InputKind.DIRECTION, value: Direction.UP, length: 7 },
    ]);

    expect(result).toBeNull();
  });

  it("getAction returns null when the gesture does not matched", async () => {
    const result = await mapper.getAction([
      { kind: InputKind.DIRECTION, value: Direction.LEFT, length: 10 },
    ]);

    expect(result).toBeNull();
  });

  it("getAction returns null when the gesture is filtered by min_length", async () => {
    await mapper.initialize();

    const result = await mapper.getAction([
      { kind: InputKind.DIRECTION, value: Direction.LEFT, length: 7 },
    ]);

    expect(result).toBeNull();
  });

  it("getAction returns null when the gesture is filtered by max_length", async () => {
    await mapper.initialize();

    const result = await mapper.getAction([
      { kind: InputKind.DIRECTION, value: Direction.DOWN, length: 30 },
    ]);

    expect(result).toBeNull();
  });

  it("getNoWaitAction", async () => {
    await mapper.initialize();

    const result = await mapper.getNoWaitAction([
      { kind: InputKind.DIRECTION, value: Direction.LEFT, length: 10 },
    ]);

    const expected = {
      nowait: true,
      inputs: [
        { kind: InputKind.DIRECTION, value: Direction.LEFT, min_length: 8 },
      ],
    };
    expect(result).toEqual(expected);
  });

  it("getNoWaitAction returns a buffer local action", async () => {
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      call: call,
      buffer: buffer2,
    })) as any;
    const vim = new NeovimClass();

    mapper = new GestureMapper(vim);

    await mapper.initialize();

    const result = await mapper.getNoWaitAction([
      { kind: InputKind.DIRECTION, value: Direction.LEFT, length: 10 },
    ]);

    const expected = {
      nowait: true,
      inputs: [{ kind: InputKind.DIRECTION, value: Direction.LEFT }],
      buffer: true,
    };
    expect(result).toEqual(expected);
  });

  it("getNoWaitAction returns null when the gesture is filtered buffer local action by min_length", async () => {
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      call: call,
      buffer: buffer2,
    })) as any;
    const vim = new NeovimClass();

    mapper = new GestureMapper(vim);

    await mapper.initialize();

    const result = await mapper.getNoWaitAction([
      { kind: InputKind.DIRECTION, value: Direction.UP, length: 7 },
    ]);

    expect(result).toBeNull();
  });

  it("getNoWaitAction returns null when the gesture does not matched", async () => {
    const result = await mapper.getNoWaitAction([
      { kind: InputKind.DIRECTION, value: Direction.LEFT, length: 10 },
    ]);

    expect(result).toBeNull();
  });

  it("getNoWaitAction returns null when the gesture does not matched nowait", async () => {
    await mapper.initialize();

    const result = await mapper.getNoWaitAction([
      { kind: InputKind.DIRECTION, value: Direction.RIGHT, length: 10 },
    ]);

    expect(result).toBeNull();
  });
});
