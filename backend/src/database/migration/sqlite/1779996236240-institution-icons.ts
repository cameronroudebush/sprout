import { MigrationInterface, QueryRunner } from "typeorm";

export class InstitutionIcons1779996236240 implements MigrationInterface {
    name = 'InstitutionIcons1779996236240'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "temporary_institution" ("id" varchar PRIMARY KEY NOT NULL, "url" varchar NOT NULL, "name" varchar NOT NULL, "hasError" boolean NOT NULL, "userId" varchar NOT NULL, "iconType" varchar CHECK( "iconType" IN ('icon','symbol') ) NOT NULL DEFAULT ('icon'), CONSTRAINT "FK_166fa924f28750b4b9f8227ed9d" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "temporary_institution"("id", "url", "name", "hasError", "userId") SELECT "id", "url", "name", "hasError", "userId" FROM "institution"`);
        await queryRunner.query(`DROP TABLE "institution"`);
        await queryRunner.query(`ALTER TABLE "temporary_institution" RENAME TO "institution"`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "institution" RENAME TO "temporary_institution"`);
        await queryRunner.query(`CREATE TABLE "institution" ("id" varchar PRIMARY KEY NOT NULL, "url" varchar NOT NULL, "name" varchar NOT NULL, "hasError" boolean NOT NULL, "userId" varchar NOT NULL, CONSTRAINT "FK_166fa924f28750b4b9f8227ed9d" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "institution"("id", "url", "name", "hasError", "userId") SELECT "id", "url", "name", "hasError", "userId" FROM "temporary_institution"`);
        await queryRunner.query(`DROP TABLE "temporary_institution"`);
    }

}
