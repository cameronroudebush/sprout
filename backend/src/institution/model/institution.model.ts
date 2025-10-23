import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";

@DatabaseDecorators.entity()
export class Institution extends DatabaseBase {
  /** The URL for where this institution is */
  @DatabaseDecorators.column({ nullable: false })
  url: string;
  @DatabaseDecorators.column({ nullable: false })
  name: string;
  /** If this institution has connection errors and needs fixed */
  @DatabaseDecorators.column({ nullable: false })
  hasError: boolean;

  constructor(url: string, name: string, hasError: boolean) {
    super();
    this.url = url;
    this.name = name;
    this.hasError = hasError;
  }
}
