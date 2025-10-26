import { DBBase } from "@backend/core/model/base";
import { CustomTypes } from "@backend/core/model/utility/custom.types";
import { DatabaseService } from "@backend/database/database.service";
import { ApiProperty } from "@nestjs/swagger";
import { decorate } from "ts-mixer";
import { FindManyOptions, FindOneOptions, FindOptionsWhere, In, PrimaryGeneratedColumn, Repository } from "typeorm";

/** This class implements a bunch of common functionality that can be reused for other models that utilize the database */
export class DatabaseBase extends DBBase {
  /** The database connection we use for all queries. Set during startup. */
  static database: DatabaseService;

  @decorate(PrimaryGeneratedColumn("uuid"))
  @ApiProperty()
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

  /**
   * Inserts the element from `this` into the database
   *
   * @param wipeId If we should reset the ID so we don't accidentally upsert. Default is true
   */
  async insert(wipeId = true) {
    if (wipeId) this.id = undefined as any;
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

  /** Given a condition and a field partial object to update, updates all elements that match this condition to include the partial object. */
  static async updateWhere<T extends DatabaseBase>(this: CustomTypes.Constructor<T>, where: FindOptionsWhere<T>, partial: Partial<T>) {
    return await new this().getRepository().update(where, partial as any);
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

  /**
   * Finds the most recent record for each group based on a date column. This is useful for "greatest-n-per-group" queries.
   * For example, finding the latest log entry for each user per day.
   *
   * @param options An object containing query options.
   * @param options.dateColumn The name of the date/timestamp column to use for ordering.
   * @param options.partitionBy An array of column names to group by (e.g., ['userId', 'eventType']).
   * @param options.partitionByDateOnly If true, the grouping will be on the DATE part of the `dateColumn`. Defaults to true.
   * @param options.where An optional TypeORM `where` clause to pre-filter the records.
   * @param options.joins An optional array of relation names to LEFT JOIN before applying the where clause.
   * @returns A promise that resolves to an array of the most recent entities for each group.
   */
  static async findMostRecentInGroup<T extends DatabaseBase>(
    this: CustomTypes.Constructor<T> & typeof DatabaseBase,
    options: {
      dateColumn: keyof T & string;
      partitionBy: (keyof T & string)[];
      partitionByDateOnly?: boolean;
      where?: FindOptionsWhere<T> | FindOptionsWhere<T>[];
      joins?: string[];
    },
  ): Promise<T[]> {
    const repository = new this().getRepository();
    const alias = repository.metadata.tableName;
    const { dateColumn, partitionBy, where, joins } = options;
    const partitionByDateOnly = options.partitionByDateOnly !== false;
    const partitionClauses = [...partitionBy.map((col) => `"${alias}"."${col}"`)];
    if (partitionByDateOnly) partitionClauses.push(`DATE("${alias}"."${dateColumn}")`);
    const partitionSql = partitionClauses.join(", ");
    const subQuery = repository.createQueryBuilder(alias);
    if (joins) for (const relation of joins) subQuery.leftJoinAndSelect(`${alias}.${relation}`, relation);
    subQuery.select(`"${alias}".*`).addSelect(`ROW_NUMBER() OVER (PARTITION BY ${partitionSql} ORDER BY "${alias}"."${dateColumn}" DESC) as "row_num"`);
    if (where) subQuery.where(where);
    const rawResults = await repository.manager.connection
      .createQueryBuilder()
      .select("subquery.*")
      .from(`(${subQuery.getQuery()})`, "subquery")
      .setParameters(subQuery.getParameters())
      .where(`"subquery"."row_num" = 1`)
      .getRawMany();
    const ids = rawResults.map((r) => r.id) as string[];
    const fullEntities = await this.find({
      where: { id: In(ids) } as any,
    });
    const entityMap = new Map(fullEntities.map((e) => [e.id, e]));
    return ids.map((id) => entityMap.get(id)!);
  }
}
