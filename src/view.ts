import { Neovim, Window, Buffer } from "neovim";
import { Input } from "./input";
import { Logger, getLogger } from "./logger";
import { WithError } from "./error";
import { TabpageRepository } from "./repository/tabpage";
import { ConfigRepository } from "./repository/config";
import { GestureMapper } from "./mapper";
import { Action } from "./command";
import { Reporter } from "./reporter";

export class InputView {
  protected window: Window | null = null;

  protected readonly logger: Logger;

  private readonly width = 50;
  private readonly sidePadding = 3;

  constructor(
    private readonly vim: Neovim,
    private readonly viewBufferFactory: ViewBufferFactory,
    private readonly inputLinesFactory: InputLinesFactory,
    private readonly viewWindowFactory: ViewWindowFactory,
    private readonly windowOptionsFactory: WindowOptionsFactory,
    private readonly configRepository: ConfigRepository,
    private readonly mapper: GestureMapper,
    private readonly reporter: Reporter
  ) {
    this.logger = getLogger("view");
  }

  public async render(inputs: ReadonlyArray<Input>) {
    if (
      inputs.length === 0 ||
      !(await this.configRepository.enabledInputView())
    ) {
      return;
    }

    const [buffer, bufErr] = await this.viewBufferFactory.get();
    if (bufErr !== null || buffer === null) {
      this.reporter.error(bufErr);
      return;
    }
    const action = await this.mapper.getAction(inputs);
    const lines = await this.inputLinesFactory.create(
      inputs,
      action,
      this.width,
      this.sidePadding
    );
    await buffer.remove(0, lines.length, false);
    await buffer.setLines(lines, {
      start: 0,
      end: lines.length,
      strictIndexing: false,
    });

    const hasAction = action !== null;
    if (hasAction) {
      await buffer.addHighlight({
        hlGroup: "GestureActionLabel",
        line: lines.length - 1,
      });
    }
    const hasForwardMatch = await this.mapper.hasForwardMatch(inputs);
    const windowOptions = await this.windowOptionsFactory.create(
      lines.length,
      this.width
    );
    if (this.window !== null) {
      await this.vim.windowConfig(this.window, windowOptions);
      if (!hasForwardMatch) {
        await this.window.setOption(
          "winhighlight",
          "NormalFloat:GestureNoAction"
        );
      }
      return;
    }
    const [window, winErr] = await this.viewWindowFactory.create(
      buffer,
      windowOptions
    );
    if (winErr !== null || window === null) {
      this.reporter.error(winErr);
      return;
    }
    this.window = window;
    await this.vim.windowConfig(this.window, windowOptions);
    if (!hasForwardMatch) {
      await this.window.setOption(
        "winhighlight",
        "NormalFloat:GestureNoAction"
      );
    } else {
      await this.window.setOption("winhighlight", "NormalFloat:GestureInput");
    }
  }

  public async destroy() {
    if (this.window === null) {
      return;
    }
    if (await this.window.valid) {
      await this.window.close();
    }
    this.window = null;
  }
}

export const WindowOpenError = {
  name: "WindowOpenError",
  message: "failed to open window",
};

export class ViewWindowFactory {
  constructor(private readonly vim: Neovim) {}

  public async create(
    buffer: Buffer,
    windowOptions: OpenWindowOptions
  ): Promise<WithError<Window | null>> {
    const window = await this.vim.openWindow(buffer, false, windowOptions);
    if (typeof window === "number") {
      return [null, WindowOpenError];
    }

    await window.setOption("list", false);
    return [window, null];
  }
}

export const BufferCreateError = {
  name: "BufferCreateError",
  message: "failed to create buffer",
};

export class ViewBufferFactory {
  protected buffer: Buffer | null = null;

  constructor(private readonly vim: Neovim) {}

  public async get(): Promise<WithError<Buffer | null>> {
    if (this.buffer === null) {
      return this.create();
    }

    const valid = await this.buffer.valid;
    if (valid) {
      return [this.buffer, null];
    }

    return this.create();
  }

  private async create(): Promise<WithError<Buffer | null>> {
    const buffer = await this.vim.createBuffer(false, true);
    if (typeof buffer === "number") {
      return [null, BufferCreateError];
    }
    this.buffer = buffer;
    return [this.buffer, null];
  }
}

export class WindowOptionsFactory {
  constructor(private readonly tabpageRepository: TabpageRepository) {}

  public async create(
    height: number,
    width: number
  ): Promise<OpenWindowOptions> {
    const tabpageSize = await this.tabpageRepository.getSize();
    const centerX = tabpageSize.width / 2 - width / 2;
    const centerY = tabpageSize.height / 2 - height / 2;

    return {
      relative: "editor",
      anchor: "NW",
      focusable: false,
      height: height,
      width: width,
      row: centerY,
      col: centerX,
    };
  }
}

export class InputLinesFactory {
  private readonly separator = " ";

  public create(
    inputs: ReadonlyArray<Input>,
    action: Action | null,
    width: number,
    sidePadding: number
  ): string[] {
    const bothPadding = sidePadding * 2;
    const lines: string[] = [];
    for (const input of inputs) {
      const str = input.value;
      const last = lines.pop();
      if (last == null) {
        lines.push(str);
        continue;
      } else if (
        last.length + this.separator.length + str.length + bothPadding >
        width
      ) {
        lines.push(last);
        lines.push(str);
        continue;
      }
      lines.push(`${last}${this.separator}${str}`);
    }

    const paddingLines: string[] = [];
    for (const line of lines) {
      const remaining = width - line.length;
      const space = " ".repeat(remaining / 2);
      paddingLines.push(`${space}${line}${space}`);
    }
    paddingLines.unshift("");

    if (action === null) {
      paddingLines.push("");
      return paddingLines;
    }

    const name = action.name.length === 0 ? action.rhs : action.name;
    const remaining = width - name.length;
    const space = " ".repeat(remaining > 0 ? remaining / 2 : 0);
    paddingLines.push(`${space}${name}${space}`);

    return paddingLines;
  }
}

interface OpenWindowOptions {
  relative?: "editor" | "win" | "cursor";
  anchor?: "NW" | "NE" | "SW" | "SE";
  focusable?: boolean;
  row?: number;
  col?: number;
  width: number;
  height: number;
}
