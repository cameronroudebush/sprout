import { setupTests } from "@backend/test/helpers";
setupTests();

import { InstitutionController } from "@backend/institution/institution.controller";
import { InstitutionIconType } from "@backend/institution/model/institution.icon.type";
import { Institution } from "@backend/institution/model/institution.model";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TestEntities } from "@backend/test/entities";
import { NotFoundException } from "@nestjs/common";

describe("InstitutionController", () => {
  let controller: InstitutionController;
  let sseService: jest.Mocked<SSEService>;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    sseService = {
      sendToUser: jest.fn(),
    } as any;

    controller = new InstitutionController(sseService);
  });

  describe("update", () => {
    it("should throw NotFoundException if institution does not exist for user", async () => {
      jest.spyOn(Institution, "findOne").mockResolvedValue(null);

      await expect(controller.update("inst-invalid", user, { iconType: InstitutionIconType.ICON })).rejects.toThrow(NotFoundException);
    });

    it("should update institution iconType and trigger force update", async () => {
      const inst = TestEntities.institution;
      inst.update = jest.fn().mockResolvedValue(inst);
      jest.spyOn(Institution, "findOne").mockResolvedValue(inst);

      const res = await controller.update(inst.id, user, { iconType: InstitutionIconType.ICON });

      expect(inst.iconType).toBe(InstitutionIconType.ICON);
      expect(inst.update).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res).toBe(inst);
    });
  });
});
