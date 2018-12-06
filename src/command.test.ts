import { CommandFactory } from "./command";

describe("CommandFactory", () => {
  let commandFactory: CommandFactory;

  beforeEach(() => {
    commandFactory = new CommandFactory();
  });

  [
    {
      action: { rhs: "gg", noremap: true, silent: false },
      expected: "normal! gg",
    },
    {
      action: { rhs: "gg", noremap: false, silent: false },
      expected: "normal gg",
    },
    {
      action: { rhs: "gg", noremap: false, silent: true },
      expected: "silent normal gg",
    },
  ].forEach(data => {
    const info = data.action;
    const expected = data.expected;

    const json = JSON.stringify(info);
    it(`create ${json}`, () => {
      const action = {
        directions: [],
        nowait: false,
        noremap: info.noremap,
        silent: info.silent,
        rhs: info.rhs,
      };
      const result = commandFactory.create(action);

      expect(result.command).toEqual(expected);
    });
  });
});
