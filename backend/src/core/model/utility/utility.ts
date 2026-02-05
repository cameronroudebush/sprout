/** Utility functions that can be shared across projects */
export class Utility {
  /** Given an array, randomly picks a value from it and returns it. */
  static randomFromArray<T>(array: T[]) {
    return array[Math.floor(Math.random() * array.length)]!;
  }

  /**
   * Executes a delay that can be used to stop promise execution until the amount of time given
   * @param delay The amount of milliseconds to wait before resolving this promise
   */
  static async delay(delay: number) {
    return await new Promise((f) => setTimeout(f, delay));
  }

  /**
   * Shuffles an array in place using the Fisher-Yates algorithm.
   * @param array The array to shuffle
   * @returns The same array instance, shuffled
   */
  static shuffleArray<T>(array: T[]): T[] {
    let currentIndex = array.length;
    let randomIndex;

    // While there remain elements to shuffle...
    while (currentIndex !== 0) {
      // Pick a remaining element...
      randomIndex = Math.floor(Math.random() * currentIndex);
      currentIndex--;

      // And swap it with the current element.
      [array[currentIndex] as any, array[randomIndex] as any] = [array[randomIndex], array[currentIndex]];
    }

    return array;
  }
}
