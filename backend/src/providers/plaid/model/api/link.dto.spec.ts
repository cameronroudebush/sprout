import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { PlaidAccountDTO, PlaidInstitutionDTO, PlaidLinkDTO, PlaidMetadataDTO } from "@backend/providers/plaid/model/api/link.dto.js";

describe("PlaidLinkDTO", () => {
  it("should instantiate PlaidAccountDTO with and without mask", () => {
    const acc1 = new PlaidAccountDTO("acc_1", "Checking", "depository", "checking", "1234");
    expect(acc1.id).toBe("acc_1");
    expect(acc1.name).toBe("Checking");
    expect(acc1.type).toBe("depository");
    expect(acc1.subtype).toBe("checking");
    expect(acc1.mask).toBe("1234");

    const acc2 = new PlaidAccountDTO("acc_2", "Savings", "depository", "savings");
    expect(acc2.mask).toBeUndefined();
  });

  it("should instantiate PlaidInstitutionDTO", () => {
    const inst = new PlaidInstitutionDTO("Bank", "inst_1");
    expect(inst.name).toBe("Bank");
    expect(inst.institution_id).toBe("inst_1");
  });

  it("should instantiate PlaidMetadataDTO and PlaidLinkDTO", () => {
    const inst = new PlaidInstitutionDTO("Bank", "inst_1");
    const acc = new PlaidAccountDTO("acc_1", "Checking", "depository", "checking", "1234");
    const meta = new PlaidMetadataDTO(inst, [acc], "sess_123");
    expect(meta.institution).toBe(inst);
    expect(meta.accounts).toEqual([acc]);
    expect(meta.link_session_id).toBe("sess_123");

    const link = new PlaidLinkDTO("public-token-123", meta);
    expect(link.publicToken).toBe("public-token-123");
    expect(link.metadata).toBe(meta);
  });
});
