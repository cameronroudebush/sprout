import { MigrationInterface, QueryRunner } from "typeorm";

export class CategorySubVariance1782136079357 implements MigrationInterface {
  name = "CategorySubVariance1782136079357";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "temporary_category" ("id" varchar PRIMARY KEY NOT NULL, "userId" varchar NOT NULL, "name" varchar NOT NULL, "parentCategoryId" varchar, "icon" varchar, "excludeFromCashFlow" boolean NOT NULL DEFAULT (0), "increasedSubVariance" boolean NOT NULL DEFAULT (0), CONSTRAINT "UQ_0634179a4275a9ed86e3dae060c" UNIQUE ("name", "userId", "parentCategoryId"), CONSTRAINT "FK_9e5435ba76dbc1f1a0705d4db43" FOREIGN KEY ("parentCategoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION, CONSTRAINT "FK_32b856438dffdc269fa84434d9f" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_category"("id", "userId", "name", "parentCategoryId", "icon", "excludeFromCashFlow", "increasedSubVariance") SELECT "id", "userId", "name", "parentCategoryId", "icon", "excludeFromCashFlow", "canBeHighestExpense" FROM "category"`);
    await queryRunner.query(`DROP TABLE "category"`);
    await queryRunner.query(`ALTER TABLE "temporary_category" RENAME TO "category"`);
    await queryRunner.query(
      `CREATE TABLE "temporary_category" ("id" varchar PRIMARY KEY NOT NULL, "userId" varchar NOT NULL, "name" varchar NOT NULL, "parentCategoryId" varchar, "icon" varchar, "excludeFromCashFlow" boolean NOT NULL DEFAULT (0), "increasedSubVariance" boolean NOT NULL DEFAULT (0), CONSTRAINT "UQ_0634179a4275a9ed86e3dae060c" UNIQUE ("name", "userId", "parentCategoryId"), CONSTRAINT "FK_9e5435ba76dbc1f1a0705d4db43" FOREIGN KEY ("parentCategoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION, CONSTRAINT "FK_32b856438dffdc269fa84434d9f" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_category"("id", "userId", "name", "parentCategoryId", "icon", "excludeFromCashFlow", "increasedSubVariance") SELECT "id", "userId", "name", "parentCategoryId", "icon", "excludeFromCashFlow", 0 FROM "category"`);
    await queryRunner.query(`DROP TABLE "category"`);
    await queryRunner.query(`ALTER TABLE "temporary_category" RENAME TO "category"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "category" RENAME TO "temporary_category"`);
    await queryRunner.query(
      `CREATE TABLE "category" ("id" varchar PRIMARY KEY NOT NULL, "userId" varchar NOT NULL, "name" varchar NOT NULL, "parentCategoryId" varchar, "icon" varchar, "excludeFromCashFlow" boolean NOT NULL DEFAULT (0), "increasedSubVariance" boolean NOT NULL DEFAULT (0), CONSTRAINT "UQ_0634179a4275a9ed86e3dae060c" UNIQUE ("name", "userId", "parentCategoryId"), CONSTRAINT "FK_9e5435ba76dbc1f1a0705d4db43" FOREIGN KEY ("parentCategoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION, CONSTRAINT "FK_32b856438dffdc269fa84434d9f" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "category"("id", "userId", "name", "parentCategoryId", "icon", "excludeFromCashFlow", "increasedSubVariance") SELECT "id", "userId", "name", "parentCategoryId", "icon", "excludeFromCashFlow", "increasedSubVariance" FROM "temporary_category"`);
    await queryRunner.query(`DROP TABLE "temporary_category"`);
    await queryRunner.query(`ALTER TABLE "category" RENAME TO "temporary_category"`);
    await queryRunner.query(
      `CREATE TABLE "category" ("id" varchar PRIMARY KEY NOT NULL, "userId" varchar NOT NULL, "name" varchar NOT NULL, "parentCategoryId" varchar, "icon" varchar, "excludeFromCashFlow" boolean NOT NULL DEFAULT (0), "canBeHighestExpense" boolean NOT NULL DEFAULT (1), CONSTRAINT "UQ_0634179a4275a9ed86e3dae060c" UNIQUE ("name", "userId", "parentCategoryId"), CONSTRAINT "FK_9e5435ba76dbc1f1a0705d4db43" FOREIGN KEY ("parentCategoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION, CONSTRAINT "FK_32b856438dffdc269fa84434d9f" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "category"("id", "userId", "name", "parentCategoryId", "icon", "excludeFromCashFlow", "canBeHighestExpense") SELECT "id", "userId", "name", "parentCategoryId", "icon", "excludeFromCashFlow", "increasedSubVariance" FROM "temporary_category"`);
    await queryRunner.query(`DROP TABLE "temporary_category"`);
  }
}
