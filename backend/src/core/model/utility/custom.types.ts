/** Custom types to help better improve developer type implementations */
export namespace CustomTypes {
  /**
   * This custom type allows you to get properties of an object of a certain type as strings so you can use them
   *  as parameters for various things like functions or even props of other components.
   *
   * If you want the **static** properties, you can do `PropertyNames<typeof ObjectType, InputType>` instead
   */
  export type PropertyNames<ObjectType, InputType> = {
    [T in keyof ObjectType]: ObjectType[T] extends InputType | undefined ? T : never;
  }[keyof ObjectType] &
    string;

  // Used below to have a maximum depth check
  type Prev = [never, 0, 1, 2, 3, 4, 5, ...0[]];
  /**
   * Defines a type that can deep cycle through a type and return the nested properties prefixed with their path. Has
   *  a maximum depth check of 5.
   *
   * @see https://stackoverflow.com/questions/58434389/typescript-deep-keyof-of-a-nested-object
   */
  export type PropertyPaths<T, D extends number = 5> = [D] extends [never]
    ? never
    : T extends object
      ? {
          [K in keyof T]-?: K extends string | number
            ? `${K}` | (PropertyPaths<T[K], Prev[D]> extends infer Rest ? (Rest extends string | number ? `${K}.${Rest}` : never) : never)
            : never;
        }[keyof T]
      : never;

  export type Constructor<T> = new (...args: any[]) => T;
}
