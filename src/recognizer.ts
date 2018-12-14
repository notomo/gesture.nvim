import { Neovim, Window, Buffer } from "neovim";
import { Context } from "./command";
import { Logger, getLogger } from "./logger";
import { Point, PointFactory } from "./point";
import { ConfigRepository } from "./repository/config";
import { TabpageRepository } from "./repository/tabpage";
import { Input, InputArgument, InputKind, InputLine, InputText } from "./input";

export class DirectionRecognizer {
  protected readonly inputs: Input[] = [];

  protected lastEdge: Point;
  protected lineStarted: boolean = false;

  protected readonly logger: Logger;

  protected windowId: number | null = null;
  protected readonly windowAndBuffers: [Window, Buffer][] = [];

  constructor(
    protected readonly vim: Neovim,
    protected readonly pointFactory: PointFactory,
    protected readonly tabpageRepository: TabpageRepository,
    protected readonly configRepository: ConfigRepository
  ) {
    this.logger = getLogger("recognizer");
    this.lastEdge = this.pointFactory.createForInitialize();
  }

  public async update(inputArgument: InputArgument) {
    const currentWindow = await this.vim.window;
    const currentWindowId = currentWindow.id;
    if (this.windowId === null || this.windowId !== currentWindowId) {
      this.windowId = currentWindowId;
      const buffer = await currentWindow.buffer;
      this.windowAndBuffers.push([currentWindow, buffer]);
    }

    switch (inputArgument.kind) {
      case InputKind.DIRECTION:
        await this.updateByDirection();
        return;
      case InputKind.TEXT:
        await this.updateByText(inputArgument.value);
        return;
    }
  }

  public getInputs(): ReadonlyArray<Input> {
    return this.inputs.slice();
  }

  public async getContext(): Promise<Context> {
    const windows = this.windowAndBuffers.map(windowAndBuffer => {
      return {
        id: windowAndBuffer[0].id,
        bufferId: windowAndBuffer[1].id,
      };
    });

    return { windows: windows };
  }

  public clear() {
    this.inputs.length = 0;
    this.lineStarted = false;
    this.lastEdge = this.pointFactory.createForInitialize();

    this.windowId = null;
    this.windowAndBuffers.length = 0;
  }

  protected async updateByDirection() {
    const globalPosition = await this.tabpageRepository.getGlobalPosition();
    const point = this.pointFactory.create(globalPosition.x, globalPosition.y);
    if (!this.lineStarted) {
      this.lastEdge = point;
      this.lineStarted = true;
    }

    const info = this.lastEdge.calculate(point);
    if (
      info.direction === null ||
      info.length <
        (await this.configRepository.getMinLengthByDirection(info.direction))
    ) {
      return;
    }

    this.lastEdge = point;

    const lastInputs = this.inputs
      .slice(-1)
      .filter(
        (input): input is InputLine => input.kind === InputKind.DIRECTION
      );
    const newInput: InputLine = {
      kind: InputKind.DIRECTION,
      value: info.direction,
      length: info.length,
    };

    if (
      lastInputs.length === 0 ||
      (lastInputs.length === 1 && lastInputs[0].value !== info.direction)
    ) {
      this.inputs.push(newInput);
      return;
    }

    const newLength = lastInputs.concat([newInput]).reduce((acc, input) => {
      acc += input.length;
      return acc;
    }, 0);
    this.inputs.pop();
    this.inputs.push({
      kind: InputKind.DIRECTION,
      value: newInput.value,
      length: newLength,
    });
  }

  protected async updateByText(value: string) {
    const lastInputs = this.inputs
      .slice(-1)
      .filter((input): input is InputText => input.kind === InputKind.TEXT);
    const newInput: InputText = {
      kind: InputKind.TEXT,
      value: value,
      count: 1,
    };

    if (
      lastInputs.length === 0 ||
      (lastInputs.length === 1 && lastInputs[0].value !== value)
    ) {
      this.inputs.push(newInput);
      return;
    }

    const newCount = lastInputs.concat([newInput]).reduce((acc, input) => {
      acc += input.count;
      return acc;
    }, 0);
    this.inputs.pop();
    this.inputs.push({
      kind: InputKind.TEXT,
      value: newInput.value,
      count: newCount,
    });
  }
}
