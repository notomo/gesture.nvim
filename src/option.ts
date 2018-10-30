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
    this.virtualEdit = (await this.vim.getOption("virtualedit")) as string;
    this.scrollOff = (await this.vim.getOption("scrolloff")) as number;
    this.sideScrollOff = (await this.vim.getOption("sidescrolloff")) as number;

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
    this.modified = (await this.buffer.getOption("modified")) as boolean;
    this.modifiable = (await this.buffer.getOption("modifiable")) as boolean;
    this.readonly = (await this.buffer.getOption("readonly")) as boolean;

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
