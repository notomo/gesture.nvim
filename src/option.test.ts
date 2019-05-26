import { Neovim, Buffer } from "neovim";
import {
  OptionStore,
  BufferOptionStore,
  BufferOptionStoreFactory,
} from "./option";
import { UndoStore } from "./undo";
import { OptionRepository } from "./repository/option";

describe("OptionStore", () => {
  let optionRepository: OptionRepository;

  let optionStore: OptionStore;

  let setOption: jest.Mock;
  let getOption: jest.Mock;

  const virtualedit = "";
  const scrolloff = 8;
  const sidescrolloff = 16;

  beforeEach(() => {
    setOption = jest.fn();
    getOption = jest
      .fn()
      .mockReturnValueOnce([virtualedit, scrolloff, sidescrolloff]);
    const OptionRepositoryClass: jest.Mock<OptionRepository> = jest.fn(() => ({
      set: setOption,
      get: getOption,
    })) as any;
    optionRepository = new OptionRepositoryClass();

    optionStore = new OptionStore(optionRepository);
  });

  it("restore does nothing when options are not stored", async () => {
    await optionStore.restore();

    expect(setOption).not.toHaveBeenCalled();
  });

  it("set and restore", async () => {
    await optionStore.set();

    expect(setOption).toHaveBeenCalledWith(
      ["virtualedit", "all"],
      ["scrolloff", 0],
      ["sidescrolloff", 0]
    );

    await optionStore.restore();

    expect(setOption).toHaveBeenCalledWith(
      ["virtualedit", virtualedit],
      ["scrolloff", scrolloff],
      ["sidescrolloff", sidescrolloff]
    );
  });
});

describe("BufferOptionStore", () => {
  let bufferOptionStore: BufferOptionStore;

  let getOption: jest.Mock;
  let setOption: jest.Mock;

  const modified = true;

  let save: jest.Mock;
  let restore: jest.Mock;

  beforeEach(() => {
    setOption = jest.fn();
    getOption = jest.fn().mockReturnValueOnce(modified);
    const BufferClass: jest.Mock<Buffer> = jest.fn(() => ({
      setOption: setOption,
      getOption: getOption,
    })) as any;
    const buffer = new BufferClass();

    save = jest.fn();
    restore = jest.fn();
    const UndoStoreClass: jest.Mock<UndoStore> = jest.fn(() => ({
      save: save,
      restore: restore,
    })) as any;
    const undoStore = new UndoStoreClass();

    bufferOptionStore = new BufferOptionStore(buffer, undoStore);
  });

  it("restore does not set option when options are not stored", async () => {
    await bufferOptionStore.restore();

    expect(restore).toHaveBeenCalled();
    expect(setOption).not.toHaveBeenCalled();
  });

  it("set and restore", async () => {
    await bufferOptionStore.set();

    expect(save).toHaveBeenCalled();

    await bufferOptionStore.restore();

    expect(restore).toHaveBeenCalled();
    expect(setOption).toHaveBeenCalledWith("modified", modified);
  });
});

describe("BufferOptionStoreFactory", () => {
  it("create", () => {
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({})) as any;
    const vim = new NeovimClass();

    const bufferOptionStoreFactory = new BufferOptionStoreFactory(vim);

    const BufferClass: jest.Mock<Buffer> = jest.fn(() => ({})) as any;
    const buffer = new BufferClass();

    bufferOptionStoreFactory.create(buffer);
  });
});
