import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { Institution } from "@backend/institution/model/institution.model";
import { ProviderType } from "@backend/providers/base/provider.type";
import { ZillowPropertyDTO } from "@backend/providers/zillow/model/api/zillow.lookup.dto";
import { ZillowPropertyResultDto } from "@backend/providers/zillow/model/api/zillow.result.dto";
import { ZillowAsset } from "@backend/providers/zillow/model/zillow.asset";
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
export class ZillowProviderController {
  private readonly logger = new Logger("provider:controller:zillow");
  constructor(
    private readonly sseService: SSEService,
    private readonly zillowProviderService: ZillowProviderService,
  ) {}

  @Get(":accountId")
  @ApiOperation({
    summary: "Get property info from Zillow",
    description: "Grabs zillow asset data based on the account given.",
  })
  @ApiOkResponse({ description: "Property data retrieved successfully.", type: ZillowAsset })
  @ApiParam({ name: "accountId", description: "The ID of the account to lookup", type: String })
  async getByAccount(@CurrentUser() user: User, @Param("accountId") accountId: string) {
    return await ZillowAsset.findOne({ where: { account: { id: accountId, user: { id: user.id } } } });
  }

  @Post("lookup")
  @ApiOperation({
    summary: "Get property info from Zillow",
    description: "Grabs data from zillow for Zpid, Zestimate, and Rent Zestimate based on address.",
  })
  @ApiCreatedResponse({ description: "Property data retrieved successfully.", type: ZillowPropertyResultDto })
  @ApiBody({ type: ZillowPropertyDTO })
  async lookupProperty(@CurrentUser() user: User, @Body() lookupDto: ZillowPropertyDTO) {
    let data: Awaited<ReturnType<ZillowProviderService["getInfoByAddress"]>> | undefined;
    try {
      const { address, city, state, zip } = lookupDto;
      data = await this.zillowProviderService.getInfoByAddress(user, address, city, state, zip);
    } catch (error) {
      this.logger.error(error);
      throw new InternalServerErrorException("Failed to fetch property data from Zillow.");
    }
    // 35072756 Seems to be the default zpid when no property is found
    if (data == null || data.zpid == null || data.zpid === "35072756") throw new BadRequestException("Failed to locate the property on zillow.");
    return data;
  }

  @Post("link")
  @ApiOperation({
    summary: "Link a Zillow property as an account.",
    description: "Verifies property info and creates a tracked account with Zestimate value.",
  })
  @ApiCreatedResponse({ description: "Zillow property linked successfully.", type: Account })
  @ApiBody({ type: ZillowPropertyDTO })
  async link(@CurrentUser() user: User, @Body() linkDto: ZillowPropertyDTO): Promise<Account> {
    const { address, city, state, zip } = linkDto;

    // Re-call getPropertyInfo to ensure data integrity
    const propertyInfo = await this.zillowProviderService.getInfoByAddress(user, address, city, state, zip);

    if (!propertyInfo.zpid || propertyInfo.zestimate === null) {
      throw new BadRequestException("Could not verify property information with Zillow.");
    }

    // Create or find the institution which we just track as zillow
    const defaultInstitution = new Institution(this.zillowProviderService.config.url, "Zillow", false, user);
    let institution = await Institution.findOne({ where: { user: { id: user.id }, name: defaultInstitution.name } });
    if (!institution) institution = defaultInstitution;

    // Create the Account
    const newAccount = await new Account(
      address,
      ProviderType.zillow,
      user,
      institution,
      propertyInfo.zestimate,
      0,
      AccountType.asset,
      "USD",
      AccountSubType.house,
    ).insert();
    // Link Zillow Metadata to the account
    await new ZillowAsset(newAccount, propertyInfo.zpid).insert();
    // Insert one day old history
    AccountHistory.insertForNewAccount(newAccount);
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
    return newAccount;
  }
}
