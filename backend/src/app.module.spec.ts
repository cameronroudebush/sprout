import { setupTests } from "@backend/test/helpers";
setupTests();

import { AppModule } from "@backend/app.module";

describe("AppModule", () => {
  it("should define AppModule class", () => {
    expect(AppModule).toBeDefined();
  });

  describe("configure", () => {
    it("should configure middleware consumer", () => {
      const appModule = new AppModule();
      const consumer = {
        apply: jest.fn().mockReturnThis(),
        forRoutes: jest.fn().mockReturnThis(),
      };

      appModule.configure(consumer as any);

      expect(consumer.apply).toHaveBeenCalled();
      expect(consumer.forRoutes).toHaveBeenCalledWith("*path");
    });
  });
});
