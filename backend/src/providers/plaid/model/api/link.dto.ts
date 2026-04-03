import { ApiProperty } from "@nestjs/swagger";
import { Type } from "class-transformer";
import { IsArray, IsNotEmpty, IsOptional, IsString, ValidateNested } from "class-validator";

export class PlaidAccountDTO {
  @ApiProperty()
  @IsString()
  id: string;

  @ApiProperty()
  @IsString()
  name: string;

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  mask?: string;

  @ApiProperty()
  @IsString()
  type: string;

  @ApiProperty()
  @IsString()
  subtype: string;

  constructor(id: string, name: string, type: string, subtype: string, mask?: string) {
    this.id = id;
    this.name = name;
    this.type = type;
    this.subtype = subtype;
    this.mask = mask;
  }
}

export class PlaidInstitutionDTO {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  institution_id: string;

  constructor(name: string, institution_id: string) {
    this.name = name;
    this.institution_id = institution_id;
  }
}

export class PlaidMetadataDTO {
  @ApiProperty({ type: PlaidInstitutionDTO })
  @ValidateNested()
  @Type(() => PlaidInstitutionDTO)
  institution: PlaidInstitutionDTO;

  @ApiProperty({ type: [PlaidAccountDTO] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => PlaidAccountDTO)
  accounts: PlaidAccountDTO[];

  @ApiProperty()
  @IsString()
  link_session_id: string;

  constructor(institution: PlaidInstitutionDTO, accounts: PlaidAccountDTO[], link_session_id: string) {
    this.institution = institution;
    this.accounts = accounts;
    this.link_session_id = link_session_id;
  }
}

export class PlaidLinkDTO {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  publicToken: string;

  @ApiProperty({ type: PlaidMetadataDTO })
  @ValidateNested()
  @Type(() => PlaidMetadataDTO)
  metadata: PlaidMetadataDTO;

  constructor(publicToken: string, metadata: PlaidMetadataDTO) {
    this.publicToken = publicToken;
    this.metadata = metadata;
  }
}
