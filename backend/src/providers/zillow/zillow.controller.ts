import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { ZillowProviderService } from "@backend/providers/zillow/zillow.provider.service";
import { Controller } from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";

/**
 * This controller provides the endpoint for all Account related content
 */
@Controller("provider/zillow")
@ApiTags("Provider")
@AuthGuard.attach()
export class ZillowProviderController {
  constructor(private readonly zillowProviderService: ZillowProviderService) {
    console.log(this.zillowProviderService);
  }
}
