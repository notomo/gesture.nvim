import { Neovim } from "neovim";
import { CursorRepository } from "./cursor";

describe("CursorRepository", () => {
  let call: jest.Mock;

  let cursorRepository: CursorRepository;

  beforeEach(() => {
    call = jest.fn();
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      call: call,
    })) as any;
    const vim = new NeovimClass();

    cursorRepository = new CursorRepository(vim);
  });

  it("getVirtualColumn", async () => {
    await cursorRepository.getVirtualColumn();

    expect(call).toHaveBeenCalledWith("virtcol", ".");
  });

  it("getWord", async () => {
    await cursorRepository.getWord();

    expect(call).toHaveBeenCalledWith("expand", "<cword>");
  });
});
