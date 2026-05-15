import { PlaidLinkDTO } from "@backend/providers/plaid/model/api/link.dto";
import { PlaidProviderController } from "@backend/providers/plaid/plaid.controller";
import { PlaidProviderService } from "@backend/providers/plaid/plaid.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { InternalServerErrorException } from "@nestjs/common";
import { Test, TestingModule } from "@nestjs/testing";

describe("PlaidProviderController", () => {
  let controller: PlaidProviderController;
  let sseService: SSEService;
  let plaidProviderService: PlaidProviderService;

  const mockUser = { id: "user-123" } as User;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PlaidProviderController],
      providers: [
        {
          provide: SSEService,
          useValue: {
            sendToUser: jest.fn(),
          },
        },
        {
          provide: PlaidProviderService,
          useValue: {
            generateLinkToken: jest.fn(),
            exchangeAndCreateAccounts: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<PlaidProviderController>(PlaidProviderController);
    sseService = module.get<SSEService>(SSEService);
    plaidProviderService = module.get<PlaidProviderService>(PlaidProviderService);
  });

  describe("createLinkToken", () => {
    it("should successfully return a link token", async () => {
      const expectedToken = { expiration: new Date(), link_token: "token", request_id: "req_id" };
      (plaidProviderService.generateLinkToken as jest.Mock).mockResolvedValue(expectedToken);

      const result = await controller.createLinkToken(mockUser, "inst-1");

      expect(result).toEqual(expectedToken);
      expect(plaidProviderService.generateLinkToken).toHaveBeenCalledWith(mockUser, "inst-1");
    });

    it("should handle missing institutionId", async () => {
      const expectedToken = { expiration: new Date(), link_token: "token", request_id: "req_id" };
      (plaidProviderService.generateLinkToken as jest.Mock).mockResolvedValue(expectedToken);

      const result = await controller.createLinkToken(mockUser);

      expect(result).toEqual(expectedToken);
      expect(plaidProviderService.generateLinkToken).toHaveBeenCalledWith(mockUser, undefined);
    });

    it("should throw InternalServerErrorException on error", async () => {
      (plaidProviderService.generateLinkToken as jest.Mock).mockRejectedValue(new Error("Provider Error"));

      await expect(controller.createLinkToken(mockUser)).rejects.toThrow(InternalServerErrorException);
    });
  });

  describe("exchangeAndLink", () => {
    it("should exchange token, create accounts, and trigger SSE", async () => {
      const mockAccounts = [{ id: "acc-1" }];
      const mockDto = { metadata: { institution: null as any, accounts: [], link_session_id: "", status: null as any }, public_token: "pub_tok" } as unknown as PlaidLinkDTO;

      (plaidProviderService.exchangeAndCreateAccounts as jest.Mock).mockResolvedValue(mockAccounts);

      const result = await controller.exchangeAndLink(mockUser, mockDto);

      expect(result).toEqual(mockAccounts);
      expect(plaidProviderService.exchangeAndCreateAccounts).toHaveBeenCalledWith(mockUser, mockDto);
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
    });

    it("should throw InternalServerErrorException on error", async () => {
      const mockDto = { metadata: { institution: null as any, accounts: [], link_session_id: "", status: null as any }, public_token: "pub_tok" } as unknown as PlaidLinkDTO;
      (plaidProviderService.exchangeAndCreateAccounts as jest.Mock).mockRejectedValue(new Error("Provider Error"));

      await expect(controller.exchangeAndLink(mockUser, mockDto)).rejects.toThrow(InternalServerErrorException);
    });
  });
});
