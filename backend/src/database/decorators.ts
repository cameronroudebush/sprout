import { DatabaseBase } from "@backend/model/database.base";
import { CustomTypes } from "@backend/model/utility/custom.types";
import { Column, ColumnOptions, Entity, EntityOptions } from "typeorm";

/** Currently registered entities to the database */
export const registeredEntities: CustomTypes.Constructor<DatabaseBase>[] = [];

/** This class provides centralized decorators to help apply common functionality to simplify database management */
export class DatabaseDecorators {
  /** Entity configuration to wrap database classes */
  static entity(options?: EntityOptions) {
    return function (target: any) {
      registeredEntities.push(target);
      return Entity(options)(target);
    };
  }

  /**
   * Decorates this property with the given options
   */
  static column(options?: ColumnOptions) {
    return function (target: any, key: string) {
      return Column({ ...options })(target, key);
    };
  }

  /** Decorates this column with the options and sets a numeric transformer */
  static numericColumn(options?: ColumnOptions) {
    return function (target: any, key: string) {
      return Column({ ...options, type: "double" })(target, key);
    };
  }

  /** Decorates this column to expect json data */
  static jsonColumn(options?: ColumnOptions) {
    return function (target: any, key: string) {
      return Column({ ...options, type: "json" })(target, key);
    };
  }
}
