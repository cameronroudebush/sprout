import { Account } from "@backend/account/model/account.model";
import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { Configuration } from "@backend/config/core";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { ProviderType } from "@backend/providers/base/provider.type";
import { ZillowPropertyDTO } from "@backend/providers/zillow/model/api/zillow.lookup.dto";
import { ZillowPropertyResultDto } from "@backend/providers/zillow/model/api/zillow.result.dto";
import { ZillowProviderService } from "@backend/providers/zillow/zillow.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, Body, Controller, Get, InternalServerErrorException, Logger, Param, Post } from "@nestjs/common";
import { ApiBody, ApiCreatedResponse, ApiOkResponse, ApiOperation, ApiParam, ApiTags } from "@nestjs/swagger";

/** This controller provides endpoints for zillow specific functionality */
@Controller("provider/zillow")
@ApiTags("Provider")
@AuthGuard.attach()
@EnabledGuard.attach(Configuration.providers.zillow.enabled)
export class ZillowProviderController {
  private readonly logger = new Logger("provider:controller:zillow");
  constructor(
    private readonly sseService: SSEService,
    private readonly zillowProviderService: ZillowProviderService,
  ) {}

  @Get(":accountId")
  @ApiOperation({
    summary: "Get property info from Zillow",
    description: "Grabs zillow zpid for the given account Id.",
  })
  @ApiOkResponse({ description: "Property Id retrieved successfully.", type: String })
  @ApiParam({ name: "accountId", description: "The ID of the account to lookup", type: String })
  async getByAccount(@CurrentUser() user: User, @Param("accountId") accountId: string) {
    const acc = await Account.findOne({ where: { id: accountId, user: { id: user.id } } });
    if (!acc || !acc.providerAccountId || acc.provider !== ProviderType.zillow) {
      throw new BadRequestException("Account given is not a valid Zillow account.");
    }
    return acc.providerAccountId;
  }

  @Post("lookup")
  @ApiOperation({
    summary: "Get property info from Zillow",
    description: "Grabs data from zillow for Zpid, Zestimate, and Rent Zestimate based on address.",
  })
  @ApiCreatedResponse({ description: "Property data retrieved successfully.", type: ZillowPropertyResultDto })
  @ApiBody({ type: ZillowPropertyDTO })
  @EnabledGuard.attachDemoMode()
  async lookupProperty(@CurrentUser() user: User, @Body() lookupDto: ZillowPropertyDTO) {
    try {
      const { address, city, state, zip } = lookupDto;
      return await this.zillowProviderService.getInfoByAddress(user, address, city, state, zip);
    } catch (error) {
      this.logger.error(error);
      throw new InternalServerErrorException("Failed to fetch property data from Zillow.");
    }
  }

  @Post("link")
  @ApiOperation({
    summary: "Link a Zillow property as an account.",
    description: "Verifies property info and creates a tracked account with Zestimate value.",
  })
  @ApiCreatedResponse({ description: "Zillow property linked successfully.", type: Account })
  @ApiBody({ type: ZillowPropertyDTO })
  @EnabledGuard.attachDemoMode()
  async link(@CurrentUser() user: User, @Body() linkDto: ZillowPropertyDTO): Promise<Account> {
    const { address, city, state, zip } = linkDto;
    // Re-call getPropertyInfo to ensure data integrity
    const propertyInfo = await this.zillowProviderService.getInfoByAddress(user, address, city, state, zip);
    if (!propertyInfo.zpid || propertyInfo.zestimate === null) throw new BadRequestException("Could not verify property information with Zillow.");
    const results = await this.zillowProviderService.exchangeAndCreateAccounts(user, linkDto);
    const createdAccount = results[0]?.account;
    if (!createdAccount) throw new InternalServerErrorException("Failed to link Zillow property.");
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
    return createdAccount;
  }
}
