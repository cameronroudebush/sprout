import { Account } from "@backend/account/model/account.model";
import { DatabaseService } from "@backend/database/database.service";
import { ProviderSyncOrchestratorJob } from "@backend/jobs/sync";
import { SSEEventType } from "@backend/sse/model/event.model";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, NotFoundException } from "@nestjs/common";
import { Test, TestingModule } from "@nestjs/testing";
import { SSEService } from "../sse/sse.service";
import { AccountController } from "./account.controller";

describe("AccountController", () => {
  let controller: AccountController;
  let sseService: SSEService;

  const mockUser = { id: "user-123" } as User;
  const mockAccount = {
    id: "acc-1",
    name: "Savings Account",
    user: mockUser,
    update: jest.fn().mockResolvedValue({ id: "acc-1", name: "Updated Name" }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AccountController],
      providers: [
        {
          provide: SSEService,
          useValue: { sendToUser: jest.fn() },
        },
        {
          provide: DatabaseService,
          useValue: { source: { transaction: jest.fn() } },
        },
        {
          provide: ProviderSyncOrchestratorJob,
          useValue: { jobs: [] },
        },
      ],
    }).compile();

    controller = module.get<AccountController>(AccountController);
    sseService = module.get<SSEService>(SSEService);

    // Mock static methods of Account Entity
    Account.findOne = jest.fn();
    Account.find = jest.fn();
    Account.deleteById = jest.fn();
  });

  describe("getById", () => {
    it("should return an account if found", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(mockAccount);

      const result = await controller.getById("acc-1", mockUser);
      expect(result).toEqual(mockAccount);
      expect(Account.findOne).toHaveBeenCalledWith({
        where: { id: "acc-1", user: { id: mockUser.id } },
      });
    });

    it("should throw NotFoundException if account not found", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(null);

      await expect(controller.getById("invalid", mockUser)).rejects.toThrow(NotFoundException);
    });
  });

  describe("edit", () => {
    it("should update account fields and trigger SSE", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(mockAccount);
      const updateDto = { name: "New Valid Name" };

      const result = await controller.edit("acc-1", mockUser, updateDto);

      expect(mockAccount.update).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(result.name).toBe("Updated Name");
    });

    it("should throw BadRequestException if name is too short", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(mockAccount);
      const updateDto = { name: "Shot" };

      await expect(controller.edit("acc-1", mockUser, updateDto)).rejects.toThrow(BadRequestException);
    });
  });

  describe("delete", () => {
    it("should delete and notify via SSE", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(mockAccount);
      (Account.deleteById as jest.Mock).mockResolvedValue({ affected: 1 });

      const result = await controller.delete("acc-1", mockUser);

      expect(result).toContain("deleted successfully");
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
    });
  });
});
