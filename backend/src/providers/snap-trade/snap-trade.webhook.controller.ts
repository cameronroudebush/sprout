import { Configuration } from "@backend/config/core";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { ProviderSyncService } from "@backend/providers/base/sync.service";
import { SnapTradeInstitutionAsset } from "@backend/providers/snap-trade/model/snap-trade.institution.asset.model";
import { SnapTradeProviderService } from "@backend/providers/snap-trade/snap-trade.provider.service";
import { BadRequestException, Body, Controller, Headers, Logger, Post, RawBodyRequest, Req, UnauthorizedException } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import crypto from "crypto";

/** Controller that allows snap-trade to inform us of webhook updates. */
@Controller("webhooks/snap-trade")
@ApiTags("Webhook")
@EnabledGuard.attach(Configuration.providers.snapTrade.enabled)
export class SnapTradeWebHookController {
  private readonly logger = new Logger("provider:snapTrade:controller:webhook");

  constructor(
    private readonly snapTradeProvider: SnapTradeProviderService,
    private readonly providerSyncService: ProviderSyncService,
  ) {}

  @Post()
  @ApiOperation({
    summary: "Handle SnapTrade update webhook",
    description:
      "Used to listen for responses from SnapTrade to trigger automatic account syncs. This allows out-of-band syncing, not requiring a job to perform the update.",
  })
  @EnabledGuard.attachDemoMode()
  async handleSnapTradeWebhook(@Headers() headers: Record<string, string>, @Req() req: RawBodyRequest<Request>, @Body() payload: any) {
    // Express lowercases header keys in the headers object
    const signature = headers["signature"];
    const rawBody = req.rawBody?.toString();

    if (!signature) {
      this.logger.warn("Received webhook missing signature header.");
      throw new BadRequestException("Missing verification signature");
    }

    if (!rawBody) {
      this.logger.error("Raw body string missing from request buffer parser.");
      throw new BadRequestException("Internal configuration error");
    }

    // Validate HMAC SHA256 signature
    const isValid = this.verifyWebhookSignature(rawBody, signature);
    if (!isValid) {
      this.logger.error("Webhook signature verification failed.");
      throw new UnauthorizedException("Invalid webhook signature");
    }

    // Handle what to do with our webhook. Don't await so SnapTrade knows we received it immediately.
    this.handleWebhook(payload);

    // Tell SnapTrade this was successful
    return { status: "received" };
  }

  /** Handles what to do with incoming webhooks. */
  private async handleWebhook(payload: any) {
    const eventType = payload.eventType;
    const authId = payload.brokerageAuthorizationId;

    if (!authId) {
      this.logger.warn(`Webhook received without a brokerageAuthorizationId: ${eventType}`);
      return;
    }

    try {
      switch (eventType) {
        case "TRANSACTIONS_SYNC_COMPLETED":
        case "CONNECTION_UPDATED":
        case "CONNECTION_ADDED": {
          const asset = await this.getSnapTradeInstitutionAsset(authId);
          const user = asset.institution.user;
          this.logger.log(`Queueing Webhook based sync for: ${user.username} [${eventType}]`);
          await this.providerSyncService.syncForProvider(user, this.snapTradeProvider, false, asset.institution.id);
          break;
        }

        case "CONNECTION_BROKEN": { //case "CONNECTION_DELETED":
          const asset = await this.getSnapTradeInstitutionAsset(authId);
          this.logger.log(`Flagging institution as broken: [${eventType}]`);
          await this.providerSyncService.flagInstitution(asset.institution, true);
          break;
        }

        default:
          this.logger.log(`Ignoring unknown webhook type: ${eventType}`);
      }
    } catch (e) {
      this.logger.error(`Failed to execute webhook handler`, e);
    }
  }

  /** Given the payload auth ID, returns the institution asset, throws an error if it doesn't exist */
  private async getSnapTradeInstitutionAsset(authId: string) {
    const asset = await SnapTradeInstitutionAsset.findOne({
      where: { authorizationId: authId },
      relations: { institution: { user: true } },
    });

    if (!asset) throw new BadRequestException(`Failed to locate matching institution to update: ${authId}`);
    return asset;
  }

  /** Verifies the webhook came from SnapTrade using HMAC SHA256 */
  private verifyWebhookSignature(rawBody: string, signature: string): boolean {
    try {
      const consumerKey = Configuration.providers.snapTrade.consumerKey;
      if (!consumerKey) return false;
      const hmac = crypto.createHmac("sha256", consumerKey);
      hmac.update(rawBody);
      const calculatedSignature = hmac.digest("base64");
      return crypto.timingSafeEqual(Buffer.from(calculatedSignature, "utf8"), Buffer.from(signature, "utf8"));
    } catch (err) {
      this.logger.error("Unexpected error occurred inside webhook verification pipeline", err);
      return false;
    }
  }
}
