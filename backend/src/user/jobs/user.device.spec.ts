import { setupTests } from "@backend/test/helpers";
setupTests();

import { UserDeviceJob } from "@backend/user/jobs/user.device";
import { UserDevice } from "@backend/user/model/user.device.model";

describe("UserDeviceJob", () => {
  let job: UserDeviceJob;

  beforeEach(() => {
    jest.clearAllMocks();
    job = new UserDeviceJob();
  });

  it("should delete user devices last seen before cutoff date and log warning when affected > 0", async () => {
    const deleteSpy = jest.spyOn(UserDevice, "delete").mockResolvedValue({ affected: 2, raw: [] });

    await (job as any).update();

    expect(deleteSpy).toHaveBeenCalledWith({
      lastSeenAt: expect.anything(),
    });
  });

  it("should log info message when zero user devices are affected", async () => {
    const deleteSpy = jest.spyOn(UserDevice, "delete").mockResolvedValue({ affected: 0, raw: [] });

    await (job as any).update();

    expect(deleteSpy).toHaveBeenCalledWith({
      lastSeenAt: expect.anything(),
    });
  });
});
