import { Neovim } from "neovim";
import { Logger, getLogger } from "./logger";
import { DirectionRecognizer } from "./recognizer";
import { GestureMapper } from "./mapper";
import { GestureBuffer } from "./buffer";

export class Gesture {
  protected readonly logger: Logger;

  constructor(
    protected readonly vim: Neovim,
    protected readonly recognizer: DirectionRecognizer,
    protected readonly mapper: GestureMapper,
    protected readonly gestureBuffer: GestureBuffer
  ) {
    this.logger = getLogger("gesture");
  }

  public async execute(): Promise<void> {
    await this.initialize();

    const isValid = await this.gestureBuffer.validate();
    if (!isValid) {
      await this.gestureBuffer.restore();
      return;
    }

    const cursor = await this.gestureBuffer.getCursor();
    this.recognizer.add(cursor.x, cursor.y);
  }

  public async finish(): Promise<void> {
    if (!this.gestureBuffer.isStarted) {
      return;
    }

    await this.gestureBuffer.restore();

    const directions = this.recognizer.getDirections();
    await this.mapper.execute(directions);
  }

  public async initialize() {
    if (this.gestureBuffer.isStarted) {
      return;
    }

    this.recognizer.clear();

    await this.gestureBuffer.setup();
  }
}
