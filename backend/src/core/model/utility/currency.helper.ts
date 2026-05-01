import { CustomTypes } from "@backend/core/model/utility/custom.types";
import { ClassTransformerUserContext } from "@backend/core/serializer/user.context.serializer";
import { CurrencyOptions } from "@backend/user/model/user.config.model";
import { User } from "@backend/user/model/user.model";
import { Logger } from "@nestjs/common";
import { ApiProperty } from "@nestjs/swagger";
import { Transform } from "class-transformer";
import { get } from "lodash";

/** This class provides formatting help to convert currencies between one another and format them into strings. */
export class CurrencyHelper {
  private static readonly logger = new Logger("currency-helper");
  /** What currency option we should fallback to if we can't determine one from the source */
  protected static readonly FallbackCurrency = CurrencyOptions.USD;
  /** Exchange rates populated by a background job */
  static exchangeRates = new Map<string, Map<string, number>>();

  /**
   * This decorator is used to override the source property (the finance amount, like an account balance) to set it to a specific
   *  target currency specified by the user config from the currencyProperty. This will flat out override the source property when
   *  sent across the API. So the backend will maintain the currency format that is configured by the user, but the backend will have the
   *  ability to see what the actual value is, pre currency format change.
   *
   * You should hide your currencyProperty from the output since it will no longer be relevant across the API.
   * @param sourceProperty The property that contains the source numeric value (think account balance).
   * @param currencyProperty The property that contains what currency the source numeric value is (so an account balance could be in EUR for one account and USD in another).
   */
  static ExposeCurrencyFields<T>(sourceProperty: CustomTypes.PropertyNames<T, number>, currencyProperty: CustomTypes.PropertyPaths<T>): ClassDecorator {
    return function (constructor: Function) {
      const target = constructor.prototype;
      const targetKey = sourceProperty as string;
      // Define the Swagger/OpenAPI documentation
      ApiProperty({
        type: "number",
        required: true,
        nullable: false,
        description: `The numeric value converted to the user's preferred currency format. This overrides the original ${targetKey} property.`,
      })(target, targetKey);
      // Transform logic: Convert the amount and replace the property
      Transform(
        ({ obj, options }) => {
          const originalAmount = obj[targetKey];
          if (originalAmount === undefined || originalAmount === null) return null;
          const user = (options as ClassTransformerUserContext)?.context?.user;
          const sourceCurrency = get(obj, currencyProperty) ?? CurrencyHelper.FallbackCurrency;
          const targetCurrency = user?.config.currency ?? CurrencyHelper.FallbackCurrency;
          return CurrencyHelper.convert(originalAmount, sourceCurrency, targetCurrency);
        },
        { toPlainOnly: true },
      )(target, targetKey);
    };
  }

  /** Used to convert between two different currencies */
  static convert(amount: number, from: string, to: string): number {
    if (from === to) return amount;
    if (amount == null || amount === 0) return 0;
    const rate = CurrencyHelper.exchangeRates.get(from)?.get(to);
    if (rate === undefined) {
      this.logger.warn(`Failed to locate a matching currency map from ${from} to ${to}. You should report this to the developer.`);
      return 0;
    }
    return amount * rate;
  }

  /**
   * Formats the financial amount to the target currency formatter for our current user.
   *
   * ***This expects the amount to already be converted***
   */
  static format(amount: number, user: User, digits = 2) {
    const targetCurrency = user?.config.currency ?? CurrencyHelper.FallbackCurrency;
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: targetCurrency,
      minimumFractionDigits: digits,
      maximumFractionDigits: digits,
    }).format(amount);
  }

  /**
   * Manually converts a list of items to a target currency. This is used normally for internal
   *  use as the API requests should automatically do the conversion via {@link CurrencyHelper.ExposeCurrencyFields}.
   *
   * **This function edits in place so it will replace the properties you specify.**
   */
  static convertList<T>(
    items: T[],
    sourceProperties: CustomTypes.PropertyNames<T, number> | Array<CustomTypes.PropertyNames<T, number>>,
    currencyPath: CustomTypes.PropertyPaths<T>,
    user: User,
  ) {
    const props = Array.isArray(sourceProperties) ? sourceProperties : [sourceProperties];
    items.forEach((item) => {
      const sourceCurrency = (get(item, currencyPath) ?? CurrencyHelper.FallbackCurrency) as string;
      // Update each property
      props.forEach((prop) => {
        const amount = item[prop] as unknown as number;
        const targetCurrency = user?.config.currency ?? CurrencyHelper.FallbackCurrency;
        const converted = CurrencyHelper.convert(amount, sourceCurrency, targetCurrency);
        (item as any)[prop] = converted;
      });
    });
    return items;
  }
}
