import { Database } from "@backend/database/source";
import { DBBase } from "@backend/model/base";
import { CustomTypes } from "@backend/model/utility/custom.types";
import { decorate } from "ts-mixer";
import { FindManyOptions, FindOneOptions, FindOptionsWhere, PrimaryGeneratedColumn, Repository } from "typeorm";

/** This class implements a bunch of common functionality that can be reused for other models that utilize the database */
export class DatabaseBase extends DBBase {
  /** The database connection we use for all queries. Set during startup. */
  static database: Database;

  @decorate(PrimaryGeneratedColumn("uuid"))
  declare id: string;

  /** Returns the repository from the data source to execute content against */
  getRepository() {
    return DatabaseBase.database!.source!.getRepository(this.constructor) as Repository<this>;
  }

  /** Returns the repository from the data source to execute content against */
  static getRepository<T extends DatabaseBase>(this: CustomTypes.Constructor<T>) {
    return new this().getRepository();
  }

  /** Returns this current element with {@link id} from the database */
  async get(): Promise<this> {
    const element = this.getRepository().findOne({ where: { id: this.id as any } });
    if (element == null) throw new Error(`Failed to locate matching element in db for id: ${this.id}`);
    return element as any;
  }

  /** Given some options of what to find, looks up the content in the database */
  static async find<T extends DatabaseBase>(this: CustomTypes.Constructor<T>, opts: FindManyOptions<T>) {
    return await new this().getRepository().find(opts);
  }

  /** Similar to {@link find} but specifically tries to locate a single object, not multiple */
  static async findOne<T extends DatabaseBase>(this: CustomTypes.Constructor<T>, opts: FindOneOptions<T>) {
    return await new this().getRepository().findOne(opts);
  }

  /** Given an ID, deletes the matching element in the database. */
  static async deleteById<T extends DatabaseBase>(this: CustomTypes.Constructor<T>, id: string) {
    return await new this().getRepository().delete(id);
  }

  /** Given the ID's of many objects, removes them from the database. */
  static async deleteMany<T extends DatabaseBase>(this: CustomTypes.Constructor<T>, ids: Array<string>) {
    return await new this().getRepository().delete(ids);
  }

  /** Inserts the element from `this` into the database */
  async insert() {
    this.id = undefined as any; // Make sure no id is set during inserts
    return await this.getRepository().save(this);
  }

  /** Inserts the elements given */
  static async insertMany<T extends DatabaseBase>(this: CustomTypes.Constructor<T>, elements: Array<T>) {
    return await new this().getRepository().save(elements, { chunk: 999 });
  }

  /** Updates this element in the database */
  async update() {
    if (!this.id) throw new Error("Failed to update, no ID provided");
    else return await this.getRepository().save(this);
  }

  /** Counts the total amount of fields that match the given query options */
  static async count<T extends DatabaseBase>(this: CustomTypes.Constructor<T>, options?: FindManyOptions<T>) {
    return await new this().getRepository().count(options);
  }

  /** Given a column name, returns the maximum value */
  static async max<T extends DatabaseBase>(this: CustomTypes.Constructor<T>, columnName: CustomTypes.PropertyNames<T, number>, options?: FindOptionsWhere<T>) {
    return await new this().getRepository().maximum(columnName as any, options);
  }

  /** Given a column name, returns the minimum value */
  static async min<T extends DatabaseBase>(this: CustomTypes.Constructor<T>, columnName: CustomTypes.PropertyNames<T, number>, options?: FindOptionsWhere<T>) {
    return await new this().getRepository().minimum(columnName as any, options);
  }

  /** Given a column name, returns the sum of all values matching the where clause */
  static async sum<T extends DatabaseBase>(this: CustomTypes.Constructor<T>, columnName: CustomTypes.PropertyNames<T, number>, options: FindOptionsWhere<T>) {
    return await new this().getRepository().sum(columnName as any, options);
  }
}
