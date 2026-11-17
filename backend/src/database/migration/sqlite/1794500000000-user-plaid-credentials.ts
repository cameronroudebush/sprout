import { MigrationInterface, QueryRunner } from "typeorm";

export class UserPlaidCredentials1794500000000 implements MigrationInterface {
  name = "UserPlaidCredentials1794500000000";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "user_config" ADD "plaidClientId" varchar`);
    await queryRunner.query(`ALTER TABLE "user_config" ADD "plaidSecret" varchar`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "user_config" DROP COLUMN "plaidSecret"`);
    await queryRunner.query(`ALTER TABLE "user_config" DROP COLUMN "plaidClientId"`);
  }
}
