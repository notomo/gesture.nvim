import { PointContextFactory } from "./context";
import { CursorRepository } from "./repository/cursor";
import { Neovim, Window } from "neovim";

describe("PointContextFactory", () => {
  const row = 1;
  const column = 2;
  const text = "text";

  it("create", async () => {
    const WindowClass: jest.Mock<Window> = jest.fn(() => ({
      cursor: [row, column],
    })) as any;
    const win = new WindowClass();
    const window = jest.fn().mockImplementation(async () => {
      return win;
    })();

    const call = jest.fn().mockReturnValue(text);
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      window: window,
      call: call,
    })) as any;
    const vim = new NeovimClass();

    const getVirtualColumn = jest.fn().mockReturnValue(column);
    const getWord = jest.fn().mockReturnValue(text);
    const CursorRepositoryClass: jest.Mock<CursorRepository> = jest.fn(() => ({
      getVirtualColumn: getVirtualColumn,
      getWord: getWord,
    })) as any;
    const cursorRepository = new CursorRepositoryClass();

    const pointContextFactory = new PointContextFactory(vim, cursorRepository);
    const result = await pointContextFactory.create();

    expect(result).toEqual({
      row: row,
      column: column,
      text: text,
    });
  });
});
