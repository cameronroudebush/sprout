import { setupTests } from "@backend/test/helpers";
setupTests();

import { EmailController } from "@backend/email/email.controller";
import { EmailService } from "@backend/email/email.service";
import { TestEntities } from "@backend/test/entities";
import ejs from "ejs";

describe("EmailController", () => {
  let controller: EmailController;
  let emailService: jest.Mocked<EmailService>;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    emailService = {
      sendWeeklyUpdate: jest.fn(),
      getWeeklyEmailContent: jest.fn().mockResolvedValue({ user }),
    } as any;

    controller = new EmailController(emailService);
  });

  describe("notify", () => {
    it("should trigger sendWeeklyUpdate for current user", async () => {
      await controller.notify(user);

      expect(emailService.sendWeeklyUpdate).toHaveBeenCalledWith(user);
    });
  });

  describe("previewWeeklyUpdate", () => {
    it("should render EJS content and send html response on success", async () => {
      jest.spyOn(ejs, "renderFile").mockImplementation((_path, _ctx, cb: any) => {
        if (typeof cb === "function") cb(null, "<html>Email Content</html>");
        return Promise.resolve("<html>Email Content</html>");
      });

      const mockRes: any = {
        setHeader: jest.fn(),
        send: jest.fn(),
        status: jest.fn().mockReturnThis(),
      };

      await controller.previewWeeklyUpdate(user, mockRes);

      expect(emailService.getWeeklyEmailContent).toHaveBeenCalledWith(user);
      expect(mockRes.setHeader).toHaveBeenCalledWith("Content-Type", "text/html");
      expect(mockRes.send).toHaveBeenCalledWith("<html>Email Content</html>");
    });

    it("should return 500 error if EJS rendering fails", async () => {
      jest.spyOn(ejs, "renderFile").mockRejectedValue(new Error("Template missing"));

      const mockRes: any = {
        setHeader: jest.fn(),
        send: jest.fn(),
        status: jest.fn().mockReturnThis(),
      };

      await controller.previewWeeklyUpdate(user, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.send).toHaveBeenCalledWith(expect.stringContaining("Error rendering template"));
    });
  });
});
