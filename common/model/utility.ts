/** Utility functions that can be shared across projects */
export class Utility {
  /** Given an array, randomly picks a value from it and returns it. */
  static randomFromArray<T>(array: T[]) {
    return array[Math.floor(Math.random() * array.length)];
  }
}
