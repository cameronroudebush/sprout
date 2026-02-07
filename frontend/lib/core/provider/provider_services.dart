import 'package:sprout/account/account_provider.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/chat/chat_provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/sse.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/transaction-rule/transaction_rule.provider.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/user/user_config_provider.dart';
import 'package:sprout/user/user_provider.dart';

/// A mixin that makes it much simpler to use providers across the app
mixin SproutProviders {
  // ===========================================================================
  // Instance Accessors (The Mixin part)
  // Usage: class MyState extends State... with SproutProviders { ... authProvider.login() }
  // ===========================================================================
  AuthProvider get authProvider => SproutProviders.auth;
  NotificationProvider get notificationProvider => SproutProviders.notification;
  UserProvider get userProvider => SproutProviders.user;
  UserConfigProvider get userConfigProvider => SproutProviders.userConfig;
  ConfigProvider get configProvider => SproutProviders.config;
  AccountProvider get accountProvider => SproutProviders.account;
  SSEProvider get sseProvider => SproutProviders.sse;
  NetWorthProvider get netWorthProvider => SproutProviders.netWorth;
  TransactionProvider get transactionProvider => SproutProviders.transaction;
  TransactionRuleProvider get transactionRuleProvider => SproutProviders.transactionRule;
  CategoryProvider get categoryProvider => SproutProviders.category;
  HoldingProvider get holdingProvider => SproutProviders.holding;
  CashFlowProvider get cashFlowProvider => SproutProviders.cashFlow;
  ChatProvider get chatProvider => SproutProviders.chat;
  BiometricProvider get biometricProvider => SproutProviders.bio;

  // ===========================================================================
  // Static Accessors
  // Usage: SproutProviders.authProviderS.login(...)
  // ===========================================================================
  static AuthProvider get auth => ServiceLocator.get<AuthProvider>();
  static NotificationProvider get notification => ServiceLocator.get<NotificationProvider>();
  static UserProvider get user => ServiceLocator.get<UserProvider>();
  static UserConfigProvider get userConfig => ServiceLocator.get<UserConfigProvider>();
  static ConfigProvider get config => ServiceLocator.get<ConfigProvider>();
  static AccountProvider get account => ServiceLocator.get<AccountProvider>();
  static SSEProvider get sse => ServiceLocator.get<SSEProvider>();
  static NetWorthProvider get netWorth => ServiceLocator.get<NetWorthProvider>();
  static TransactionProvider get transaction => ServiceLocator.get<TransactionProvider>();
  static TransactionRuleProvider get transactionRule => ServiceLocator.get<TransactionRuleProvider>();
  static CategoryProvider get category => ServiceLocator.get<CategoryProvider>();
  static HoldingProvider get holding => ServiceLocator.get<HoldingProvider>();
  static CashFlowProvider get cashFlow => ServiceLocator.get<CashFlowProvider>();
  static ChatProvider get chat => ServiceLocator.get<ChatProvider>();
  static BiometricProvider get bio => ServiceLocator.get<BiometricProvider>();
}
