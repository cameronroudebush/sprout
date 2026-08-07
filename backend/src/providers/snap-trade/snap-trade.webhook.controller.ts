import { Configuration } from "@backend/config/core";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { Controller } from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";

// TODO: Webhook support.
/** Controller that allows snap-trade to inform us of webhook updates. */
@Controller("webhooks/snap-trade")
@ApiTags("Webhook")
@EnabledGuard.attach(Configuration.providers.snapTrade.enabled)
export class SnapTradeWebHookController {
  constructor() {}

  //   @Post()
  // @HttpCode(200)
  // async handleSnapTradeWebhook(
  //   @Req() req: RawBodyRequest<Request>,
  //   @Headers("Signature") signature: string,
  //   @Body() payload: any,
  // ) {
  //   // 1. Validate HMAC SHA256 signature using your SNAPTRADE_CONSUMER_KEY
  //   const isValid = this.snapTradeProviderService.verifyWebhookSignature(req.rawBody, signature);
  //   if (!isValid) throw new UnauthorizedException("Invalid webhook signature");

  //   // 2. Process event types
  //   switch (payload.eventType) {
  //     case "CONNECTION_ADDED": {
  //       // payload contains: userId, brokerageId, brokerageAuthorizationId
  //       const { userId, brokerageAuthorizationId } = payload;
  //       await this.snapTradeProviderService.handleNewConnection(userId, brokerageAuthorizationId);
  //       break;
  //     }
  //     case "CONNECTION_DELETED":
  //     case "CONNECTION_BROKEN": {
  //       // Handle connection removals or disabled credentials
  //       break;
  //     }
  //   }

  //   return { status: "success" };
  // }

  //   verifyWebhookSignature(rawBody: Buffer, signature: string): boolean {
  //   const consumerKey = Configuration.providers.snapTrade.consumerKey;
  //   const hmac = crypto.createHmac("sha256", consumerKey);
  //   hmac.update(rawBody);
  //   const calculatedSignature = hmac.digest("base64");
  //   return calculatedSignature === signature;
  // }
}
