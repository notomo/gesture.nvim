import { Direction } from "./direction";
import { Logger, getLogger } from "./logger";
import { Point, PointFactory } from "./point";

export class DirectionRecognizer {
  protected readonly points: Point[] = [];
  protected readonly directions: Direction[] = [];

  protected lastEdge: Point;
  protected lastDirection: Direction | null = null;
  protected started: boolean = false;

  protected readonly lengthThreshold = 10;

  protected readonly logger: Logger;

  constructor(protected readonly pointFactory: PointFactory) {
    this.logger = getLogger("recognizer");
    this.lastEdge = this.pointFactory.createForInitialize();
  }

  public add(x: number, y: number) {
    const point = this.pointFactory.create(x, y);

    if (!this.started) {
      this.lastEdge = point;
      this.started = true;
    }

    this.points.push(point);

    const info = this.lastEdge.calcDistanceInfo(point);
    if (info.distance >= this.lengthThreshold) {
      this.lastEdge = point;

      const direction = info.direction;
      if (this.lastDirection !== direction) {
        this.lastDirection = direction;
        this.directions.push(direction);
      }
    }
  }

  public getDirections(): Direction[] {
    return this.directions;
  }

  public clear() {
    this.points.length = 0;
    this.directions.length = 0;
    this.started = false;
    this.lastDirection = null;
    this.lastEdge = this.pointFactory.createForInitialize();
  }
}
