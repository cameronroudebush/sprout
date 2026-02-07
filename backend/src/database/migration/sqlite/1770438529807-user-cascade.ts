import { MigrationInterface, QueryRunner } from "typeorm";

export class UserCascade1770438529807 implements MigrationInterface {
  name = "UserCascade1770438529807";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "user_config" ADD COLUMN "temp_userId" varchar`);
    // Move the ID from User.id to UserConfig.userId based on the old relation
    await queryRunner.query(`
            UPDATE "user_config" 
            SET "temp_userId" = (SELECT "id" FROM "user" WHERE "user"."configId" = "user_config"."id")
        `);

    await queryRunner.query(`CREATE TABLE "temporary_user" ("id" varchar PRIMARY KEY NOT NULL, "firstName" varchar, "lastName" varchar, "username" varchar NOT NULL, "admin" boolean NOT NULL DEFAULT (0), "password" varchar, "configId" varchar, CONSTRAINT "UQ_ba8b1b73ff0a6b15ae34619d944" UNIQUE ("configId"))`);
    await queryRunner.query(`INSERT INTO "temporary_user"("id", "firstName", "lastName", "username", "admin", "password", "configId") SELECT "id", "firstName", "lastName", "username", "admin", "password", "configId" FROM "user"`);
    await queryRunner.query(`DROP TABLE "user"`);
    await queryRunner.query(`ALTER TABLE "temporary_user" RENAME TO "user"`);
    await queryRunner.query(`CREATE TABLE "temporary_institution" ("id" varchar PRIMARY KEY NOT NULL, "url" varchar NOT NULL, "name" varchar NOT NULL, "hasError" boolean NOT NULL, "userId" varchar NOT NULL)`);
    await queryRunner.query(`INSERT INTO "temporary_institution"("id", "url", "name", "hasError", "userId") SELECT "id", "url", "name", "hasError", "userId" FROM "institution"`);
    await queryRunner.query(`DROP TABLE "institution"`);
    await queryRunner.query(`ALTER TABLE "temporary_institution" RENAME TO "institution"`);
    await queryRunner.query(
      `CREATE TABLE "temporary_account" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "provider" varchar NOT NULL, "currency" varchar NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "type" varchar NOT NULL, "institutionId" varchar, "userId" varchar, "extra" json, "subType" varchar, CONSTRAINT "UQ_414d4052f22837655ff312168cb" UNIQUE ("name"), CONSTRAINT "FK_b0d9c345163894d7476574eaf84" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_account"("id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType") SELECT "id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType" FROM "account"`);
    await queryRunner.query(`DROP TABLE "account"`);
    await queryRunner.query(`ALTER TABLE "temporary_account" RENAME TO "account"`);
    await queryRunner.query(`CREATE TABLE "temporary_notification" ("id" varchar PRIMARY KEY NOT NULL, "title" varchar NOT NULL, "message" varchar NOT NULL, "type" varchar NOT NULL, "createdAt" datetime NOT NULL, "isRead" boolean NOT NULL DEFAULT (0), "readAt" datetime, "userId" varchar)`);
    await queryRunner.query(`INSERT INTO "temporary_notification"("id", "title", "message", "type", "createdAt", "isRead", "readAt", "userId") SELECT "id", "title", "message", "type", "createdAt", "isRead", "readAt", "userId" FROM "notification"`);
    await queryRunner.query(`DROP TABLE "notification"`);
    await queryRunner.query(`ALTER TABLE "temporary_notification" RENAME TO "notification"`);
    await queryRunner.query(`CREATE TABLE "temporary_user_device" ("id" varchar PRIMARY KEY NOT NULL, "fcmToken" varchar NOT NULL, "deviceName" varchar, "platform" varchar NOT NULL DEFAULT ('android'), "lastSeenAt" datetime NOT NULL, "userId" varchar, CONSTRAINT "UQ_034f6dc930c25b5d315462ca9bf" UNIQUE ("fcmToken"))`);
    await queryRunner.query(`INSERT INTO "temporary_user_device"("id", "fcmToken", "deviceName", "platform", "lastSeenAt", "userId") SELECT "id", "fcmToken", "deviceName", "platform", "lastSeenAt", "userId" FROM "user_device"`);
    await queryRunner.query(`DROP TABLE "user_device"`);
    await queryRunner.query(`ALTER TABLE "temporary_user_device" RENAME TO "user_device"`);
    await queryRunner.query(`CREATE TABLE "temporary_chat_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "isThinking" boolean NOT NULL DEFAULT (0), "role" double NOT NULL, "userId" varchar)`);
    await queryRunner.query(`INSERT INTO "temporary_chat_history"("id", "time", "text", "isThinking", "role", "userId") SELECT "id", "time", "text", "isThinking", "role", "userId" FROM "chat_history"`);
    await queryRunner.query(`DROP TABLE "chat_history"`);
    await queryRunner.query(`ALTER TABLE "temporary_chat_history" RENAME TO "chat_history"`);
    await queryRunner.query(`CREATE TABLE "temporary_user" ("id" varchar PRIMARY KEY NOT NULL, "firstName" varchar, "lastName" varchar, "username" varchar NOT NULL, "admin" boolean NOT NULL DEFAULT (0), "password" varchar)`);
    await queryRunner.query(`INSERT INTO "temporary_user"("id", "firstName", "lastName", "username", "admin", "password") SELECT "id", "firstName", "lastName", "username", "admin", "password" FROM "user"`);
    await queryRunner.query(`DROP TABLE "user"`);
    await queryRunner.query(`ALTER TABLE "temporary_user" RENAME TO "user"`);
    await queryRunner.query(`CREATE TABLE "temporary_user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "geminiKey" varchar, "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"))`);
    await queryRunner.query(`INSERT INTO "temporary_user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey", "userId") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey", "temp_userId" FROM "user_config"`);
    await queryRunner.query(`DROP TABLE "user_config"`);
    await queryRunner.query(`ALTER TABLE "temporary_user_config" RENAME TO "user_config"`);
    await queryRunner.query(
      `CREATE TABLE "temporary_user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "geminiKey" varchar, "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"), CONSTRAINT "FK_50aa50cd542e360ea75bf4eaa74" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey", "secureMode", "userId") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey", "secureMode", "userId" FROM "user_config"`);
    await queryRunner.query(`DROP TABLE "user_config"`);
    await queryRunner.query(`ALTER TABLE "temporary_user_config" RENAME TO "user_config"`);
    await queryRunner.query(`CREATE TABLE "temporary_institution" ("id" varchar PRIMARY KEY NOT NULL, "url" varchar NOT NULL, "name" varchar NOT NULL, "hasError" boolean NOT NULL, "userId" varchar NOT NULL, CONSTRAINT "FK_166fa924f28750b4b9f8227ed9d" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_institution"("id", "url", "name", "hasError", "userId") SELECT "id", "url", "name", "hasError", "userId" FROM "institution"`);
    await queryRunner.query(`DROP TABLE "institution"`);
    await queryRunner.query(`ALTER TABLE "temporary_institution" RENAME TO "institution"`);
    await queryRunner.query(
      `CREATE TABLE "temporary_account" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "provider" varchar NOT NULL, "currency" varchar NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "type" varchar NOT NULL, "institutionId" varchar, "userId" varchar, "extra" json, "subType" varchar, CONSTRAINT "UQ_414d4052f22837655ff312168cb" UNIQUE ("name"), CONSTRAINT "FK_b0d9c345163894d7476574eaf84" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION, CONSTRAINT "FK_60328bf27019ff5498c4b977421" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_account"("id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType") SELECT "id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType" FROM "account"`);
    await queryRunner.query(`DROP TABLE "account"`);
    await queryRunner.query(`ALTER TABLE "temporary_account" RENAME TO "account"`);
    await queryRunner.query(`CREATE TABLE "temporary_notification" ("id" varchar PRIMARY KEY NOT NULL, "title" varchar NOT NULL, "message" varchar NOT NULL, "type" varchar NOT NULL, "createdAt" datetime NOT NULL, "isRead" boolean NOT NULL DEFAULT (0), "readAt" datetime, "userId" varchar, CONSTRAINT "FK_1ced25315eb974b73391fb1c81b" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_notification"("id", "title", "message", "type", "createdAt", "isRead", "readAt", "userId") SELECT "id", "title", "message", "type", "createdAt", "isRead", "readAt", "userId" FROM "notification"`);
    await queryRunner.query(`DROP TABLE "notification"`);
    await queryRunner.query(`ALTER TABLE "temporary_notification" RENAME TO "notification"`);
    await queryRunner.query(`CREATE TABLE "temporary_user_device" ("id" varchar PRIMARY KEY NOT NULL, "fcmToken" varchar NOT NULL, "deviceName" varchar, "platform" varchar NOT NULL DEFAULT ('android'), "lastSeenAt" datetime NOT NULL, "userId" varchar, CONSTRAINT "UQ_034f6dc930c25b5d315462ca9bf" UNIQUE ("fcmToken"), CONSTRAINT "FK_bda1afb30d9e3e8fb30b1e90af7" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_user_device"("id", "fcmToken", "deviceName", "platform", "lastSeenAt", "userId") SELECT "id", "fcmToken", "deviceName", "platform", "lastSeenAt", "userId" FROM "user_device"`);
    await queryRunner.query(`DROP TABLE "user_device"`);
    await queryRunner.query(`ALTER TABLE "temporary_user_device" RENAME TO "user_device"`);
    await queryRunner.query(`CREATE TABLE "temporary_chat_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "isThinking" boolean NOT NULL DEFAULT (0), "role" double NOT NULL, "userId" varchar, CONSTRAINT "FK_6bac64204c7b416f465e17957ed" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_chat_history"("id", "time", "text", "isThinking", "role", "userId") SELECT "id", "time", "text", "isThinking", "role", "userId" FROM "chat_history"`);
    await queryRunner.query(`DROP TABLE "chat_history"`);
    await queryRunner.query(`ALTER TABLE "temporary_chat_history" RENAME TO "chat_history"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "chat_history" RENAME TO "temporary_chat_history"`);
    await queryRunner.query(`CREATE TABLE "chat_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "isThinking" boolean NOT NULL DEFAULT (0), "role" double NOT NULL, "userId" varchar)`);
    await queryRunner.query(`INSERT INTO "chat_history"("id", "time", "text", "isThinking", "role", "userId") SELECT "id", "time", "text", "isThinking", "role", "userId" FROM "temporary_chat_history"`);
    await queryRunner.query(`DROP TABLE "temporary_chat_history"`);
    await queryRunner.query(`ALTER TABLE "user_device" RENAME TO "temporary_user_device"`);
    await queryRunner.query(`CREATE TABLE "user_device" ("id" varchar PRIMARY KEY NOT NULL, "fcmToken" varchar NOT NULL, "deviceName" varchar, "platform" varchar NOT NULL DEFAULT ('android'), "lastSeenAt" datetime NOT NULL, "userId" varchar, CONSTRAINT "UQ_034f6dc930c25b5d315462ca9bf" UNIQUE ("fcmToken"))`);
    await queryRunner.query(`INSERT INTO "user_device"("id", "fcmToken", "deviceName", "platform", "lastSeenAt", "userId") SELECT "id", "fcmToken", "deviceName", "platform", "lastSeenAt", "userId" FROM "temporary_user_device"`);
    await queryRunner.query(`DROP TABLE "temporary_user_device"`);
    await queryRunner.query(`ALTER TABLE "notification" RENAME TO "temporary_notification"`);
    await queryRunner.query(`CREATE TABLE "notification" ("id" varchar PRIMARY KEY NOT NULL, "title" varchar NOT NULL, "message" varchar NOT NULL, "type" varchar NOT NULL, "createdAt" datetime NOT NULL, "isRead" boolean NOT NULL DEFAULT (0), "readAt" datetime, "userId" varchar)`);
    await queryRunner.query(`INSERT INTO "notification"("id", "title", "message", "type", "createdAt", "isRead", "readAt", "userId") SELECT "id", "title", "message", "type", "createdAt", "isRead", "readAt", "userId" FROM "temporary_notification"`);
    await queryRunner.query(`DROP TABLE "temporary_notification"`);
    await queryRunner.query(`ALTER TABLE "account" RENAME TO "temporary_account"`);
    await queryRunner.query(
      `CREATE TABLE "account" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "provider" varchar NOT NULL, "currency" varchar NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "type" varchar NOT NULL, "institutionId" varchar, "userId" varchar, "extra" json, "subType" varchar, CONSTRAINT "UQ_414d4052f22837655ff312168cb" UNIQUE ("name"), CONSTRAINT "FK_b0d9c345163894d7476574eaf84" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "account"("id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType") SELECT "id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType" FROM "temporary_account"`);
    await queryRunner.query(`DROP TABLE "temporary_account"`);
    await queryRunner.query(`ALTER TABLE "institution" RENAME TO "temporary_institution"`);
    await queryRunner.query(`CREATE TABLE "institution" ("id" varchar PRIMARY KEY NOT NULL, "url" varchar NOT NULL, "name" varchar NOT NULL, "hasError" boolean NOT NULL, "userId" varchar NOT NULL)`);
    await queryRunner.query(`INSERT INTO "institution"("id", "url", "name", "hasError", "userId") SELECT "id", "url", "name", "hasError", "userId" FROM "temporary_institution"`);
    await queryRunner.query(`DROP TABLE "temporary_institution"`);
    await queryRunner.query(`ALTER TABLE "user_config" RENAME TO "temporary_user_config"`);
    await queryRunner.query(`CREATE TABLE "user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "geminiKey" varchar, "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"))`);
    await queryRunner.query(`INSERT INTO "user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey", "secureMode", "userId") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey", "secureMode", "userId" FROM "temporary_user_config"`);
    await queryRunner.query(`DROP TABLE "temporary_user_config"`);
    await queryRunner.query(`ALTER TABLE "user_config" RENAME TO "temporary_user_config"`);
    await queryRunner.query(`CREATE TABLE "user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "geminiKey" varchar)`);
    await queryRunner.query(`INSERT INTO "user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey" FROM "temporary_user_config"`);
    await queryRunner.query(`DROP TABLE "temporary_user_config"`);
    await queryRunner.query(`ALTER TABLE "user" RENAME TO "temporary_user"`);
    await queryRunner.query(`CREATE TABLE "user" ("id" varchar PRIMARY KEY NOT NULL, "firstName" varchar, "lastName" varchar, "username" varchar NOT NULL, "admin" boolean NOT NULL DEFAULT (0), "password" varchar, "configId" varchar, CONSTRAINT "UQ_ba8b1b73ff0a6b15ae34619d944" UNIQUE ("configId"))`);
    await queryRunner.query(`INSERT INTO "user"("id", "firstName", "lastName", "username", "admin", "password") SELECT "id", "firstName", "lastName", "username", "admin", "password" FROM "temporary_user"`);
    await queryRunner.query(`DROP TABLE "temporary_user"`);
    await queryRunner.query(`ALTER TABLE "chat_history" RENAME TO "temporary_chat_history"`);
    await queryRunner.query(`CREATE TABLE "chat_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "isThinking" boolean NOT NULL DEFAULT (0), "role" double NOT NULL, "userId" varchar, CONSTRAINT "FK_6bac64204c7b416f465e17957ed" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "chat_history"("id", "time", "text", "isThinking", "role", "userId") SELECT "id", "time", "text", "isThinking", "role", "userId" FROM "temporary_chat_history"`);
    await queryRunner.query(`DROP TABLE "temporary_chat_history"`);
    await queryRunner.query(`ALTER TABLE "user_device" RENAME TO "temporary_user_device"`);
    await queryRunner.query(`CREATE TABLE "user_device" ("id" varchar PRIMARY KEY NOT NULL, "fcmToken" varchar NOT NULL, "deviceName" varchar, "platform" varchar NOT NULL DEFAULT ('android'), "lastSeenAt" datetime NOT NULL, "userId" varchar, CONSTRAINT "UQ_034f6dc930c25b5d315462ca9bf" UNIQUE ("fcmToken"), CONSTRAINT "FK_bda1afb30d9e3e8fb30b1e90af7" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "user_device"("id", "fcmToken", "deviceName", "platform", "lastSeenAt", "userId") SELECT "id", "fcmToken", "deviceName", "platform", "lastSeenAt", "userId" FROM "temporary_user_device"`);
    await queryRunner.query(`DROP TABLE "temporary_user_device"`);
    await queryRunner.query(`ALTER TABLE "notification" RENAME TO "temporary_notification"`);
    await queryRunner.query(`CREATE TABLE "notification" ("id" varchar PRIMARY KEY NOT NULL, "title" varchar NOT NULL, "message" varchar NOT NULL, "type" varchar NOT NULL, "createdAt" datetime NOT NULL, "isRead" boolean NOT NULL DEFAULT (0), "readAt" datetime, "userId" varchar, CONSTRAINT "FK_1ced25315eb974b73391fb1c81b" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "notification"("id", "title", "message", "type", "createdAt", "isRead", "readAt", "userId") SELECT "id", "title", "message", "type", "createdAt", "isRead", "readAt", "userId" FROM "temporary_notification"`);
    await queryRunner.query(`DROP TABLE "temporary_notification"`);
    await queryRunner.query(`ALTER TABLE "account" RENAME TO "temporary_account"`);
    await queryRunner.query(
      `CREATE TABLE "account" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "provider" varchar NOT NULL, "currency" varchar NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "type" varchar NOT NULL, "institutionId" varchar, "userId" varchar, "extra" json, "subType" varchar, CONSTRAINT "UQ_414d4052f22837655ff312168cb" UNIQUE ("name"), CONSTRAINT "FK_b0d9c345163894d7476574eaf84" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION, CONSTRAINT "FK_60328bf27019ff5498c4b977421" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "account"("id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType") SELECT "id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType" FROM "temporary_account"`);
    await queryRunner.query(`DROP TABLE "temporary_account"`);
    await queryRunner.query(`ALTER TABLE "institution" RENAME TO "temporary_institution"`);
    await queryRunner.query(`CREATE TABLE "institution" ("id" varchar PRIMARY KEY NOT NULL, "url" varchar NOT NULL, "name" varchar NOT NULL, "hasError" boolean NOT NULL, "userId" varchar NOT NULL, CONSTRAINT "FK_166fa924f28750b4b9f8227ed9d" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "institution"("id", "url", "name", "hasError", "userId") SELECT "id", "url", "name", "hasError", "userId" FROM "temporary_institution"`);
    await queryRunner.query(`DROP TABLE "temporary_institution"`);
    await queryRunner.query(`ALTER TABLE "user" RENAME TO "temporary_user"`);
    await queryRunner.query(`CREATE TABLE "user" ("id" varchar PRIMARY KEY NOT NULL, "firstName" varchar, "lastName" varchar, "username" varchar NOT NULL, "admin" boolean NOT NULL DEFAULT (0), "password" varchar, "configId" varchar, CONSTRAINT "UQ_ba8b1b73ff0a6b15ae34619d944" UNIQUE ("configId"), CONSTRAINT "FK_2a91dde35c5a0668f32b39f49c5" FOREIGN KEY ("configId") REFERENCES "user_config" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "user"("id", "firstName", "lastName", "username", "admin", "password", "configId") SELECT "id", "firstName", "lastName", "username", "admin", "password", "configId" FROM "temporary_user"`);
    await queryRunner.query(`DROP TABLE "temporary_user"`);
  }
}
