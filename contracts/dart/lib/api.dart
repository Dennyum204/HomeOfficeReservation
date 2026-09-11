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

part 'api/access_api.dart';
part 'api/auth_api.dart';
part 'api/notifications_api.dart';
part 'api/planning_api.dart';
part 'api/workspace_api.dart';

part 'model/accept_proposal_input.dart';
part 'model/access_token_response.dart';
part 'model/assigned_task_state.dart';
part 'model/availability.dart';
part 'model/calendar_view.dart';
part 'model/comment_input.dart';
part 'model/comment_page.dart';
part 'model/comment_view.dart';
part 'model/complete_account_request.dart';
part 'model/credentials.dart';
part 'model/csrf_token.dart';
part 'model/date_preview.dart';
part 'model/day_decision.dart';
part 'model/day_input.dart';
part 'model/decision_input.dart';
part 'model/device_receipt_input.dart';
part 'model/device_registration_input.dart';
part 'model/device_registration_view.dart';
part 'model/draft_input.dart';
part 'model/effective_day.dart';
part 'model/email_request.dart';
part 'model/invitation_change_request.dart';
part 'model/invitation_page.dart';
part 'model/invitation_profile.dart';
part 'model/member_list.dart';
part 'model/member_profile.dart';
part 'model/mutation_receipt.dart';
part 'model/notification_capabilities.dart';
part 'model/notification_context.dart';
part 'model/notification_count.dart';
part 'model/notification_destination.dart';
part 'model/notification_operations.dart';
part 'model/notification_page.dart';
part 'model/notification_read_input.dart';
part 'model/notification_view.dart';
part 'model/onsite_acknowledge_input.dart';
part 'model/onsite_conflict.dart';
part 'model/onsite_input.dart';
part 'model/onsite_page.dart';
part 'model/onsite_preview.dart';
part 'model/onsite_state.dart';
part 'model/onsite_view.dart';
part 'model/pattern_input.dart';
part 'model/pattern_page.dart';
part 'model/pattern_view.dart';
part 'model/pending_day.dart';
part 'model/preview_day.dart';
part 'model/problem_details.dart';
part 'model/proposal_input.dart';
part 'model/proposal_page.dart';
part 'model/proposal_state.dart';
part 'model/proposal_view.dart';
part 'model/provision_member_request.dart';
part 'model/push_provider.dart';
part 'model/refresh_request.dart';
part 'model/request_page.dart';
part 'model/request_state.dart';
part 'model/request_view.dart';
part 'model/requested_day_view.dart';
part 'model/retry_notification_input.dart';
part 'model/selected_day.dart';
part 'model/set_manager_request.dart';
part 'model/submit_input.dart';
part 'model/task_input.dart';
part 'model/task_page.dart';
part 'model/task_progress_input.dart';
part 'model/task_view.dart';
part 'model/update_member_request.dart';
part 'model/withdraw_input.dart';
part 'model/work_comment_input.dart';
part 'model/work_context.dart';
part 'model/work_entry_page.dart';
part 'model/work_entry_view.dart';
part 'model/work_location.dart';
part 'model/work_version_input.dart';
part 'model/workspace_info.dart';


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
