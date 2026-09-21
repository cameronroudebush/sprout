import { setupTests } from "@backend/test/helpers";
setupTests();

import { UserCreationRequest } from "@backend/user/model/api/creation.request.dto";

describe("UserCreationRequest DTO", () => {
  it("should construct instance properly", () => {
    const request = new UserCreationRequest("testuser", "secretpass");

    expect(request.username).toBe("testuser");
    expect(request.password).toBe("secretpass");
  });
});
