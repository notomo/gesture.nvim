import { Direction } from "./direction";

export class Point {
  constructor(public readonly x: number, public readonly y: number) {}

  public calcDistanceInfo(
    point: Point
  ): { distance: number; direction: Direction } {
    const x1 = this.x;
    const x2 = point.x;
    const diffX = x2 - x1;
    const squareDiffX = diffX * diffX;
    const lengthX = Math.abs(diffX);

    const y1 = this.y;
    const y2 = point.y;
    const diffY = y2 - y1;
    const squareDiffY = diffY * diffY;
    const lengthY = Math.abs(diffY);

    const distance = Math.sqrt(squareDiffX + squareDiffY);

    let direction: Direction;
    if (lengthX > lengthY) {
      direction = diffX > 0 ? Direction.RIGHT : Direction.LEFT;
    } else if (lengthY >= lengthX && lengthY > 0) {
      direction = diffY > 0 ? Direction.DOWN : Direction.UP;
    } else {
      direction = Direction.NONE;
    }

    return {
      distance: distance,
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
