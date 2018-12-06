import { Direction } from "./direction";

export class Point {
  constructor(public readonly x: number, public readonly y: number) {}

  public calculate(point: Point): { length: number; direction: Direction } {
    const x1 = this.x;
    const x2 = point.x;
    const diffX = x2 - x1;
    const lengthX = Math.abs(diffX);

    const y1 = this.y;
    const y2 = point.y;
    const diffY = y2 - y1;
    const lengthY = Math.abs(diffY);

    let direction: Direction;
    let length: number;
    if (lengthX > lengthY) {
      direction = diffX > 0 ? Direction.RIGHT : Direction.LEFT;
      length = lengthX;
    } else if (lengthY >= lengthX && lengthY > 0) {
      direction = diffY > 0 ? Direction.DOWN : Direction.UP;
      length = lengthY;
    } else {
      direction = Direction.NONE;
      length = 0;
    }

    return {
      length: length,
      direction: direction,
    };
  }
}

export class PointFactory {
  public create(x: number, y: number): Point {
    return new Point(x, y);
  }

  public createForInitialize(): Point {
    return new Point(-1, -1);
  }
}
