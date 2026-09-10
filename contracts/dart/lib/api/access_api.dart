//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AccessApi {
  AccessApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'PUT /api/v1/admin/members/{employeeId}/manager' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [SetManagerRequest] setManagerRequest (required):
  Future<Response> assignManagerWithHttpInfo(String employeeId, SetManagerRequest setManagerRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/members/{employeeId}/manager'
      .replaceAll('{employeeId}', employeeId);

    // ignore: prefer_final_locals
    Object? postBody = setManagerRequest;

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
  /// * [String] employeeId (required):
  ///
  /// * [SetManagerRequest] setManagerRequest (required):
  Future<void> assignManager(String employeeId, SetManagerRequest setManagerRequest, { Future<void>? abortTrigger, }) async {
    final response = await assignManagerWithHttpInfo(employeeId, setManagerRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/admin/members/{memberId}/invitation/cancel' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] memberId (required):
  ///
  /// * [InvitationChangeRequest] invitationChangeRequest (required):
  Future<Response> cancelInvitationWithHttpInfo(String memberId, InvitationChangeRequest invitationChangeRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/members/{memberId}/invitation/cancel'
      .replaceAll('{memberId}', memberId);

    // ignore: prefer_final_locals
    Object? postBody = invitationChangeRequest;

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
  /// * [String] memberId (required):
  ///
  /// * [InvitationChangeRequest] invitationChangeRequest (required):
  Future<void> cancelInvitation(String memberId, InvitationChangeRequest invitationChangeRequest, { Future<void>? abortTrigger, }) async {
    final response = await cancelInvitationWithHttpInfo(memberId, invitationChangeRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Read-only relationship/role guard. Does not create or approve any request.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] memberId (required):
  Future<Response> checkManagementAccessWithHttpInfo(String memberId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/members/{memberId}/management-access'
      .replaceAll('{memberId}', memberId);

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

  /// Read-only relationship/role guard. Does not create or approve any request.
  ///
  /// Parameters:
  ///
  /// * [String] memberId (required):
  Future<MemberProfile?> checkManagementAccess(String memberId, { Future<void>? abortTrigger, }) async {
    final response = await checkManagementAccessWithHttpInfo(memberId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MemberProfile',) as MemberProfile;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/me' operation and returns the [Response].
  Future<Response> getCurrentMemberWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/me';

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

  Future<MemberProfile?> getCurrentMember({ Future<void>? abortTrigger, }) async {
    final response = await getCurrentMemberWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MemberProfile',) as MemberProfile;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/members/{memberId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] memberId (required):
  Future<Response> getMemberWithHttpInfo(String memberId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/members/{memberId}'
      .replaceAll('{memberId}', memberId);

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
  /// * [String] memberId (required):
  Future<MemberProfile?> getMember(String memberId, { Future<void>? abortTrigger, }) async {
    final response = await getMemberWithHttpInfo(memberId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MemberProfile',) as MemberProfile;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/admin/invitations' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] after:
  ///
  /// * [int] limit:
  Future<Response> listInvitationsWithHttpInfo({ String? after, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/invitations';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (after != null) {
      queryParams.addAll(_queryParams('', 'after', after));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
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
  /// * [String] after:
  ///
  /// * [int] limit:
  Future<InvitationPage?> listInvitations({ String? after, int? limit, Future<void>? abortTrigger, }) async {
    final response = await listInvitationsWithHttpInfo(after: after, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'InvitationPage',) as InvitationPage;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/members' operation and returns the [Response].
  Future<Response> listMembersWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/members';

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

  Future<MemberList?> listMembers({ Future<void>? abortTrigger, }) async {
    final response = await listMembersWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MemberList',) as MemberList;

    }
    return null;
  }

  /// Create an admitted member and durable invitation. Repeating the identical normalized request by the same administrator returns success without creating or resending.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ProvisionMemberRequest] provisionMemberRequest (required):
  Future<Response> provisionMemberWithHttpInfo(ProvisionMemberRequest provisionMemberRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/members';

    // ignore: prefer_final_locals
    Object? postBody = provisionMemberRequest;

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

  /// Create an admitted member and durable invitation. Repeating the identical normalized request by the same administrator returns success without creating or resending.
  ///
  /// Parameters:
  ///
  /// * [ProvisionMemberRequest] provisionMemberRequest (required):
  Future<void> provisionMember(ProvisionMemberRequest provisionMemberRequest, { Future<void>? abortTrigger, }) async {
    final response = await provisionMemberWithHttpInfo(provisionMemberRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/admin/members/{memberId}/invitation/resend' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] memberId (required):
  ///
  /// * [InvitationChangeRequest] invitationChangeRequest (required):
  Future<Response> resendInvitationWithHttpInfo(String memberId, InvitationChangeRequest invitationChangeRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/members/{memberId}/invitation/resend'
      .replaceAll('{memberId}', memberId);

    // ignore: prefer_final_locals
    Object? postBody = invitationChangeRequest;

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
  /// * [String] memberId (required):
  ///
  /// * [InvitationChangeRequest] invitationChangeRequest (required):
  Future<void> resendInvitation(String memberId, InvitationChangeRequest invitationChangeRequest, { Future<void>? abortTrigger, }) async {
    final response = await resendInvitationWithHttpInfo(memberId, invitationChangeRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'PUT /api/v1/admin/members/{memberId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] memberId (required):
  ///
  /// * [UpdateMemberRequest] updateMemberRequest (required):
  Future<Response> updateMemberWithHttpInfo(String memberId, UpdateMemberRequest updateMemberRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/members/{memberId}'
      .replaceAll('{memberId}', memberId);

    // ignore: prefer_final_locals
    Object? postBody = updateMemberRequest;

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
  /// * [String] memberId (required):
  ///
  /// * [UpdateMemberRequest] updateMemberRequest (required):
  Future<void> updateMember(String memberId, UpdateMemberRequest updateMemberRequest, { Future<void>? abortTrigger, }) async {
    final response = await updateMemberWithHttpInfo(memberId, updateMemberRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
