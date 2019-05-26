import { Neovim } from "neovim";
import { Di } from "./di";

describe("Di", () => {
  it("get", () => {
    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({})) as any;
    const vim = new NeovimClass();

    Di.get("Gesture", vim);
    Di.clear();
    Di.get("Gesture", vim);
    Di.clear();
  });
});
