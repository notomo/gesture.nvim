import { Gesture } from "./gesture";
import { Reporter } from "./reporter";
import { getLogger } from "./logger";
import { Neovim } from "neovim";
import { DirectionRecognizer } from "./recognizer";
import { GestureMapper } from "./mapper";
import { PointFactory } from "./point";

export class Di {
  protected static readonly deps: Deps = {
    Gesture: (vim: Neovim) => {
      const pointFactory = new PointFactory();
      const recognizer = new DirectionRecognizer(pointFactory);
      const mapper = new GestureMapper(vim);
      return new Gesture(vim, recognizer, mapper);
    },
    Reporter: (vim: Neovim) => {
      const logger = getLogger("index");
      return new Reporter(vim, logger);
    },
  };

  protected static readonly cache: DepsCache = {
    Gesture: null,
    Reporter: null,
  };

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
}

type DepsCache = { [P in keyof Deps]: ReturnType<Deps[P]> | null };
