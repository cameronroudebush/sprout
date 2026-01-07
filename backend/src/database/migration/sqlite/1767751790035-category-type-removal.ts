import { MigrationInterface, QueryRunner } from "typeorm";

export class CategoryTypeRemoval1767751790035 implements MigrationInterface {
    name = 'CategoryTypeRemoval1767751790035'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "temporary_category" ("id" varchar PRIMARY KEY NOT NULL, "userId" varchar NOT NULL, "name" varchar NOT NULL, "parentCategoryId" varchar, "icon" varchar, CONSTRAINT "UQ_0634179a4275a9ed86e3dae060c" UNIQUE ("name", "userId", "parentCategoryId"), CONSTRAINT "FK_9e5435ba76dbc1f1a0705d4db43" FOREIGN KEY ("parentCategoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION, CONSTRAINT "FK_32b856438dffdc269fa84434d9f" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "temporary_category"("id", "userId", "name", "parentCategoryId", "icon") SELECT "id", "userId", "name", "parentCategoryId", "icon" FROM "category"`);
        await queryRunner.query(`DROP TABLE "category"`);
        await queryRunner.query(`ALTER TABLE "temporary_category" RENAME TO "category"`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "category" RENAME TO "temporary_category"`);
        await queryRunner.query(`CREATE TABLE "category" ("id" varchar PRIMARY KEY NOT NULL, "userId" varchar NOT NULL, "name" varchar NOT NULL, "type" varchar NOT NULL, "parentCategoryId" varchar, "icon" varchar, CONSTRAINT "UQ_0634179a4275a9ed86e3dae060c" UNIQUE ("name", "userId", "parentCategoryId"), CONSTRAINT "FK_9e5435ba76dbc1f1a0705d4db43" FOREIGN KEY ("parentCategoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION, CONSTRAINT "FK_32b856438dffdc269fa84434d9f" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "category"("id", "userId", "name", "parentCategoryId", "icon") SELECT "id", "userId", "name", "parentCategoryId", "icon" FROM "temporary_category"`);
        await queryRunner.query(`DROP TABLE "temporary_category"`);
    }

}
