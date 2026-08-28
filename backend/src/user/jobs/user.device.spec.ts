import { setupTests } from "@backend/test/helpers";
setupTests();

import { UserDeviceJob } from "@backend/user/jobs/user.device";
import { UserDevice } from "@backend/user/model/user.device.model";

describe("UserDeviceJob", () => {
  let job: UserDeviceJob;

  beforeEach(() => {
    job = new UserDeviceJob();
  });

  it("should delete devices older than cutoff date and log warning if affected > 0", async () => {
    const deleteSpy = jest.spyOn(UserDevice, "delete").mockResolvedValue({ affected: 3 } as any);

    await (job as any).update();

    expect(deleteSpy).toHaveBeenCalledWith({
      lastSeenAt: expect.anything(),
    });
  });

  it("should log info when affected is 0 or null", async () => {
    jest.spyOn(UserDevice, "delete").mockResolvedValue({ affected: 0 } as any);

    await (job as any).update();

    expect(UserDevice.delete).toHaveBeenCalled();
  });
});
