import { Neovim, Buffer, Window } from "neovim";

export class UndoStore {
  protected undoFile: string | null = null;

  constructor(
    protected readonly vim: Neovim,
    protected readonly buffer: Buffer
  ) {}

  protected async getTargetWindow(): Promise<Window | null> {
    for (const window of await this.vim.windows) {
      const bufferId = await window.buffer.id;
      if (bufferId === this.buffer.id) {
        return window;
      }
    }

    return null;
  }

  public async save() {
    const targetWindow = await this.getTargetWindow();
    if (targetWindow === null) {
      return;
    }

    const currentWindow = await this.vim.window;

    await this.vim.setWindow(targetWindow);

    this.undoFile = (await this.vim.call("tempname")) as string;
    await this.vim.command("wundo " + this.undoFile);

    await this.clearUndo();

    await this.vim.setWindow(currentWindow);
  }

  public async restore() {
    const targetWindow = await this.getTargetWindow();
    if (targetWindow === null) {
      return;
    }

    const currentWindow = await this.vim.window;
    const currentCursor = await currentWindow.cursor;

    await this.vim.setWindow(targetWindow);

    const modifiable = (await this.buffer.getOption("modifiable")) as boolean;
    if (modifiable) {
      await this.vim.command("keepjump silent undo");
    }
    if (this.undoFile !== null) {
      await this.restoreFromUndoFile(this.undoFile);
    }

    await this.vim.setWindow(currentWindow);
    await (currentWindow.cursor = currentCursor);
  }

  protected async restoreFromUndoFile(undoFile: string) {
    const readable = (await this.vim.call("filereadable", undoFile)) as boolean;
    if (!readable) {
      await this.clearUndo();
      return;
    }

    await this.vim.command("silent rundo " + this.undoFile);
  }

  protected async clearUndo() {
    const modifiable = (await this.buffer.getOption("modifiable")) as boolean;
    if (!modifiable) {
      return;
    }
    const undolevels = (await this.vim.call(
      "gesture#get_undolevels",
      this.buffer.id
    )) as number;
    await this.buffer.setOption("undolevels", -1);
    await this.vim.command('noautocmd execute "normal! A \\<BS>\\<Esc>"');
    await this.buffer.setOption("undolevels", undolevels);
  }
}
