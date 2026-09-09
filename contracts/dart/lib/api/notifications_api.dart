//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class NotificationsApi {
  NotificationsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'GET /api/v1/notifications/{notificationId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] notificationId (required):
  Future<Response> getNotificationWithHttpInfo(String notificationId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/notifications/{notificationId}'
      .replaceAll('{notificationId}', notificationId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Parameters:
  ///
  /// * [String] notificationId (required):
  Future<NotificationView?> getNotification(String notificationId, { Future<void>? abortTrigger, }) async {
    final response = await getNotificationWithHttpInfo(notificationId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'NotificationView',) as NotificationView;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/notifications/capabilities' operation and returns the [Response].
  Future<Response> getNotificationCapabilitiesWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/notifications/capabilities';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  Future<NotificationCapabilities?> getNotificationCapabilities({ Future<void>? abortTrigger, }) async {
    final response = await getNotificationCapabilitiesWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'NotificationCapabilities',) as NotificationCapabilities;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/notifications/operations' operation and returns the [Response].
  Future<Response> getNotificationOperationsWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/notifications/operations';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  Future<NotificationOperations?> getNotificationOperations({ Future<void>? abortTrigger, }) async {
    final response = await getNotificationOperationsWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'NotificationOperations',) as NotificationOperations;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/notifications/unread-count' operation and returns the [Response].
  Future<Response> getNotificationUnreadCountWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/notifications/unread-count';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  Future<NotificationCount?> getNotificationUnreadCount({ Future<void>? abortTrigger, }) async {
    final response = await getNotificationUnreadCountWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'NotificationCount',) as NotificationCount;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/notifications' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] offset:
  ///
  /// * [int] limit:
  ///
  /// * [bool] unreadOnly:
  ///
  /// * [bool] historical:
  Future<Response> listNotificationsWithHttpInfo({ int? offset, int? limit, bool? unreadOnly, bool? historical, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/notifications';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (offset != null) {
      queryParams.addAll(_queryParams('', 'offset', offset));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }
    if (unreadOnly != null) {
      queryParams.addAll(_queryParams('', 'unreadOnly', unreadOnly));
    }
    if (historical != null) {
      queryParams.addAll(_queryParams('', 'historical', historical));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Parameters:
  ///
  /// * [int] offset:
  ///
  /// * [int] limit:
  ///
  /// * [bool] unreadOnly:
  ///
  /// * [bool] historical:
  Future<NotificationPage?> listNotifications({ int? offset, int? limit, bool? unreadOnly, bool? historical, Future<void>? abortTrigger, }) async {
    final response = await listNotificationsWithHttpInfo(offset: offset, limit: limit, unreadOnly: unreadOnly, historical: historical, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'NotificationPage',) as NotificationPage;

    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/notifications/devices' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [DeviceRegistrationInput] deviceRegistrationInput (required):
  Future<Response> registerPushDeviceWithHttpInfo(DeviceRegistrationInput deviceRegistrationInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/notifications/devices';

    // ignore: prefer_final_locals
    Object? postBody = deviceRegistrationInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Parameters:
  ///
  /// * [DeviceRegistrationInput] deviceRegistrationInput (required):
  Future<DeviceRegistrationView?> registerPushDevice(DeviceRegistrationInput deviceRegistrationInput, { Future<void>? abortTrigger, }) async {
    final response = await registerPushDeviceWithHttpInfo(deviceRegistrationInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DeviceRegistrationView',) as DeviceRegistrationView;

    }
    return null;
  }

  /// Performs an HTTP 'DELETE /api/v1/notifications/devices/{installationId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] installationId (required):
  Future<Response> removePushDeviceWithHttpInfo(String installationId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/notifications/devices/{installationId}'
      .replaceAll('{installationId}', installationId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Parameters:
  ///
  /// * [String] installationId (required):
  Future<void> removePushDevice(String installationId, { Future<void>? abortTrigger, }) async {
    final response = await removePushDeviceWithHttpInfo(installationId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'PUT /api/v1/notifications/{notificationId}/device-receipt' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] notificationId (required):
  ///
  /// * [DeviceReceiptInput] deviceReceiptInput (required):
  Future<Response> reportNotificationDeviceReceiptWithHttpInfo(String notificationId, DeviceReceiptInput deviceReceiptInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/notifications/{notificationId}/device-receipt'
      .replaceAll('{notificationId}', notificationId);

    // ignore: prefer_final_locals
    Object? postBody = deviceReceiptInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Parameters:
  ///
  /// * [String] notificationId (required):
  ///
  /// * [DeviceReceiptInput] deviceReceiptInput (required):
  Future<void> reportNotificationDeviceReceipt(String notificationId, DeviceReceiptInput deviceReceiptInput, { Future<void>? abortTrigger, }) async {
    final response = await reportNotificationDeviceReceiptWithHttpInfo(notificationId, deviceReceiptInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/notifications/operations/retry' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [RetryNotificationInput] retryNotificationInput (required):
  Future<Response> retryFailedNotificationWorkWithHttpInfo(RetryNotificationInput retryNotificationInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/notifications/operations/retry';

    // ignore: prefer_final_locals
    Object? postBody = retryNotificationInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Parameters:
  ///
  /// * [RetryNotificationInput] retryNotificationInput (required):
  Future<void> retryFailedNotificationWork(RetryNotificationInput retryNotificationInput, { Future<void>? abortTrigger, }) async {
    final response = await retryFailedNotificationWorkWithHttpInfo(retryNotificationInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'PUT /api/v1/notifications/{notificationId}/read' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] notificationId (required):
  ///
  /// * [NotificationReadInput] notificationReadInput (required):
  Future<Response> setNotificationReadWithHttpInfo(String notificationId, NotificationReadInput notificationReadInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/notifications/{notificationId}/read'
      .replaceAll('{notificationId}', notificationId);

    // ignore: prefer_final_locals
    Object? postBody = notificationReadInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Parameters:
  ///
  /// * [String] notificationId (required):
  ///
  /// * [NotificationReadInput] notificationReadInput (required):
  Future<NotificationView?> setNotificationRead(String notificationId, NotificationReadInput notificationReadInput, { Future<void>? abortTrigger, }) async {
    final response = await setNotificationReadWithHttpInfo(notificationId, notificationReadInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'NotificationView',) as NotificationView;

    }
    return null;
  }
}
