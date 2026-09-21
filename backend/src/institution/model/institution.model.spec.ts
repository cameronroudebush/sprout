import { setupTests } from "@backend/test/helpers";
setupTests();

import { Institution } from "@backend/institution/model/institution.model";
import { InstitutionIconType } from "@backend/institution/model/institution.icon.type";
import { TestEntities } from "@backend/test/entities";

describe("Institution Model", () => {
  const user = TestEntities.user;

  it("should create institution instance with defaults", () => {
    const inst = new Institution("https://chase.com", "Chase", false, user, InstitutionIconType.ICON);

    expect(inst.name).toBe("Chase");
    expect(inst.url).toBe("https://chase.com");
    expect(inst.user).toEqual(user);
    expect(inst.iconType).toBe(InstitutionIconType.ICON);
  });
});
