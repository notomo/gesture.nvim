import { Neovim, Buffer } from "neovim";
import { UndoStore } from "./undo";

export class OptionStore {
  protected virtualEdit: string | null = null;
  protected scrollOff: number | null = null;
  protected sideScrollOff: number | null = null;

  constructor(protected readonly vim: Neovim) {}

  public async restore() {
    if (
      this.virtualEdit === null ||
      this.scrollOff === null ||
      this.sideScrollOff === null
    ) {
      return;
    }

    await Promise.all([
      this.vim.setOption("virtualedit", this.virtualEdit),
      this.vim.setOption("scrolloff", this.scrollOff),
      this.vim.setOption("sidescrolloff", this.sideScrollOff),
    ]);

    this.virtualEdit = null;
    this.scrollOff = null;
    this.sideScrollOff = null;
  }

  public async set() {
    [this.virtualEdit, this.scrollOff, this.sideScrollOff] = await Promise.all([
      this.vim.getOption("virtualedit") as Promise<string>,
      this.vim.getOption("scrolloff") as Promise<number>,
      this.vim.getOption("sidescrolloff") as Promise<number>,
    ]);

    await Promise.all([
      this.vim.setOption("virtualedit", "all"),
      this.vim.setOption("scrolloff", 0),
      this.vim.setOption("sidescrolloff", 0),
    ]);
  }
}

export class BufferOptionStore {
  protected modified: boolean | null = null;

  constructor(
    protected readonly buffer: Buffer,
    protected readonly undoStore: UndoStore
  ) {}

  public async restore() {
    await this.undoStore.restore();

    if (this.modified === null) {
      return;
    }

    await this.buffer.setOption("modified", this.modified);

    this.modified = null;
  }

  public async set() {
    this.modified = (await this.buffer.getOption("modified")) as boolean;

    await this.undoStore.save();
  }
}

export class BufferOptionStoreFactory {
  constructor(protected readonly vim: Neovim) {}

  public create(buffer: Buffer): BufferOptionStore {
    const undoStore = new UndoStore(this.vim, buffer);
    return new BufferOptionStore(buffer, undoStore);
  }
}
