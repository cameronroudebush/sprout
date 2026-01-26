//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library openapi.api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/account_api.dart';
part 'api/auth_api.dart';
part 'api/cash_flow_api.dart';
part 'api/category_api.dart';
part 'api/config_api.dart';
part 'api/core_api.dart';
part 'api/holding_api.dart';
part 'api/net_worth_api.dart';
part 'api/notification_api.dart';
part 'api/transaction_api.dart';
part 'api/transaction_rule_api.dart';
part 'api/user_api.dart';
part 'api/user_config_api.dart';

part 'model/api_config.dart';
part 'model/account.dart';
part 'model/account_edit_request.dart';
part 'model/account_sub_type_enum.dart';
part 'model/cash_flow_spending.dart';
part 'model/cash_flow_stats.dart';
part 'model/category.dart';
part 'model/category_stats.dart';
part 'model/chart_range_enum.dart';
part 'model/entity_history.dart';
part 'model/entity_history_data_point.dart';
part 'model/firebase_config_dto.dart';
part 'model/firebase_notification_dto.dart';
part 'model/holding.dart';
part 'model/institution.dart';
part 'model/jwt_login_request.dart';
part 'model/model_sync.dart';
part 'model/monthly_category_data.dart';
part 'model/monthly_spending_stats.dart';
part 'model/notification.dart';
part 'model/notification_ssedto.dart';
part 'model/provider_config.dart';
part 'model/refresh_request_dto.dart';
part 'model/refresh_response_dto.dart';
part 'model/register_device_dto.dart';
part 'model/sse_data.dart';
part 'model/sankey_data.dart';
part 'model/sankey_link.dart';
part 'model/total_transactions.dart';
part 'model/transaction.dart';
part 'model/transaction_rule.dart';
part 'model/transaction_subscription.dart';
part 'model/unsecure_app_configuration.dart';
part 'model/unsecure_oidc_config.dart';
part 'model/user.dart';
part 'model/user_config.dart';
part 'model/user_creation_request.dart';
part 'model/user_creation_response.dart';
part 'model/user_login_response.dart';
part 'model/username_password_login_request.dart';


/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) => pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';
