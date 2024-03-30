import { plainToInstance } from "class-transformer";
import { CustomTypes } from "./custom.types";

/** The base class to every model of this application that provides generic capabilities */
export class Base {
  /** Creates an instance of `this` from the given Object */
  static fromPlain<T>(this: CustomTypes.Constructor<T>, obj: Partial<T> | Object | string) {
    return plainToInstance(this, obj);
  }

  /** Returns `this` as a JSON string */
  toJSONString() {
    return JSON.stringify(this);
  }
}

/** A class with a slight extension upon Base so we can provide fields we know will exist from the database. */
export class DBBase extends Base {
  id: number;

  constructor(id: number) {
    super();
    this.id = id;
  }
}
