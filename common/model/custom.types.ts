/** Custom types to help better improve developer type implementations */
export module CustomTypes {
  export type Constructor<T> = new (...args: any[]) => T;
}
