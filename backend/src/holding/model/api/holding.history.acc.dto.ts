import { EntityHistory } from "@backend/core/model/api/entity.history.dto";
import { Base } from "@backend/core/model/base";
import { ApiProperty, getSchemaPath } from "@nestjs/swagger";

/** This class represents all holding histories by each account as a key */
export class HoldingHistoryByAccount extends Base {
  @ApiProperty({
    type: "object",
    additionalProperties: {
      type: "array",
      items: { $ref: getSchemaPath(EntityHistory) },
    },
  })
  history: Map<String, Array<EntityHistory>>;

  constructor(history: Map<String, Array<EntityHistory>>) {
    super();
    this.history = history;
  }
}
