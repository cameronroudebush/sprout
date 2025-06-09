import { Database } from "@backend/database/source";
import { CustomTypes, DBBase } from "@common";
import { decorate } from "ts-mixer";
import { FindManyOptions, FindOneOptions, PrimaryGeneratedColumn, Repository } from "typeorm";

/** This class implements a bunch of common functionality that can be reused for other models that utilize the database */
export class DatabaseBase extends DBBase {
  @decorate(PrimaryGeneratedColumn("uuid"))
  declare id: string;

  /** Returns the repository from the data source to execute content against */
  private getRepository() {
    return Database.source!.getRepository(this.constructor) as Repository<this>;
  }

  //   /**
  //    * @see {@link getRepository}
  //    */
  //   private static getRepository<T extends DatabaseBase>(this: CustomTypes.Constructor<T>) {
  //     return new this().getRepository();
  //   }

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

  /** Inserts the element from `this` into the database */
  async insert() {
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
}
