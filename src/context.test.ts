import { PointContextFactory } from "./context";
import { CursorRepository } from "./repository/cursor";
import { Neovim, Window } from "neovim";

describe("PointContextFactory", () => {
  const row = 1;
  const column = 2;
  const text = "text";

  it("create", async () => {
    const WindowClass = jest.fn<Window>(() => ({
      cursor: [row, column],
    }));
    const win = new WindowClass();
    const window = jest.fn().mockImplementation(async () => {
      return win;
    })();

    const call = jest.fn().mockReturnValue(text);
    const NeovimClass = jest.fn<Neovim>(() => ({
      window: window,
      call: call,
    }));
    const vim = new NeovimClass();

    const getVirtualColumn = jest.fn().mockReturnValue(column);
    const getWord = jest.fn().mockReturnValue(text);
    const CursorRepositoryClass = jest.fn<CursorRepository>(() => ({
      getVirtualColumn: getVirtualColumn,
      getWord: getWord,
    }));
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
