export type Pretty<T> = {
  [K in keyof T]: T[K]
} & {}

declare global {
  interface BigInt {
    toJSON(): string
  }
}
