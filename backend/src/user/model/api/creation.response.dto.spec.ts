import { setupTests } from "@backend/test/helpers";
setupTests();

import { UserCreationResponse } from "@backend/user/model/api/creation.response.dto";

describe("UserCreationResponse DTO", () => {
  it("should construct instance properly", () => {
    const response = new UserCreationResponse("createduser");

    expect(response.username).toBe("createduser");
  });
});
