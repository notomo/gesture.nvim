import { Gesture } from "./gesture";
import { Reporter } from "./reporter";
import { getLogger } from "./logger";
import { Neovim } from "neovim";
import { DirectionRecognizer } from "./recognizer";
import { GestureMapper } from "./mapper";
import { PointFactory } from "./point";
import { GestureBuffer } from "./buffer";
import {
  InputView,
  ViewBufferFactory,
  ViewWindowFactory,
  InputLinesFactory,
  WindowOptionsFactory,
} from "./view";
import { OptionStore, BufferOptionStoreFactory } from "./option";
import { CommandFactory } from "./command";
import { PointContextFactory } from "./context";
import { ConfigRepository } from "./repository/config";
import { CursorRepository } from "./repository/cursor";
import { TabpageRepository } from "./repository/tabpage";
import { OptionRepository } from "./repository/option";

export class Di {
  protected static readonly deps: Deps = {
    Gesture: (vim: Neovim) => {
      const recognizer = Di.get("DirectionRecognizer", vim);
      const mapper = Di.get("GestureMapper", vim);
      const commandFactory = new CommandFactory();
      const gestureBuffer = Di.get("GestureBuffer", vim);
      const inputView = Di.get("InputView", vim);
      return new Gesture(
        vim,
        recognizer,
        mapper,
        gestureBuffer,
        commandFactory,
        inputView
      );
    },
    InputView: (vim: Neovim) => {
      const viewBufferFactory = new ViewBufferFactory(vim);
      const inputLinesFactory = new InputLinesFactory();
      const viewWindowFactory = new ViewWindowFactory(vim);
      const windowOptionsFactory = Di.get("WindowOptionsFactory", vim);
      const configRepository = Di.get("ConfigRepository", vim);
      const mapper = Di.get("GestureMapper", vim);
      const reporter = Di.get("Reporter", vim);
      return new InputView(
        vim,
        viewBufferFactory,
        inputLinesFactory,
        viewWindowFactory,
        windowOptionsFactory,
        configRepository,
        mapper,
        reporter
      );
    },
    GestureBuffer: (vim: Neovim) => {
      const optionStore = Di.get("OptionStore", vim, false);
      const bufferOptionStoreFactory = new BufferOptionStoreFactory(vim);
      return new GestureBuffer(vim, optionStore, bufferOptionStoreFactory);
    },
    DirectionRecognizer: (vim: Neovim) => {
      const pointFactory = new PointFactory();
      const configRepository = Di.get("ConfigRepository", vim);
      const tabpageRepository = Di.get("TabpageRepository", vim);
      const pointContextFactory = Di.get("PointContextFactory", vim);
      return new DirectionRecognizer(
        vim,
        pointFactory,
        tabpageRepository,
        configRepository,
        pointContextFactory
      );
    },
    GestureMapper: (vim: Neovim) => {
      return new GestureMapper(vim);
    },
    OptionStore: (vim: Neovim) => {
      const optionRepository = new OptionRepository(vim);
      return new OptionStore(optionRepository);
    },
    WindowOptionsFactory: (vim: Neovim) => {
      const tabpageRepository = Di.get("TabpageRepository", vim);
      return new WindowOptionsFactory(tabpageRepository);
    },
    Reporter: (vim: Neovim) => {
      const logger = getLogger("index");
      return new Reporter(vim, logger);
    },
    PointContextFactory: (vim: Neovim) => {
      const cursorRepository = Di.get("CursorRepository", vim);
      return new PointContextFactory(vim, cursorRepository);
    },
    ConfigRepository: (vim: Neovim) => {
      return new ConfigRepository(vim);
    },
    TabpageRepository: (vim: Neovim) => {
      return new TabpageRepository(vim);
    },
    CursorRepository: (vim: Neovim) => {
      return new CursorRepository(vim);
    },
  };

  protected static readonly cache: DepsCache = {
    Gesture: null,
    GestureBuffer: null,
    GestureMapper: null,
    OptionStore: null,
    WindowOptionsFactory: null,
    InputView: null,
    DirectionRecognizer: null,
    Reporter: null,
    PointContextFactory: null,
    ConfigRepository: null,
    TabpageRepository: null,
    CursorRepository: null,
  };

  public static get(cls: "CursorRepository", vim: Neovim): CursorRepository;
  public static get(cls: "TabpageRepository", vim: Neovim): TabpageRepository;
  public static get(cls: "ConfigRepository", vim: Neovim): ConfigRepository;
  public static get(
    cls: "PointContextFactory",
    vim: Neovim
  ): PointContextFactory;
  public static get(cls: "GestureBuffer", vim: Neovim): GestureBuffer;
  public static get(cls: "GestureMapper", vim: Neovim): GestureMapper;
  public static get(
    cls: "OptionStore",
    vim: Neovim,
    cacheable: false
  ): OptionStore;
  public static get(
    cls: "WindowOptionsFactory",
    vim: Neovim
  ): WindowOptionsFactory;
  public static get(cls: "InputView", vim: Neovim): InputView;
  public static get(
    cls: "DirectionRecognizer",
    vim: Neovim
  ): DirectionRecognizer;
  public static get(cls: "Reporter", vim: Neovim): Reporter;
  public static get(cls: "Gesture", vim: Neovim): Gesture;
  public static get(
    cls: keyof Deps,
    vim: Neovim,
    cacheable: boolean = true
  ): ReturnType<Deps[keyof Deps]> {
    const cache = this.cache[cls];
    if (cache !== null) {
      return cache;
    }
    const resolved = this.deps[cls](vim);
    if (cacheable) {
      this.cache[cls] = resolved;
    }
    return resolved;
  }

  public static set(
    cls: keyof Deps,
    value: ReturnType<Deps[keyof Deps]>
  ): void {
    this.cache[cls] = value;
  }

  public static clear(): void {
    for (const key of Object.keys(this.deps)) {
      this.cache[key as keyof DepsCache] = null;
    }
  }
}

interface Deps {
  Gesture: { (vim: Neovim): Gesture };
  GestureBuffer: { (vim: Neovim): GestureBuffer };
  GestureMapper: { (vim: Neovim): GestureMapper };
  OptionStore: { (vim: Neovim): OptionStore };
  WindowOptionsFactory: { (vim: Neovim): WindowOptionsFactory };
  InputView: { (vim: Neovim): InputView };
  DirectionRecognizer: { (vim: Neovim): DirectionRecognizer };
  Reporter: { (vim: Neovim): Reporter };
  PointContextFactory: { (vim: Neovim): PointContextFactory };
  ConfigRepository: { (vim: Neovim): ConfigRepository };
  TabpageRepository: { (vim: Neovim): TabpageRepository };
  CursorRepository: { (vim: Neovim): CursorRepository };
}

type DepsCache = { [P in keyof Deps]: ReturnType<Deps[P]> | null };
