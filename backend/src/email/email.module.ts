import { Configuration } from "@backend/config/core";
import { EmailController } from "@backend/email/email.controller";
import { NetWorthModule } from "@backend/net-worth/net-worth.module";
import { MailerModule, MailerOptions } from "@nestjs-modules/mailer";
import { EjsAdapter } from "@nestjs-modules/mailer/adapters/ejs.adapter";
import { Module } from "@nestjs/common";
import path from "path";
import { EmailService } from "./email.service";

@Module({
  imports: [
    NetWorthModule,
    MailerModule.forRoot({
      transport: {
        host: Configuration.server.email.host,
        port: Configuration.server.email.port,
        secure: Configuration.server.email.secure,
        auth: {
          user: Configuration.server.email.user,
          pass: Configuration.server.email.pass,
        },
      },
      template: {
        dir: path.join(__dirname, "templates"),
        adapter: new EjsAdapter(),
        options: {
          strict: true,
        },
      },
    } as MailerOptions),
  ],
  controllers: [EmailController],
  providers: [EmailService],
  exports: [EmailService],
})
export class EmailModule {}
