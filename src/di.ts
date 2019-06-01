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

type Deps = {
  Gesture: Gesture;
  GestureBuffer: GestureBuffer;
  GestureMapper: GestureMapper;
  OptionStore: OptionStore;
  WindowOptionsFactory: WindowOptionsFactory;
  InputView: InputView;
  DirectionRecognizer: DirectionRecognizer;
  Reporter: Reporter;
  PointContextFactory: PointContextFactory;
  ConfigRepository: ConfigRepository;
  TabpageRepository: TabpageRepository;
  CursorRepository: CursorRepository;
};

type DepsFuncs = { [P in keyof Deps]: { (vim: Neovim): Deps[P] } };
type DepsCache = { [P in keyof Deps]: Deps[P] | null };
const initDepsCache = (depsFuncs: DepsFuncs): DepsCache => {
  const caches = {} as DepsCache;
  Object.keys(depsFuncs).map(key => {
    caches[key as keyof Deps] = null;
  });
  return caches;
};

export class Di {
  protected static readonly deps: DepsFuncs = {
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

  protected static readonly cache: DepsCache = initDepsCache(Di.deps);

  public static get<ClassName extends keyof Deps>(
    cls: ClassName,
    vim: Neovim,
    cacheable: boolean = true
  ): Deps[ClassName] {
    const cache = this.cache[cls];
    if (cache !== null) {
      // FIXME: needs type assertion from typescript 3.5
      return cache as Deps[ClassName];
    }
    // FIXME: needs type assertion from typescript 3.5
    const resolved = this.deps[cls](vim) as Deps[ClassName];
    if (cacheable) {
      this.cache[cls] = resolved;
    }
    return resolved;
  }

  public static set<ClassName extends keyof Deps>(
    cls: ClassName,
    value: Deps[ClassName]
  ): void {
    this.cache[cls] = value;
  }

  public static clear(): void {
    for (const key of Object.keys(this.deps)) {
      this.cache[key as keyof DepsCache] = null;
    }
  }
}
