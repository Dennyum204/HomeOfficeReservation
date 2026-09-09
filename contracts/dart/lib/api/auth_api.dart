//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AuthApi {
  AuthApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/v1/auth/activation/complete' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [CompleteAccountRequest] completeAccountRequest (required):
  Future<Response> activateAccountWithHttpInfo(CompleteAccountRequest completeAccountRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/activation/complete';

    // ignore: prefer_final_locals
    Object? postBody = completeAccountRequest;

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
  /// * [CompleteAccountRequest] completeAccountRequest (required):
  Future<void> activateAccount(CompleteAccountRequest completeAccountRequest, { Future<void>? abortTrigger, }) async {
    final response = await activateAccountWithHttpInfo(completeAccountRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/auth/csrf' operation and returns the [Response].
  Future<Response> getCsrfTokenWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/csrf';

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

  Future<CsrfToken?> getCsrfToken({ Future<void>? abortTrigger, }) async {
    final response = await getCsrfTokenWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CsrfToken',) as CsrfToken;

    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/auth/token/login' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [Credentials] credentials (required):
  Future<Response> loginTokenWithHttpInfo(Credentials credentials, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/token/login';

    // ignore: prefer_final_locals
    Object? postBody = credentials;

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
  /// * [Credentials] credentials (required):
  Future<AccessTokenResponse?> loginToken(Credentials credentials, { Future<void>? abortTrigger, }) async {
    final response = await loginTokenWithHttpInfo(credentials, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AccessTokenResponse',) as AccessTokenResponse;

    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/auth/web/login' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [Credentials] credentials (required):
  Future<Response> loginWebWithHttpInfo(Credentials credentials, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/web/login';

    // ignore: prefer_final_locals
    Object? postBody = credentials;

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
  /// * [Credentials] credentials (required):
  Future<void> loginWeb(Credentials credentials, { Future<void>? abortTrigger, }) async {
    final response = await loginWebWithHttpInfo(credentials, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/auth/logout' operation and returns the [Response].
  Future<Response> logoutWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/logout';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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

  Future<void> logout({ Future<void>? abortTrigger, }) async {
    final response = await logoutWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/auth/token/refresh' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [RefreshRequest] refreshRequest (required):
  Future<Response> refreshSessionWithHttpInfo(RefreshRequest refreshRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/token/refresh';

    // ignore: prefer_final_locals
    Object? postBody = refreshRequest;

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
  /// * [RefreshRequest] refreshRequest (required):
  Future<AccessTokenResponse?> refreshSession(RefreshRequest refreshRequest, { Future<void>? abortTrigger, }) async {
    final response = await refreshSessionWithHttpInfo(refreshRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AccessTokenResponse',) as AccessTokenResponse;

    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/auth/activation/request' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [EmailRequest] emailRequest (required):
  Future<Response> requestActivationWithHttpInfo(EmailRequest emailRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/activation/request';

    // ignore: prefer_final_locals
    Object? postBody = emailRequest;

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
  /// * [EmailRequest] emailRequest (required):
  Future<void> requestActivation(EmailRequest emailRequest, { Future<void>? abortTrigger, }) async {
    final response = await requestActivationWithHttpInfo(emailRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/auth/recovery/request' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [EmailRequest] emailRequest (required):
  Future<Response> requestRecoveryWithHttpInfo(EmailRequest emailRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/recovery/request';

    // ignore: prefer_final_locals
    Object? postBody = emailRequest;

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
  /// * [EmailRequest] emailRequest (required):
  Future<void> requestRecovery(EmailRequest emailRequest, { Future<void>? abortTrigger, }) async {
    final response = await requestRecoveryWithHttpInfo(emailRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/auth/recovery/complete' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [CompleteAccountRequest] completeAccountRequest (required):
  Future<Response> resetPasswordWithHttpInfo(CompleteAccountRequest completeAccountRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/recovery/complete';

    // ignore: prefer_final_locals
    Object? postBody = completeAccountRequest;

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
  /// * [CompleteAccountRequest] completeAccountRequest (required):
  Future<void> resetPassword(CompleteAccountRequest completeAccountRequest, { Future<void>? abortTrigger, }) async {
    final response = await resetPasswordWithHttpInfo(completeAccountRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
