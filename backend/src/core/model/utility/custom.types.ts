/** Custom types to help better improve developer type implementations */
export module CustomTypes {
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

  /**
   * Defines a type that can deep cycle through a type and return the nested properties prefixed with their path.
   *
   * @see https://stackoverflow.com/questions/58434389/typescript-deep-keyof-of-a-nested-object
   */
  export type PropertyPaths<T> = T extends object
    ? { [K in keyof T]: `${Exclude<K, symbol>}${PropertyPaths<T[K]> extends never ? "" : `.${PropertyPaths<T[K]>}`}` }[keyof Omit<T, "prototype">]
    : never;

  export type Constructor<T> = new (...args: any[]) => T;
}
