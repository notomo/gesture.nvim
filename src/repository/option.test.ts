import { Neovim } from "neovim";
import { OptionRepository } from "./option";

describe("OptionRepository", () => {
  let vim: Neovim;
  let callAtomic: jest.Mock;

  let optionRepository: OptionRepository;

  beforeEach(() => {
    callAtomic = jest.fn().mockReturnValue([[], []]);
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      callAtomic: callAtomic,
    })) as any;
    vim = new NeovimClass();

    optionRepository = new OptionRepository(vim);
  });

  it("get", async () => {
    await optionRepository.get("columns");

    expect(callAtomic).toHaveBeenCalledWith([["nvim_get_option", ["columns"]]]);
  });

  it("set", async () => {
    await optionRepository.set(["columns", 200]);

    expect(callAtomic).toHaveBeenCalledWith([
      ["nvim_set_option", ["columns", 200]],
    ]);
  });
});
