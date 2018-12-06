import { Point, PointFactory } from "./point";
import { Direction } from "./direction";

describe("Point", () => {
  [
    {
      x: 1,
      y: 1,
      targetX: 1,
      targetY: 1,
      expected: { direction: Direction.NONE, length: 0 },
    },
    {
      x: 1,
      y: 1,
      targetX: 2,
      targetY: 1,
      expected: { direction: Direction.RIGHT, length: 1 },
    },
    {
      x: 1,
      y: 1,
      targetX: 1,
      targetY: 2,
      expected: { direction: Direction.DOWN, length: 1 },
    },
    {
      x: 4,
      y: 2,
      targetX: 2,
      targetY: 2,
      expected: { direction: Direction.LEFT, length: 2 },
    },
    {
      x: 2,
      y: 4,
      targetX: 2,
      targetY: 2,
      expected: { direction: Direction.UP, length: 2 },
    },
    {
      x: 4,
      y: 4,
      targetX: 2,
      targetY: 2,
      expected: { direction: Direction.UP, length: 2 },
    },
  ].forEach(data => {
    const constructorArgs = [data.x, data.y];
    const calcArgs = [data.targetX, data.targetY];
    let expected = data.expected;
    it(`calc "${constructorArgs}" to "${calcArgs}"`, () => {
      const point = new Point(data.x, data.y);
      const result = point.calculate(new Point(data.targetX, data.targetY));
      expect(result).toEqual(expected);
    });
  });
});

describe("PointFactory", () => {
  let pointFactory: PointFactory;

  beforeEach(() => {
    pointFactory = new PointFactory();
  });

  it("create", () => {
    const x = 1;
    const y = 2;
    const point = pointFactory.create(x, y);
    expect(point.x).toEqual(x);
    expect(point.y).toEqual(y);
  });

  it("create", () => {
    const point = pointFactory.createForInitialize();
    expect(point.x).toEqual(-1);
    expect(point.y).toEqual(-1);
  });
});
