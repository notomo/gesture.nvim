import { Reporter } from "./reporter";
import { Neovim } from "neovim";
import { Logger } from "./logger";

describe("Reporter", () => {
  let reporter: Reporter;
  let errWrite: jest.Mock;
  let error: jest.Mock;
  let e: Error;
  const errorName = "errorName";
  const errorMessage = "errorMessage";

  beforeEach(() => {
    errWrite = jest.fn(async () => {});
    const NeovimClass = jest.fn<Neovim>(() => ({
      errWrite: errWrite,
    }));
    const vim = new NeovimClass();

    error = jest.fn();
    const LoggerClass = jest.fn<Logger>(() => ({
      error: error,
    }));
    const logger = new LoggerClass();

    reporter = new Reporter(vim, logger);

    e = {
      name: errorName,
      message: errorMessage,
    };
  });

  it("error does not report if argument is not error", async () => {
    await reporter.error("");

    expect(error).not.toHaveBeenCalled();
    expect(errWrite).not.toHaveBeenCalled();
  });

  it("error report the message if argument is Error", async () => {
    await reporter.error(e);

    expect(error).toHaveBeenCalledWith(e);
    expect(errWrite).toHaveBeenCalledWith("[gesture]" + errorMessage);
  });

  it("error report the stack trace if argument is Error has a stack", async () => {
    const stack = "errorStack";
    const e = {
      name: errorName,
      message: errorMessage,
      stack: stack,
    };
    await reporter.error(e);

    expect(error).toHaveBeenCalledWith(e);
    expect(errWrite).toHaveBeenCalledWith("[gesture]" + stack);
  });

  it("error report vim errWrite's error if vim errWrite throw error", async () => {
    const vimError = {
      name: "vimError",
      message: "vimErrorMessage",
    };
    errWrite.mockImplementation(async () => {
      throw vimError;
    });

    await reporter.error(e);

    expect(error).toHaveBeenCalledWith(e);
    expect(error).toHaveBeenCalledWith(vimError);
  });
});
