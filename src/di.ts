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

export class Di {
  protected static readonly deps: Deps = {
    Gesture: (vim: Neovim) => {
      const pointFactory = new PointFactory();
      const configRepository = Di.get("ConfigRepository", vim);
      const tabpageRepository = new TabpageRepository(vim);
      const pointContextFactory = Di.get("PointContextFactory", vim);
      const recognizer = new DirectionRecognizer(
        vim,
        pointFactory,
        tabpageRepository,
        configRepository,
        pointContextFactory
      );
      const mapper = new GestureMapper(vim);
      const optionStore = new OptionStore(vim);
      const bufferOptionStoreFactory = new BufferOptionStoreFactory(vim);
      const commandFactory = new CommandFactory();
      const gestureBuffer = new GestureBuffer(
        vim,
        optionStore,
        bufferOptionStoreFactory
      );
      const viewBufferFactory = new ViewBufferFactory(vim);
      const inputLinesFactory = new InputLinesFactory();
      const viewWindowFactory = new ViewWindowFactory(vim);
      const windowOptionsFactory = new WindowOptionsFactory(tabpageRepository);
      const reporter = Di.get("Reporter", vim);
      const inputView = new InputView(
        vim,
        viewBufferFactory,
        inputLinesFactory,
        viewWindowFactory,
        windowOptionsFactory,
        configRepository,
        reporter
      );
      return new Gesture(
        vim,
        recognizer,
        mapper,
        gestureBuffer,
        commandFactory,
        inputView
      );
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
    CursorRepository: (vim: Neovim) => {
      return new CursorRepository(vim);
    },
  };

  protected static readonly cache: DepsCache = {
    Gesture: null,
    Reporter: null,
    PointContextFactory: null,
    ConfigRepository: null,
    CursorRepository: null,
  };

  public static get(cls: "CursorRepository", vim: Neovim): CursorRepository;
  public static get(cls: "ConfigRepository", vim: Neovim): ConfigRepository;
  public static get(
    cls: "PointContextFactory",
    vim: Neovim
  ): PointContextFactory;
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
  Reporter: { (vim: Neovim): Reporter };
  PointContextFactory: { (vim: Neovim): PointContextFactory };
  ConfigRepository: { (vim: Neovim): ConfigRepository };
  CursorRepository: { (vim: Neovim): CursorRepository };
}

type DepsCache = { [P in keyof Deps]: ReturnType<Deps[P]> | null };
