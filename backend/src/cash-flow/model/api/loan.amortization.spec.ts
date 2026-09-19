import { setupTests } from "@backend/test/helpers";
setupTests();

import { LoanAmortizationSeries } from "@backend/cash-flow/model/api/loan.amortization";
import { HistoricalDataPoint } from "@backend/net-worth/model/api/entity.history.dto";

describe("LoanAmortizationSeries", () => {
  it("should instantiate with proper fields", () => {
    const dataPoints = [new HistoricalDataPoint(new Date(), -5000)];
    const series = new LoanAmortizationSeries("acc-1", "Car Loan", 24, 250, "#FF0000", dataPoints);

    expect(series.accountId).toBe("acc-1");
    expect(series.accountName).toBe("Car Loan");
    expect(series.monthsToPayOff).toBe(24);
    expect(series.monthlyPayment).toBe(250);
    expect(series.color).toBe("#FF0000");
    expect(series.dataPoints).toBe(dataPoints);
  });
});
