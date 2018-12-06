import { Neovim } from "neovim";
import { GestureMapper } from "./mapper";
import { Direction } from "./direction";

describe("GestureMapper", () => {
  let mapper: GestureMapper;

  let call: jest.Mock;

  beforeEach(() => {
    call = jest
      .fn()
      .mockReturnValue([
        { nowait: false, directions: [Direction.LEFT, Direction.RIGHT] },
        { nowait: true, directions: [Direction.LEFT] },
      ]);
    const NeovimClass = jest.fn<Neovim>(() => ({
      call: call,
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

  it("getNoWaitAction returns null when the gesture does not matched", async () => {
    const result = await mapper.getNoWaitAction([
      { direction: Direction.LEFT, length: 10 },
    ]);

    expect(result).toBeNull();
  });
});
