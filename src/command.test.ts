import { CommandFactory } from "./command";
import { Context } from "./context";

describe("CommandFactory", () => {
  let commandFactory: CommandFactory;

  beforeEach(() => {
    commandFactory = new CommandFactory();
  });

  [
    {
      action: {
        rhs: "gg",
        noremap: true,
        silent: false,
        is_func: false,
        name: "",
      },
      expected: "normal! gg",
    },
    {
      action: {
        rhs: "gg",
        noremap: false,
        silent: false,
        is_func: false,
        name: "",
      },
      expected: "normal gg",
    },
    {
      action: {
        rhs: "gg",
        noremap: false,
        silent: true,
        is_func: false,
        name: "",
      },
      expected: "silent normal gg",
    },
    {
      action: {
        rhs: "",
        noremap: false,
        silent: false,
        is_func: true,
        name: "",
      },
      expected: "",
    },
  ].forEach(data => {
    const info = data.action;
    const expected = data.expected;

    const json = JSON.stringify(info);
    it(`create ${json}`, () => {
      const action = {
        inputs: [],
        nowait: false,
        noremap: info.noremap,
        silent: info.silent,
        is_func: info.is_func,
        rhs: info.rhs,
        name: info.name,
      };

      const ContextClass: jest.Mock<Context> = jest.fn(() => ({})) as any;
      const context = new ContextClass();

      const result = commandFactory.create(action, context);

      expect(result.command).toEqual(expected);
    });
  });
});
