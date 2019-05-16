import { Neovim } from "neovim";
import { Logger, getLogger } from "./logger";
import { DirectionRecognizer } from "./recognizer";
import { GestureMapper } from "./mapper";
import { GestureBuffer } from "./buffer";
import { Command, CommandFactory } from "./command";
import { Input, InputArgument } from "./input";
import { InputView } from "./view";

export class Gesture {
  protected readonly logger: Logger;

  constructor(
    protected readonly vim: Neovim,
    protected readonly recognizer: DirectionRecognizer,
    protected readonly mapper: GestureMapper,
    protected readonly gestureBuffer: GestureBuffer,
    protected readonly commandFactory: CommandFactory,
    protected readonly inputView: InputView
  ) {
    this.logger = getLogger("gesture");
  }

  public async execute(inputArgument: InputArgument): Promise<Command | null> {
    const isValid = await this.gestureBuffer.validate();
    if (!isValid) {
      await this.inputView.destroy();
      await this.gestureBuffer.restore();
      return null;
    }

    await this.recognizer.update(inputArgument);

    const inputs = this.recognizer.getInputs();

    const action = await this.mapper.getNoWaitAction(inputs);
    if (action !== null) {
      await this.inputView.destroy();
      await this.gestureBuffer.restore();

      const context = await this.recognizer.getContext();
      return this.commandFactory.create(action, context);
    }
    await this.inputView.render(inputs);

    return null;
  }

  public async finish(): Promise<Command | null> {
    if (!this.gestureBuffer.isStarted()) {
      return null;
    }

    const inputs = this.recognizer.getInputs();

    const action = await this.mapper.getAction(inputs);
    let command: Command | null = null;
    if (action !== null) {
      const context = await this.recognizer.getContext();
      command = this.commandFactory.create(action, context);
    }

    await this.inputView.destroy();
    await this.gestureBuffer.restore();

    return command;
  }

  public async initialize(enabledBufferFill: boolean) {
    if (this.gestureBuffer.isStarted()) {
      return;
    }

    await Promise.all([
      this.recognizer.clear(),
      this.mapper.initialize(),
      this.gestureBuffer.setup(enabledBufferFill),
      this.inputView.destroy(),
    ]);
  }

  public getInputs(): ReadonlyArray<Input> {
    if (!this.gestureBuffer.isStarted()) {
      return [];
    }
    return this.recognizer.getInputs();
  }

  public isStarted(): boolean {
    return this.gestureBuffer.isStarted();
  }
}
