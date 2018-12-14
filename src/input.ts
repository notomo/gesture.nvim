import { Direction } from "./direction";

export enum InputKind {
  DIRECTION = "direction",
  TEXT = "text",
}

export type Input = InputLine | InputText;

export interface InputLine {
  kind: InputKind.DIRECTION;
  value: Direction;
  length: number;
}

export interface InputText {
  kind: InputKind.TEXT;
  value: string;
  count: number;
}

export type InputDefinition = LineInputDefinition | TextInputDefinition;

type LineInputDefinition = {
  kind: InputKind.DIRECTION;
  value: Direction;
  max_length?: number;
  min_length?: number;
};

type TextInputDefinition = {
  kind: InputKind.TEXT;
  value: string;
  max_count?: number;
  min_count?: number;
};

export interface InputLineArgument {
  kind: InputKind.DIRECTION;
  value: null;
}

export interface InputTextArgument {
  kind: InputKind.TEXT;
  value: string;
}

export type InputArgument = InputLineArgument | InputTextArgument;
