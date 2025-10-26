import { Base } from "@backend/core/model/base";
import { ApiProperty } from "@nestjs/swagger";

/** Represents a link in a Sankey diagram, showing the flow of value from a source to a target. */
export class SankeyLink extends Base {
  source: string;
  target: string;
  value: number;
  /** A way to help describe what this link is */
  description?: string;

  constructor(source: string, target: string, value: number, description?: string) {
    super();
    this.source = source;
    this.target = target;
    this.value = value;
    this.description = description;
  }
}

/** Represents the complete dataset for a Sankey diagram, including all nodes and links. */
export class SankeyData extends Base {
  nodes: string[];
  links: SankeyLink[];
  @ApiProperty({
    type: "object",
    additionalProperties: { type: "string" },
  })
  colors: Record<string, string>;

  constructor(nodes: string[], links: SankeyLink[], colors: SankeyData["colors"]) {
    super();
    this.nodes = nodes;
    this.links = links;
    this.colors = colors;
  }

  /** The color to use for deficits */
  static deficitColor = "#E31A1C";
  /** Color to use only for income main column */
  static incomeColor = "#A6CEE3";
  /** Color to use only for excess money of net flow */
  static excessColor = "#33A02C";

  /** Color options that can be used for the links */
  static colors = [
    "#1F78B4",
    "#B2DF8A",
    "#FB9A99",
    "#FDBF6F",
    "#FF7F00",
    "#CAB2D6",
    "#6A3D9A",
    "#FFFF99",
    "#B15928",
    "#3F51B5",
    "#009688",
    "#FF9800",
    "#E91E63",
    "#8BC34A",
    "#9C27B0",
    "#795548",
    "#CDDC39",
    "#A52A2A",
    "#800000",
    "#FFD700",
    "#DAA520",
    "#ADFF2F",
    "#7FFF00",
    "#20B2AA",
    "#008B8B",
    "#4682B4",
    "#6A5ACD",
    "#8A2BE2",
    "#BA55D3",
    "#FF69B4",
    "#FF1493",
    "#FF4500",
    "#FF8C00",
    "#FFDAB9",
  ];
}
