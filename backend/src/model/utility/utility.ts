/** Utility functions that can be shared across projects */
export class Utility {
  /** Given an array, randomly picks a value from it and returns it. */
  static randomFromArray<T>(array: T[]) {
    return array[Math.floor(Math.random() * array.length)];
  }

  /**
   * Executes a delay that can be used to stop promise execution until the amount of time given
   * @param delay The amount of milliseconds to wait before resolving this promise
   */
  static async delay(delay: number) {
    return await new Promise((f) => setTimeout(f, delay));
  }
}
