import { Neovim, Buffer } from "neovim";

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
  protected modifiable: boolean | null = null;
  protected readonly: boolean | null = null;

  constructor(protected readonly buffer: Buffer) {}

  public async restore() {
    if (
      this.modified === null ||
      this.modifiable === null ||
      this.readonly === null
    ) {
      return;
    }

    await Promise.all([
      this.buffer.setOption("modified", this.modified),
      this.buffer.setOption("modifiable", this.modifiable),
      this.buffer.setOption("readonly", this.readonly),
    ]);

    this.modified = null;
    this.modifiable = null;
    this.readonly = null;
  }

  public async set() {
    [this.modified, this.modifiable, this.readonly] = await Promise.all([
      this.buffer.getOption("modified") as Promise<boolean>,
      this.buffer.getOption("modifiable") as Promise<boolean>,
      this.buffer.getOption("readonly") as Promise<boolean>,
    ]);

    await Promise.all([
      this.buffer.setOption("modifiable", true),
      this.buffer.setOption("readonly", false),
    ]);
  }
}

export class BufferOptionStoreFactory {
  public create(buffer: Buffer): BufferOptionStore {
    return new BufferOptionStore(buffer);
  }
}
