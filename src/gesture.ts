import { Neovim } from "neovim";
import { Logger, getLogger } from "./logger";
import { DirectionRecognizer } from "./recognizer";
import { GestureMapper } from "./mapper";
import { GestureBuffer } from "./buffer";
import { Command, CommandFactory } from "./command";

export class Gesture {
  protected readonly logger: Logger;

  constructor(
    protected readonly vim: Neovim,
    protected readonly recognizer: DirectionRecognizer,
    protected readonly mapper: GestureMapper,
    protected readonly gestureBuffer: GestureBuffer,
    protected readonly commandFactory: CommandFactory
  ) {
    this.logger = getLogger("gesture");
  }

  public async execute(): Promise<Command | null> {
    const isValid = await this.gestureBuffer.validate();
    if (!isValid) {
      await this.clear();
      return null;
    }

    const cursor = await this.gestureBuffer.getCursor();
    await this.recognizer.add(cursor.x, cursor.y);

    const gestureLines = this.recognizer.getGestureLines();

    const action = await this.mapper.getNoWaitAction(gestureLines);
    if (action !== null) {
      const context = await this.recognizer.getContext();
      await this.clear();
      return this.commandFactory.create(action, context);
    }

    return null;
  }

  public async finish(): Promise<Command | null> {
    if (!this.gestureBuffer.isStarted) {
      return null;
    }

    const gestureLines = this.recognizer.getGestureLines();

    const action = await this.mapper.getAction(gestureLines);
    if (action !== null) {
      const context = await this.recognizer.getContext();
      await this.clear();
      return this.commandFactory.create(action, context);
    }

    await this.clear();

    return null;
  }

  public async initialize() {
    if (this.gestureBuffer.isStarted) {
      return;
    }

    this.recognizer.clear();
    await this.mapper.initialize();

    await this.gestureBuffer.setup();
  }

  protected async clear() {
    await this.gestureBuffer.restore();
    this.recognizer.clear();
  }
}
