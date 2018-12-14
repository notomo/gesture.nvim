import { CommandFactory, Context } from "./command";

describe("CommandFactory", () => {
  let commandFactory: CommandFactory;

  beforeEach(() => {
    commandFactory = new CommandFactory();
  });

  [
    {
      action: { rhs: "gg", noremap: true, silent: false, is_func: false },
      expected: "normal! gg",
    },
    {
      action: { rhs: "gg", noremap: false, silent: false, is_func: false },
      expected: "normal gg",
    },
    {
      action: { rhs: "gg", noremap: false, silent: true, is_func: false },
      expected: "silent normal gg",
    },
    {
      action: { rhs: "", noremap: false, silent: false, is_func: true },
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
      };

      const ContextClass = jest.fn<Context>(() => ({}));
      const context = new ContextClass();

      const result = commandFactory.create(action, context);

      expect(result.command).toEqual(expected);
    });
  });
});
