import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { DevModeGuard } from "@backend/config/guard/dev-mode.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { EmailService } from "@backend/email/email.service";
import { WeeklyEmailContent } from "@backend/email/model/weekly-content";
import { User } from "@backend/user/model/user.model";
import { Controller, Get, Post, Res } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import ejs from "ejs";
import { Response } from "express";
import path from "path";

/** This controller provides the endpoint for all email related functionality */
@Controller("email")
@ApiTags("Email")
@AuthGuard.attach()
@DevModeGuard.attach()
export class EmailController {
  constructor(private readonly emailService: EmailService) {}

  /** Renders the given content as EJS to the response for viewing */
  private async renderEjsContent(context: Object, template: "weekly-update", res: Response) {
    const templatePath = path.join(__dirname, `templates/${template}.ejs`);

    try {
      const html = await ejs.renderFile(templatePath, context);
      res.setHeader("Content-Type", "text/html");
      return res.send(html);
    } catch (error) {
      return res.status(500).send(`Error rendering template: ${error}`);
    }
  }

  @Post("test/email/weekly")
  @ApiOperation({
    summary: "Send Test Weekly Email",
    description: "Notifies the current user about their weekly update via email. Only works in dev mode.",
  })
  async notify(@CurrentUser() user: User) {
    this.emailService.sendWeeklyUpdate(user);
  }

  @Get("preview/weekly-update")
  @ApiOperation({
    summary: "Preview Weekly Update Email",
    description: "Renders the weekly update email with some fake data. Only works in dev mode.",
  })
  async previewWeeklyUpdate(@CurrentUser() user: User, @Res() res: Response) {
    await this.renderEjsContent(WeeklyEmailContent.asFake(user), "weekly-update", res);
  }
}
