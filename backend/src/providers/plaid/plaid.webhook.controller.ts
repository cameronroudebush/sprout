import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { Configuration } from "@backend/config/core";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { ProviderSyncService } from "@backend/providers/base/sync.service";
import { PlaidInstitutionAsset } from "@backend/providers/plaid/model/plaid.institution.asset";
import { PlaidProviderService } from "@backend/providers/plaid/plaid.provider.service";
import { User } from "@backend/user/model/user.model";
import {
  BadRequestException,
  Body,
  Controller,
  Headers,
  HttpCode,
  HttpStatus,
  Logger,
  Post,
  Put,
  RawBodyRequest,
  Req,
  UnauthorizedException,
} from "@nestjs/common";
import { ApiBody, ApiOperation, ApiTags } from "@nestjs/swagger";
import crypto from "crypto";
import { Request } from "express";
import jwt from "jsonwebtoken";
import { JWKPublicKey, WebhookUpdateAcknowledgedWebhook } from "plaid";

/** Controller that allow plaid to communicate directly with the backend to trigger auto updates. */
@Controller("webhooks/plaid")
@ApiTags("Webhook")
@EnabledGuard.attach(Configuration.providers.plaid.enabled)
export class PlaidWebhookController {
  private readonly logger = new Logger("provider:plaid:controller:webhook");
  /** Cached signed key to not over-request to verify plaid webhooks */
  private cachedKey?: JWKPublicKey;
  constructor(
    private readonly plaidProvider: PlaidProviderService,
    private readonly providerSyncService: ProviderSyncService,
  ) {}

  @Post()
  @ApiOperation({
    summary: "Handle plaid update webhook",
    description:
      "Used to listen for responses from plaid to trigger automatic account syncs. This allows out-of-band syncing, not requiring a job to perform the update.",
  })
  @EnabledGuard.attachDemoMode()
  async handlePlaidWebhook(@Headers() headers: Record<string, string>, @Req() req: RawBodyRequest<Request>, @Body() payload: WebhookUpdateAcknowledgedWebhook) {
    const signedJwt = headers["plaid-verification"] || headers["plaid-verification-signature"];
    const rawBody = req.rawBody?.toString();
    if (!signedJwt) {
      this.logger.warn("Received webhook missing signature header.");
      throw new BadRequestException("Missing verification signature");
    }
    if (!rawBody) {
      this.logger.error("Raw body string missing from request buffer parser.");
      throw new BadRequestException("Internal configuration error");
    }

    // Validate the webhook actually came from Plaid
    const isValid = await this.verifyPlaidWebhook(rawBody, signedJwt);
    if (!isValid) {
      this.logger.error("Webhook signature verification failed.");
      throw new BadRequestException("Invalid webhook signature");
    }
    // Don't await so plaid isn't waiting on us.
    this.handleWebhook(payload);
    return { status: "received" };
  }

  @Put("migrate-url")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: "Bulk update all registered Plaid webhooks",
    description:
      "Iterates through all database items and pushes the updated webhook destination url to Plaid's servers. This is useful if you change where your server is located.",
  })
  @ApiBody({
    schema: {
      type: "object",
      properties: {
        baseUrl: { type: "string", example: "https://new-domain.com" },
      },
      required: ["baseUrl"],
    },
  })
  @AuthGuard.attach()
  @EnabledGuard.attachDemoMode()
  async migrateWebhookUrls(@CurrentUser() user: User, @Body("baseUrl") baseUrl: string) {
    if (!user.admin) throw new UnauthorizedException("You must be an admin to perform this capability.");
    if (!baseUrl || !baseUrl.startsWith("http")) throw new BadRequestException("A valid base URL starting with http/https is required.");
    // Strips trailing slashes cleanly if provided to prevent double-slashes in the service map
    const sanitizedBaseUrl = baseUrl.replace(/\/+$/, "");
    const results = await this.plaidProvider.updateAllItemWebhooks(sanitizedBaseUrl);
    return {
      message: "Webhook migration sequence complete.",
      ...results,
    };
  }

  /** Handles the webhook by calling the proper sync state. */
  private async handleWebhook(payload: WebhookUpdateAcknowledgedWebhook) {
    const { webhook_type, item_id } = payload;
    if (!item_id) return;
    const instAsset = await PlaidInstitutionAsset.findOne({
      where: { itemId: item_id },
      relations: { institution: { user: true } },
    });
    if (!instAsset) {
      this.logger.warn(`Failed to locate matching institution to update: ${item_id}`);
      return;
    }
    const user = instAsset.institution.user;
    try {
      this.logger.log(`Queueing sync task via orchestrator for user: ${instAsset.institution.user.username} [${webhook_type}]`);
      await this.providerSyncService.syncForProvider(user, this.plaidProvider, false);
    } catch (error) {
      this.logger.error(`Failed to execute webhook handler`, error);
    }
  }

  /** Verifies the webhook came from plaid. */
  private async verifyPlaidWebhook(body: string, signedJwt: string): Promise<boolean> {
    try {
      const decoded = jwt.decode(signedJwt, { complete: true });
      if (!decoded || typeof decoded === "string" || !decoded.header?.kid) return false;
      const currentKeyID = decoded.header.kid;
      if (!this.cachedKey)
        try {
          const response = await this.plaidProvider.plaidClient.webhookVerificationKeyGet({
            key_id: currentKeyID,
          });
          this.cachedKey = response.data.key;
        } catch (error) {
          this.logger.error("Failed to fetch verification key from API", error);
          return false;
        }
      if (!this.cachedKey) return false;
      const publicKey = crypto.createPublicKey({
        key: this.cachedKey,
        format: "jwk",
      });
      let decodedPayload: { request_body_sha256: string };
      try {
        decodedPayload = jwt.verify(signedJwt, publicKey, {
          maxAge: "5 min",
          algorithms: ["ES256"],
        }) as any;
      } catch (error) {
        this.logger.warn(`JWT verification failed: ${error}`);
        return false;
      }
      const computedHash = crypto.createHash("sha256").update(body).digest("hex");
      const claimedBodyHash = decodedPayload.request_body_sha256;
      if (!claimedBodyHash) return false;
      return crypto.timingSafeEqual(Buffer.from(computedHash, "utf8"), Buffer.from(claimedBodyHash, "utf8"));
    } catch (err) {
      this.logger.error("Unexpected error occurred inside webhook verification pipeline", err);
      return false;
    }
  }
}
