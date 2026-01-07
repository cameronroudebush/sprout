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
}
