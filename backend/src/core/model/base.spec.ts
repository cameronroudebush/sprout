import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { Base, DBBase } from "./base.js";

class DummyModel extends Base {
  name!: string;
  age!: number;
}

class DummyDBModel extends DBBase {
  name!: string;
}

describe("Base model", () => {
  it("should convert plain objects to model instances and list of instances", () => {
    const model = DummyModel.fromPlain({ name: "John", age: 30 });
    expect(model).toBeInstanceOf(DummyModel);
    expect(model.name).toBe("John");
    expect(model.age).toBe(30);

    const list = DummyModel.fromPlainArray([
      { name: "John", age: 30 },
      { name: "Jane", age: 25 },
    ]);
    expect(list).toHaveLength(2);
    expect(list[0]).toBeInstanceOf(DummyModel);
    expect(list[1]).toBeInstanceOf(DummyModel);
  });

  it("should convert model instance to JSON string and plain object", () => {
    const model = DummyModel.fromPlain({ name: "John", age: 30 });
    expect(model.toJSONString()).toBe('{"name":"John","age":30}');
    expect(model.toPlain()).toEqual({ name: "John", age: 30 });
  });

  it("should support DBBase subclass with id", () => {
    const dbModel = DummyDBModel.fromPlain({ id: "db-123", name: "Test" });
    expect(dbModel).toBeInstanceOf(DBBase);
    expect(dbModel.id).toBe("db-123");
    expect(dbModel.name).toBe("Test");
  });
});
