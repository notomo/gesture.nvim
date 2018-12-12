import { Neovim } from "neovim";
import { Direction } from "../direction";
import { ConfigRepository } from "./config";

describe("ConfigRepository", () => {
  [
    { expected: "y_length_threshold", direction: Direction.DOWN },
    { expected: "y_length_threshold", direction: Direction.UP },
    { expected: "x_length_threshold", direction: Direction.LEFT },
    { expected: "x_length_threshold", direction: Direction.RIGHT },
  ].forEach(data => {
    it(`getMinLengthByDirection with ${data.direction}`, async () => {
      const call = jest.fn();

      const NeovimClass = jest.fn<Neovim>(() => ({
        call: call,
      }));
      const vim = new NeovimClass();

      const configRepository = new ConfigRepository(vim);

      await configRepository.getMinLengthByDirection(data.direction);

      expect(call).toHaveBeenCalledWith("gesture#custom#get", data.expected);
    });
  });
});
