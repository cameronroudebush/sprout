/**
 * This class provides colors for use in cash flow display charts
 *
 * We use an internal mapping where we map features (categories) to specific colors
 *  so they are consistent across usage.
 */
export class Colors {
  /** The color to use for deficits */
  static deficitColor = "#E31A1C";
  /** Color to use only for income main column */
  static incomeColor = "#A6CEE3";
  /** Color to use only for excess money of net flow */
  static excessColor = "#33A02C";

  /** Internal storage to map features to specific colors */
  private static featureColorMap: Map<string, string> = new Map();

  /** Color options that can be used for the links */
  //prettier-ignore
  static colors = [
    "#1F78B4", "#B2DF8A", "#FB9A99", "#FDBF6F", "#FF7F00",
    "#CAB2D6", "#6A3D9A", "#FFFF99", "#B15928", "#3F51B5",
    "#009688", "#FF9800", "#E91E63", "#8BC34A", "#9C27B0",
    "#795548", "#CDDC39", "#A52A2A", "#800000", "#FFD700",
    "#DAA520", "#ADFF2F", "#7FFF00", "#20B2AA", "#008B8B",
    "#4682B4", "#6A5ACD", "#8A2BE2", "#BA55D3", "#FF69B4",
    "#FF1493", "#FF4500", "#FF8C00", "#FFDAB9",
  ];

  /**
   * Returns a consistent color for a given feature name.
   * If the feature has been seen before, it returns the same color.
   * @param feature - The unique string key (e.g., "Housing", "Salary")
   */
  static getColorForFeature(feature: string): string {
    if (this.featureColorMap.has(feature)) return this.featureColorMap.get(feature)!;

    // Assign a new color based on the current number of mapped features
    const colorIndex = this.featureColorMap.size % this.colors.length;
    const selectedColor = this.colors[colorIndex]!;

    // Store and return
    this.featureColorMap.set(feature, selectedColor);
    return selectedColor;
  }

  /** Optional: Clear the map if you need to reset assignments (e.g., on page navigation) */
  static resetFeatureColors(): void {
    this.featureColorMap.clear();
  }
}
