/**
 * A class that can provide more in-depth typing to the default capabilities included
 *  by Angular
 */
export module AngularCustomTypes {
  /** An improvement upon the `simpleChanges` type for the `onChanges` callback that gives better type safety */
  export type ImprovedChanges<T> = {
    [P in keyof T]?: {
      previousValue: T[P];
      currentValue: T[P];
      firstChange: boolean;
    };
  };
}
