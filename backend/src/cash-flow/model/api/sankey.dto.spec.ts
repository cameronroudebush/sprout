import { setupTests } from "@backend/test/helpers";
setupTests();

import { SankeyData, SankeyLink } from "@backend/cash-flow/model/api/sankey.dto";

describe("Sankey DTOs", () => {
  describe("SankeyLink", () => {
    it("should instantiate with source, target, value, description", () => {
      const link = new SankeyLink("Salary", "Checking", 2000, "Monthly Salary");
      expect(link.source).toBe("Salary");
      expect(link.target).toBe("Checking");
      expect(link.value).toBe(2000);
      expect(link.description).toBe("Monthly Salary");
    });
  });

  describe("SankeyData", () => {
    it("should instantiate with nodes, links, colors", () => {
      const link = new SankeyLink("Salary", "Checking", 2000);
      const data = new SankeyData(["Salary", "Checking"], [link], { Salary: "#00FF00" });

      expect(data.nodes).toEqual(["Salary", "Checking"]);
      expect(data.links).toHaveLength(1);
      expect(data.colors["Salary"]).toBe("#00FF00");
    });
  });
});
