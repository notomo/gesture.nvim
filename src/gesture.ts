import { Neovim } from "neovim";
import { Logger, getLogger } from "./logger";
import { DirectionRecognizer } from "./recognizer";
import { GestureMapper } from "./mapper";
import { GestureBuffer } from "./buffer";
import { Command, CommandFactory } from "./command";
import { GestureLine } from "./line";

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
      await this.gestureBuffer.restore();
      return null;
    }

    const cursor = await this.gestureBuffer.getCursor();
    await this.recognizer.add(cursor.x, cursor.y);

    const gestureLines = this.recognizer.getGestureLines();

    const action = await this.mapper.getNoWaitAction(gestureLines);
    if (action !== null) {
      await this.gestureBuffer.restore();

      const context = await this.recognizer.getContext();
      return this.commandFactory.create(action, context);
    }

    return null;
  }

  public async finish(): Promise<Command | null> {
    if (!this.gestureBuffer.isStarted()) {
      return null;
    }

    const gestureLines = this.recognizer.getGestureLines();

    const action = await this.mapper.getAction(gestureLines);
    let command: Command | null = null;
    if (action !== null) {
      const context = await this.recognizer.getContext();
      command = this.commandFactory.create(action, context);
    }

    await this.gestureBuffer.restore();

    return command;
  }

  public async initialize() {
    if (this.gestureBuffer.isStarted()) {
      return;
    }

    await Promise.all([
      this.recognizer.clear(),
      this.mapper.initialize(),
      this.gestureBuffer.setup(),
    ]);
  }

  public getGestureLines(): ReadonlyArray<GestureLine> {
    if (!this.gestureBuffer.isStarted()) {
      return [];
    }
    return this.recognizer.getGestureLines();
  }
}
