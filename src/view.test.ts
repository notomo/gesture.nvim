import {
  InputView,
  InputLinesFactory,
  WindowOptionsFactory,
  ViewWindowFactory,
  ViewBufferFactory,
  WindowOpenError,
  BufferCreateError,
} from "./view";
import { Direction } from "./direction";
import { InputKind } from "./input";
import { TabpageRepository } from "./repository/tabpage";
import { ConfigRepository } from "./repository/config";
import { GestureMapper } from "./mapper";
import { Neovim, Buffer, Window } from "neovim";
import { Reporter } from "./reporter";

describe("InputView", () => {
  let vim: Neovim;
  let windowConfig: jest.Mock;

  let remove: jest.Mock;
  let setLines: jest.Mock;
  let addHighlight: jest.Mock;

  let viewBufferFactory: ViewBufferFactory;
  let get: jest.Mock;

  let inputLinesFactory: InputLinesFactory;
  let createLines: jest.Mock;

  let viewWindowFactory: ViewWindowFactory;
  let createWindow: jest.Mock;
  let window: Window;
  let close: jest.Mock;
  let setOption: jest.Mock;

  let windowOptionsFactory: WindowOptionsFactory;
  let createWindowOptions: jest.Mock;
  const options = { height: 10, width: 10 };

  let configRepository: ConfigRepository;
  let enabledInputView: jest.Mock;

  let mapper: GestureMapper;
  let getAction: jest.Mock;

  let reporter: Reporter;
  let error: jest.Mock;

  beforeEach(() => {
    windowConfig = jest.fn();
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      windowConfig: windowConfig,
    })) as any;
    vim = new NeovimClass();

    remove = jest.fn();
    setLines = jest.fn();
    addHighlight = jest.fn();
    const BufferClass: jest.Mock<Buffer> = jest.fn(() => ({
      remove: remove,
      setLines: setLines,
      addHighlight: addHighlight,
    })) as any;
    const buffer = new BufferClass();

    get = jest.fn().mockReturnValue([buffer, null]);
    const ViewBufferFactoryClass: jest.Mock<ViewBufferFactory> = jest.fn(
      () => ({
        get: get,
      })
    ) as any;
    viewBufferFactory = new ViewBufferFactoryClass();

    createLines = jest.fn().mockReturnValue(["", ""]);
    const InputLinesFactoryClass: jest.Mock<InputLinesFactory> = jest.fn(
      () => ({
        create: createLines,
      })
    ) as any;
    inputLinesFactory = new InputLinesFactoryClass();

    close = jest.fn();
    setOption = jest.fn();
    const WindowClass: jest.Mock<Window> = jest.fn(() => ({
      close: close,
      setOption: setOption,
    })) as any;
    window = new WindowClass();

    createWindow = jest.fn().mockReturnValue([window, null]);
    const ViewWindowFactoryClass: jest.Mock<ViewWindowFactory> = jest.fn(
      () => ({
        create: createWindow,
      })
    ) as any;
    viewWindowFactory = new ViewWindowFactoryClass();

    createWindowOptions = jest.fn().mockReturnValue(options);
    const WindowOptionsFactoryClass: jest.Mock<WindowOptionsFactory> = jest.fn(
      () => ({
        create: createWindowOptions,
      })
    ) as any;
    windowOptionsFactory = new WindowOptionsFactoryClass();

    enabledInputView = jest.fn().mockReturnValue(true);
    const ConfigRepositoryClass: jest.Mock<ConfigRepository> = jest.fn(() => ({
      enabledInputView: enabledInputView,
    })) as any;
    configRepository = new ConfigRepositoryClass();

    getAction = jest.fn().mockReturnValue(null);
    const GestureMapperClass: jest.Mock<GestureMapper> = jest.fn(() => ({
      getAction: getAction,
    })) as any;
    mapper = new GestureMapperClass();

    error = jest.fn();
    const ReporterClass: jest.Mock<Reporter> = jest.fn(() => ({
      error: error,
    })) as any;
    reporter = new ReporterClass();
  });

  it("render with empty inputs", async () => {
    const inputView = new InputView(
      vim,
      viewBufferFactory,
      inputLinesFactory,
      viewWindowFactory,
      windowOptionsFactory,
      configRepository,
      mapper,
      reporter
    );
    await inputView.render([]);
    expect(get).not.toHaveBeenCalled();
  });

  it("disabled render", async () => {
    enabledInputView = jest.fn().mockReturnValue(false);
    const ConfigRepositoryClass: jest.Mock<ConfigRepository> = jest.fn(() => ({
      enabledInputView: enabledInputView,
    })) as any;
    configRepository = new ConfigRepositoryClass();

    const inputView = new InputView(
      vim,
      viewBufferFactory,
      inputLinesFactory,
      viewWindowFactory,
      windowOptionsFactory,
      configRepository,
      mapper,
      reporter
    );
    await inputView.render([
      { value: Direction.LEFT, kind: InputKind.DIRECTION, length: 10 },
    ]);
    expect(get).not.toHaveBeenCalled();
  });

  it("render", async () => {
    const inputView = new InputView(
      vim,
      viewBufferFactory,
      inputLinesFactory,
      viewWindowFactory,
      windowOptionsFactory,
      configRepository,
      mapper,
      reporter
    );
    await inputView.render([
      { value: Direction.LEFT, kind: InputKind.DIRECTION, length: 10 },
    ]);

    await inputView.render([
      { value: Direction.LEFT, kind: InputKind.DIRECTION, length: 10 },
    ]);
    expect(createWindow).toHaveBeenCalledTimes(1);
    expect(windowConfig).toHaveBeenCalledWith(window, options);
    expect(windowConfig).toHaveBeenCalledTimes(2);
  });

  it("render with action", async () => {
    const action = {
      inputs: [],
      nowait: false,
      silent: false,
      noremap: false,
      is_func: false,
      rhs: "gg",
    };
    getAction = jest.fn().mockReturnValue(action);
    const GestureMapperClass: jest.Mock<GestureMapper> = jest.fn(() => ({
      getAction: getAction,
    })) as any;
    mapper = new GestureMapperClass();

    const inputView = new InputView(
      vim,
      viewBufferFactory,
      inputLinesFactory,
      viewWindowFactory,
      windowOptionsFactory,
      configRepository,
      mapper,
      reporter
    );
    await inputView.render([
      { value: Direction.LEFT, kind: InputKind.DIRECTION, length: 10 },
    ]);
    expect(addHighlight).toHaveBeenCalled();
  });

  it("render reports buffer error", async () => {
    get = jest.fn().mockReturnValue([null, BufferCreateError]);
    const ViewBufferFactoryClass: jest.Mock<ViewBufferFactory> = jest.fn(
      () => ({
        get: get,
      })
    ) as any;
    viewBufferFactory = new ViewBufferFactoryClass();

    const inputView = new InputView(
      vim,
      viewBufferFactory,
      inputLinesFactory,
      viewWindowFactory,
      windowOptionsFactory,
      configRepository,
      mapper,
      reporter
    );
    await inputView.render([
      { value: Direction.LEFT, kind: InputKind.DIRECTION, length: 10 },
    ]);
    expect(error).toHaveBeenCalledWith(BufferCreateError);
    expect(error).toHaveBeenCalledTimes(1);
  });

  it("render reports window error", async () => {
    createWindow = jest.fn().mockReturnValue([null, WindowOpenError]);
    const ViewWindowFactoryClass: jest.Mock<ViewWindowFactory> = jest.fn(
      () => ({
        create: createWindow,
      })
    ) as any;
    const viewWindowFactory = new ViewWindowFactoryClass();

    const inputView = new InputView(
      vim,
      viewBufferFactory,
      inputLinesFactory,
      viewWindowFactory,
      windowOptionsFactory,
      configRepository,
      mapper,
      reporter
    );
    await inputView.render([
      { value: Direction.LEFT, kind: InputKind.DIRECTION, length: 10 },
    ]);
    expect(error).toHaveBeenCalledWith(WindowOpenError);
    expect(error).toHaveBeenCalledTimes(1);
  });

  it("destroy", async () => {
    const inputView = new InputView(
      vim,
      viewBufferFactory,
      inputLinesFactory,
      viewWindowFactory,
      windowOptionsFactory,
      configRepository,
      mapper,
      reporter
    );
    await inputView.destroy();
    expect(close).not.toHaveBeenCalled();

    await inputView.render([
      { value: Direction.LEFT, kind: InputKind.DIRECTION, length: 10 },
    ]);

    await inputView.destroy();
    await inputView.destroy(); // test do nothing
    expect(close).toHaveBeenCalledTimes(1);
  });
});

describe("ViewBufferFactory", () => {
  it("get valid buffer", async () => {
    const BufferClass: jest.Mock<Buffer> = jest.fn(() => ({
      valid: true,
    })) as any;
    const buffer = new BufferClass();

    const createBuffer = jest.fn().mockReturnValue(buffer);
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      createBuffer: createBuffer,
    })) as any;
    const vim = new NeovimClass();

    const viewBufferFactory = new ViewBufferFactory(vim);

    const [viewBuffer, error] = await viewBufferFactory.get();
    expect(viewBuffer).not.toBeNull();
    expect(error).toBeNull();

    const [viewBuffer2, error2] = await viewBufferFactory.get();
    expect(viewBuffer).toEqual(viewBuffer2);
    expect(error2).toBeNull();
  });

  it("get invalid buffer", async () => {
    const BufferClass: jest.Mock<Buffer> = jest.fn(valid => ({
      valid: valid,
    })) as any;
    const invalidBuffer = new BufferClass(false);
    const validBuffer = new BufferClass(true);

    const createBuffer = jest
      .fn()
      .mockReturnValueOnce(invalidBuffer)
      .mockReturnValueOnce(validBuffer);
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      createBuffer: createBuffer,
    })) as any;
    const vim = new NeovimClass();

    const viewBufferFactory = new ViewBufferFactory(vim);

    const [viewBuffer, error] = await viewBufferFactory.get();
    expect(viewBuffer).not.toBeNull();
    expect(error).toBeNull();

    const [viewBuffer2, error2] = await viewBufferFactory.get();
    expect(viewBuffer2).not.toBeNull();
    expect(viewBuffer).not.toEqual(viewBuffer2);
    expect(error2).toBeNull();
  });

  it("get error", async () => {
    const createBuffer = jest.fn().mockReturnValue(0);
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      createBuffer: createBuffer,
    })) as any;
    const vim = new NeovimClass();

    const viewBufferFactory = new ViewBufferFactory(vim);

    const [viewBuffer, error] = await viewBufferFactory.get();
    expect(viewBuffer).toBeNull();
    expect(error).toEqual(BufferCreateError);
  });
});

describe("ViewWindowFactory", () => {
  let buffer: Buffer;

  const options = {
    height: 10,
    width: 10,
  };

  beforeEach(() => {
    const BufferClass: jest.Mock<Buffer> = jest.fn(() => ({})) as any;
    buffer = new BufferClass();
  });

  it("create", async () => {
    const setOption = jest.fn();
    const WindowClass: jest.Mock<Window> = jest.fn(() => ({
      setOption: setOption,
    })) as any;
    const win = new WindowClass();
    const window = jest.fn().mockImplementation(async () => {
      return win;
    })();

    const openWindow = jest.fn().mockReturnValue(window);
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      openWindow: openWindow,
    })) as any;
    const vim = new NeovimClass();

    const viewWindowFactory = new ViewWindowFactory(vim);

    const [viewWindow, error] = await viewWindowFactory.create(buffer, options);
    expect(viewWindow).not.toBeNull();
    expect(error).toBeNull();
  });

  it("create error", async () => {
    const openWindow = jest.fn().mockReturnValue(0);
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      openWindow: openWindow,
    })) as any;
    const vim = new NeovimClass();

    const viewWindowFactory = new ViewWindowFactory(vim);

    const [viewWindow, error] = await viewWindowFactory.create(buffer, options);
    expect(viewWindow).toBeNull();
    expect(error).toEqual(WindowOpenError);
  });
});

describe("WindowOptionsFactory", () => {
  [
    {
      height: 40,
      width: 50,
      size: { width: 200, height: 100 },
      expected: { col: 75, row: 30 },
    },
  ].forEach(data => {
    const width = data.width;
    const height = data.height;
    const size = data.size;
    const expected = data.expected;
    it(`create`, async () => {
      const getSize = jest.fn().mockReturnValue(size);
      const TabpageRepositoryClass: jest.Mock<TabpageRepository> = jest.fn(
        () => ({
          getSize: getSize,
        })
      ) as any;
      const tabpageRepository = new TabpageRepositoryClass();
      const windowOptionsFactory = new WindowOptionsFactory(tabpageRepository);

      const result = await windowOptionsFactory.create(height, width);

      expect(result.height).toEqual(height);
      expect(result.width).toEqual(width);
      expect(result.row).toEqual(expected.row);
      expect(result.col).toEqual(expected.col);
    });
  });
});

const sidePadding = 3;
describe("InputLinesFactory", () => {
  [
    {
      name: "empty",
      inputs: [],
      action: null,
      expected: ["", ""],
      width: 50,
    },
    {
      name: "one",
      inputs: [
        { value: Direction.LEFT, kind: InputKind.DIRECTION, length: 10 },
      ] as const,
      action: null,
      expected: ["", " ".repeat(6) + "LEFT" + " ".repeat(6), ""],
      width: 6 + 4 + 6,
    },
    {
      name: "one with action",
      inputs: [
        { value: Direction.UP, kind: InputKind.DIRECTION, length: 10 },
      ] as const,
      action: {
        inputs: [],
        nowait: false,
        silent: false,
        noremap: false,
        is_func: false,
        rhs: "gg",
      },
      expected: [
        "",
        " ".repeat(7) + "UP" + " ".repeat(7),
        " ".repeat(7) + "gg" + " ".repeat(7),
      ],
      width: 6 + 4 + 6,
    },
    {
      name: "large action rhs",
      inputs: [
        { value: Direction.UP, kind: InputKind.DIRECTION, length: 10 },
      ] as const,
      action: {
        inputs: [],
        nowait: false,
        silent: false,
        noremap: false,
        is_func: false,
        rhs: "eeeeeeeeeeeeeeee",
      },
      expected: ["", " ".repeat(7) + "UP" + " ".repeat(7), "eeeeeeeeeeeeeeee"],
      width: 6 + 4 + 6,
    },
    {
      name: "two",
      inputs: [
        { value: Direction.LEFT, kind: InputKind.DIRECTION, length: 10 },
        { value: Direction.RIGHT, kind: InputKind.DIRECTION, length: 10 },
      ] as const,
      action: null,
      expected: ["", " ".repeat(21) + "LEFT RIGHT" + " ".repeat(21), ""],
      width: 21 + 10 + 21,
    },
    {
      name: "two lines",
      inputs: [
        { value: Direction.LEFT, kind: InputKind.DIRECTION, length: 10 },
        { value: Direction.RIGHT, kind: InputKind.DIRECTION, length: 10 },
        { value: Direction.LEFT, kind: InputKind.DIRECTION, length: 10 },
      ] as const,
      action: null,
      expected: [
        "",
        " ".repeat(sidePadding) + "LEFT RIGHT" + " ".repeat(sidePadding),
        " ".repeat(sidePadding + 3) + "LEFT" + " ".repeat(sidePadding + 3),
        "",
      ],
      width: sidePadding + 10 + sidePadding,
    },
  ].forEach(data => {
    const inputs = data.inputs;
    const action = data.action;
    const width = data.width;
    const expected = data.expected;
    it(`create ${data.name}`, () => {
      const inputLinesFactory = new InputLinesFactory();
      const result = inputLinesFactory.create(
        inputs,
        action,
        width,
        sidePadding
      );
      expect(result).toEqual(expected);
    });
  });
});
