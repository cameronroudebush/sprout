import { MigrationInterface, QueryRunner } from "typeorm";

export class RateLimitPerUser1768861831205 implements MigrationInterface {
  name = "RateLimitPerUser1768861831205";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "provider_rate_limit"`);
    await queryRunner.query(`CREATE TABLE "provider_rate_limit" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "lastUpdated" datetime NOT NULL, "count" integer NOT NULL, "userId" varchar, CONSTRAINT "UQ_36c4fa24ed498d2e31e26abea45" UNIQUE ("name"), CONSTRAINT "FK_2912efb1cd8d2eda414738f9b56" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "provider_rate_limit"`);
    await queryRunner.query(`CREATE TABLE "provider_rate_limit" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "lastUpdated" datetime NOT NULL, "count" integer NOT NULL, CONSTRAINT "UQ_36c4fa24ed498d2e31e26abea45" UNIQUE ("name"))`);
  }
}
