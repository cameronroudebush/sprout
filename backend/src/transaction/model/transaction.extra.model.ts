import { TransactionLocation } from "@backend/transaction/model/transaction.location.model";
import { ApiPropertyOptional } from "@nestjs/swagger";

/** Strongly typed class for the transaction extra JSON column */
export class TransactionExtraData {
  @ApiPropertyOptional({ type: String })
  code?: string | null;

  @ApiPropertyOptional({ type: () => TransactionLocation })
  location?: TransactionLocation | null;

  [key: string]: any;
}
