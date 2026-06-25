import { ApiPropertyOptional } from "@nestjs/swagger";

/** Represents location metadata occasionally provided by providers */
export class TransactionLocation {
  @ApiPropertyOptional({ type: String })
  address?: string | null;

  @ApiPropertyOptional({ type: String })
  city?: string | null;

  @ApiPropertyOptional({ type: String })
  country?: string | null;

  @ApiPropertyOptional({ type: Number })
  lat?: number | null;

  @ApiPropertyOptional({ type: Number })
  lon?: number | null;

  @ApiPropertyOptional({ type: String })
  postal_code?: string | null;

  @ApiPropertyOptional({ type: String })
  region?: string | null;

  @ApiPropertyOptional({ type: String })
  store_number?: string | null;
}
