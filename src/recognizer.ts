import { Neovim, Window, Buffer } from "neovim";
import { Direction } from "./direction";
import { GestureLine } from "./line";
import { Context } from "./command";
import { Logger, getLogger } from "./logger";
import { Point, PointFactory } from "./point";
import { ConfigRepository } from "./repository/config";

export class DirectionRecognizer {
  protected readonly points: Point[] = [];
  protected readonly gestureLines: GestureLine[] = [];

  protected lastEdge: Point;
  protected lastDirection: Direction | null = null;
  protected started: boolean = false;

  protected readonly logger: Logger;

  protected windowId: number | null = null;
  protected readonly windowAndBuffers: [Window, Buffer][] = [];

  constructor(
    protected readonly vim: Neovim,
    protected readonly pointFactory: PointFactory,
    protected readonly configRepository: ConfigRepository
  ) {
    this.logger = getLogger("recognizer");
    this.lastEdge = this.pointFactory.createForInitialize();
  }

  public async add(x: number, y: number) {
    const point = this.pointFactory.create(x, y);

    if (!this.started) {
      this.lastEdge = point;
      this.started = true;
    }

    const currentWindow = await this.vim.window;
    const currentWindowId = currentWindow.id;
    if (this.windowId === null || this.windowId !== currentWindowId) {
      this.windowId = currentWindowId;
      const buffer = await currentWindow.buffer;
      this.windowAndBuffers.push([currentWindow, buffer]);
    }

    this.points.push(point);

    const info = this.lastEdge.calculate(point);
    if (
      info.direction === null ||
      info.length <
        (await this.configRepository.getMinLengthByDirection(info.direction))
    ) {
      return;
    }

    this.lastEdge = point;

    const direction = info.direction;
    const gestureLine = this.gestureLines.pop();
    if (gestureLine === undefined || this.lastDirection !== direction) {
      this.lastDirection = direction;
      if (gestureLine !== undefined) {
        this.gestureLines.push(gestureLine);
      }
      this.gestureLines.push({
        direction: info.direction,
        length: info.length,
      });
      return;
    }

    this.gestureLines.push({
      direction: info.direction,
      length: info.length + gestureLine.length,
    });
  }

  public getGestureLines(): ReadonlyArray<GestureLine> {
    return this.gestureLines.slice();
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
    this.points.length = 0;
    this.gestureLines.length = 0;
    this.started = false;
    this.lastDirection = null;
    this.lastEdge = this.pointFactory.createForInitialize();

    this.windowId = null;
    this.windowAndBuffers.length = 0;
  }
}
