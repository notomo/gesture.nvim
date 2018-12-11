import { Gesture } from "./gesture";
import { Reporter } from "./reporter";
import { getLogger } from "./logger";
import { Neovim } from "neovim";
import { DirectionRecognizer } from "./recognizer";
import { GestureMapper } from "./mapper";
import { PointFactory } from "./point";
import { GestureBuffer } from "./buffer";
import { OptionStore, BufferOptionStoreFactory } from "./option";
import { CommandFactory } from "./command";
import { ConfigRepository } from "./repository/config";

export class Di {
  protected static readonly deps: Deps = {
    Gesture: (vim: Neovim) => {
      const pointFactory = new PointFactory();
      const configRepository = Di.get("ConfigRepository", vim);
      const recognizer = new DirectionRecognizer(
        vim,
        pointFactory,
        configRepository
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
      return new Gesture(
        vim,
        recognizer,
        mapper,
        gestureBuffer,
        commandFactory
      );
    },
    Reporter: (vim: Neovim) => {
      const logger = getLogger("index");
      return new Reporter(vim, logger);
    },
    ConfigRepository: (vim: Neovim) => {
      return new ConfigRepository(vim);
    },
  };

  protected static readonly cache: DepsCache = {
    Gesture: null,
    Reporter: null,
    ConfigRepository: null,
  };

  public static get(cls: "ConfigRepository", vim: Neovim): ConfigRepository;
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
  ConfigRepository: { (vim: Neovim): ConfigRepository };
}

type DepsCache = { [P in keyof Deps]: ReturnType<Deps[P]> | null };
