import { Neovim, Buffer } from "neovim";
import {
  OptionStore,
  BufferOptionStore,
  BufferOptionStoreFactory,
} from "./option";
import { UndoStore } from "./undo";

describe("OptionStore", () => {
  let optionStore: OptionStore;

  let getOption: jest.Mock;
  let setOption: jest.Mock;

  const virtualedit = "";
  const scrolloff = 8;
  const sidescrolloff = 16;

  beforeEach(() => {
    setOption = jest.fn();
    getOption = jest
      .fn()
      .mockReturnValueOnce(virtualedit)
      .mockReturnValueOnce(scrolloff)
      .mockReturnValueOnce(sidescrolloff);
    const NeovimClass = jest.fn<Neovim>(() => ({
      setOption: setOption,
      getOption: getOption,
    }));
    const vim = new NeovimClass();

    optionStore = new OptionStore(vim);
  });

  it("restore does nothing when options are not stored", async () => {
    await optionStore.restore();

    expect(setOption).not.toHaveBeenCalled();
  });

  it("set and restore", async () => {
    await optionStore.set();

    expect(setOption).toHaveBeenCalledWith("virtualedit", "all");
    expect(setOption).toHaveBeenCalledWith("scrolloff", 0);
    expect(setOption).toHaveBeenCalledWith("sidescrolloff", 0);

    await optionStore.restore();

    expect(setOption).toHaveBeenCalledWith("virtualedit", virtualedit);
    expect(setOption).toHaveBeenCalledWith("scrolloff", scrolloff);
    expect(setOption).toHaveBeenCalledWith("sidescrolloff", sidescrolloff);
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
    const BufferClass = jest.fn<Buffer>(() => ({
      setOption: setOption,
      getOption: getOption,
    }));
    const buffer = new BufferClass();

    save = jest.fn();
    restore = jest.fn();
    const UndoStoreClass = jest.fn<UndoStore>(() => ({
      save: save,
      restore: restore,
    }));
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
    const NeovimClass = jest.fn<Neovim>(() => ({}));
    const vim = new NeovimClass();

    const bufferOptionStoreFactory = new BufferOptionStoreFactory(vim);

    const BufferClass = jest.fn<Buffer>(() => ({}));
    const buffer = new BufferClass();

    bufferOptionStoreFactory.create(buffer);
  });
});
