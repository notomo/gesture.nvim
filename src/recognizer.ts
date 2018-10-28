import { Direction } from "./direction";
import { Logger, getLogger } from "./logger";

class Point {
  constructor(protected readonly x: number, protected readonly y: number) {}

  public calcDistanceInfo(
    point: Point
  ): { distance: number; direction: Direction } {
    const x1 = this.x;
    const x2 = point.x;
    const a = x2 - x1;
    const squareA = a * a;

    const y1 = this.y;
    const y2 = point.y;
    const b = y2 - y1;
    const squareB = b * b;

    const distance = Math.sqrt(squareA + squareB);

    let direction: Direction;
    if (Math.abs(a) > Math.abs(b)) {
      direction = a > 0 ? Direction.RIGHT : Direction.LEFT;
    } else {
      direction = b > 0 ? Direction.DOWN : Direction.UP;
    }

    return {
      distance: distance,
      direction: direction,
    };
  }
}

export class DirectionRecognizer {
  protected readonly points: Point[] = [];
  protected readonly directions: Direction[] = [];

  protected lastEdge: Point;
  protected lastDirection: Direction | null = null;
  protected started: boolean = false;

  protected readonly lengthThreshold = 10;

  protected readonly logger: Logger;

  constructor() {
    this.logger = getLogger("recognizer");
    this.lastEdge = new Point(-1, -1);
  }

  public add(x: number, y: number) {
    const point = new Point(x, y);

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
    this.lastEdge = new Point(-1, -1);
  }
}
