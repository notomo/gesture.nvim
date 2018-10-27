import { Neovim } from "neovim";
import { Logger } from "./logger";

export class Reporter {
  constructor(
    protected readonly nvim: Neovim,
    protected readonly logger: Logger
  ) {}

  public async error(error: unknown) {
    if (!this.isError(error)) {
      return;
    }
    this.logger.error(error);

    const message = (error.stack !== undefined ? error.stack : error.message)
      .split("\n")
      .map(line => {
        return "[gesture]" + line;
      })
      .join("\n");

    await this.nvim.errWrite(message).catch(e => this.logger.error(e));
  }

  protected isError(e: any): e is Error {
    return typeof e.name === "string" && typeof e.message === "string";
  }
}
