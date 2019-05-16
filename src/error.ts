export type WithError<T> = [T, NullableError];
export type NullableError = Error | null;
