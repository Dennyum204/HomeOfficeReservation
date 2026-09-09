//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class PlanningApi {
  PlanningApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/v1/planning/{employeeId}/proposals/{proposalId}/accept' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [String] proposalId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [AcceptProposalInput] acceptProposalInput (required):
  Future<Response> acceptCounterproposalWithHttpInfo(String employeeId, String proposalId, String idempotencyKey, AcceptProposalInput acceptProposalInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/proposals/{proposalId}/accept'
      .replaceAll('{employeeId}', employeeId)
      .replaceAll('{proposalId}', proposalId);

    // ignore: prefer_final_locals
    Object? postBody = acceptProposalInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);

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
  /// * [String] employeeId (required):
  ///
  /// * [String] proposalId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [AcceptProposalInput] acceptProposalInput (required):
  Future<MutationReceipt?> acceptCounterproposal(String employeeId, String proposalId, String idempotencyKey, AcceptProposalInput acceptProposalInput, { Future<void>? abortTrigger, }) async {
    final response = await acceptCounterproposalWithHttpInfo(employeeId, proposalId, idempotencyKey, acceptProposalInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MutationReceipt',) as MutationReceipt;

    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/planning/{employeeId}/requests/{requestId}/comments' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [CommentInput] commentInput (required):
  Future<Response> addPlanningCommentWithHttpInfo(String employeeId, String requestId, String idempotencyKey, CommentInput commentInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/requests/{requestId}/comments'
      .replaceAll('{employeeId}', employeeId)
      .replaceAll('{requestId}', requestId);

    // ignore: prefer_final_locals
    Object? postBody = commentInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);

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
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [CommentInput] commentInput (required):
  Future<MutationReceipt?> addPlanningComment(String employeeId, String requestId, String idempotencyKey, CommentInput commentInput, { Future<void>? abortTrigger, }) async {
    final response = await addPlanningCommentWithHttpInfo(employeeId, requestId, idempotencyKey, commentInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MutationReceipt',) as MutationReceipt;

    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/planning/{employeeId}/requests/{requestId}/proposals' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [ProposalInput] proposalInput (required):
  Future<Response> createCounterproposalWithHttpInfo(String employeeId, String requestId, String idempotencyKey, ProposalInput proposalInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/requests/{requestId}/proposals'
      .replaceAll('{employeeId}', employeeId)
      .replaceAll('{requestId}', requestId);

    // ignore: prefer_final_locals
    Object? postBody = proposalInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);

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
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [ProposalInput] proposalInput (required):
  Future<MutationReceipt?> createCounterproposal(String employeeId, String requestId, String idempotencyKey, ProposalInput proposalInput, { Future<void>? abortTrigger, }) async {
    final response = await createCounterproposalWithHttpInfo(employeeId, requestId, idempotencyKey, proposalInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MutationReceipt',) as MutationReceipt;

    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/planning/{employeeId}/requests' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [DraftInput] draftInput (required):
  Future<Response> createPlanningDraftWithHttpInfo(String employeeId, String idempotencyKey, DraftInput draftInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/requests'
      .replaceAll('{employeeId}', employeeId);

    // ignore: prefer_final_locals
    Object? postBody = draftInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);

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
  /// * [String] employeeId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [DraftInput] draftInput (required):
  Future<MutationReceipt?> createPlanningDraft(String employeeId, String idempotencyKey, DraftInput draftInput, { Future<void>? abortTrigger, }) async {
    final response = await createPlanningDraftWithHttpInfo(employeeId, idempotencyKey, draftInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MutationReceipt',) as MutationReceipt;

    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/planning/{employeeId}/requests/{requestId}/decide' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [DecisionInput] decisionInput (required):
  Future<Response> decidePlanningDaysWithHttpInfo(String employeeId, String requestId, String idempotencyKey, DecisionInput decisionInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/requests/{requestId}/decide'
      .replaceAll('{employeeId}', employeeId)
      .replaceAll('{requestId}', requestId);

    // ignore: prefer_final_locals
    Object? postBody = decisionInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);

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
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [DecisionInput] decisionInput (required):
  Future<MutationReceipt?> decidePlanningDays(String employeeId, String requestId, String idempotencyKey, DecisionInput decisionInput, { Future<void>? abortTrigger, }) async {
    final response = await decidePlanningDaysWithHttpInfo(employeeId, requestId, idempotencyKey, decisionInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MutationReceipt',) as MutationReceipt;

    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/planning/{employeeId}/requests/{requestId}/draft' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [DraftInput] draftInput (required):
  Future<Response> editPlanningDraftWithHttpInfo(String employeeId, String requestId, String idempotencyKey, DraftInput draftInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/requests/{requestId}/draft'
      .replaceAll('{employeeId}', employeeId)
      .replaceAll('{requestId}', requestId);

    // ignore: prefer_final_locals
    Object? postBody = draftInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);

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
  /// * [String] requestId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [DraftInput] draftInput (required):
  Future<MutationReceipt?> editPlanningDraft(String employeeId, String requestId, String idempotencyKey, DraftInput draftInput, { Future<void>? abortTrigger, }) async {
    final response = await editPlanningDraftWithHttpInfo(employeeId, requestId, idempotencyKey, draftInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MutationReceipt',) as MutationReceipt;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/planning/{employeeId}/calendar' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [DateTime] from (required):
  ///
  /// * [DateTime] to (required):
  Future<Response> getCalendarWithHttpInfo(String employeeId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/calendar'
      .replaceAll('{employeeId}', employeeId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'from', _dateFormatter.format(from)));
      queryParams.addAll(_queryParams('', 'to', _dateFormatter.format(to)));

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
  /// * [String] employeeId (required):
  ///
  /// * [DateTime] from (required):
  ///
  /// * [DateTime] to (required):
  Future<CalendarView?> getCalendar(String employeeId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    final response = await getCalendarWithHttpInfo(employeeId, from, to, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CalendarView',) as CalendarView;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/planning/{employeeId}/requests/{requestId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  Future<Response> getPlanningRequestWithHttpInfo(String employeeId, String requestId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/requests/{requestId}'
      .replaceAll('{employeeId}', employeeId)
      .replaceAll('{requestId}', requestId);

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
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  Future<RequestView?> getPlanningRequest(String employeeId, String requestId, { Future<void>? abortTrigger, }) async {
    final response = await getPlanningRequestWithHttpInfo(employeeId, requestId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RequestView',) as RequestView;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/planning/{employeeId}/requests/{requestId}/proposals' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [int] offset:
  ///
  /// * [int] limit:
  Future<Response> listCounterproposalsWithHttpInfo(String employeeId, String requestId, { int? offset, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/requests/{requestId}/proposals'
      .replaceAll('{employeeId}', employeeId)
      .replaceAll('{requestId}', requestId);

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
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [int] offset:
  ///
  /// * [int] limit:
  Future<ProposalPage?> listCounterproposals(String employeeId, String requestId, { int? offset, int? limit, Future<void>? abortTrigger, }) async {
    final response = await listCounterproposalsWithHttpInfo(employeeId, requestId, offset: offset, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ProposalPage',) as ProposalPage;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/planning/{employeeId}/requests/{requestId}/comments' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [int] offset:
  ///
  /// * [int] limit:
  Future<Response> listPlanningCommentsWithHttpInfo(String employeeId, String requestId, { int? offset, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/requests/{requestId}/comments'
      .replaceAll('{employeeId}', employeeId)
      .replaceAll('{requestId}', requestId);

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
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [int] offset:
  ///
  /// * [int] limit:
  Future<CommentPage?> listPlanningComments(String employeeId, String requestId, { int? offset, int? limit, Future<void>? abortTrigger, }) async {
    final response = await listPlanningCommentsWithHttpInfo(employeeId, requestId, offset: offset, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CommentPage',) as CommentPage;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/planning/{employeeId}/requests' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [int] offset:
  ///
  /// * [int] limit:
  ///
  /// * [RequestState] state:
  Future<Response> listPlanningRequestsWithHttpInfo(String employeeId, { int? offset, int? limit, RequestState? state, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/requests'
      .replaceAll('{employeeId}', employeeId);

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
    if (state != null) {
      queryParams.addAll(_queryParams('', 'state', state));
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
  /// * [String] employeeId (required):
  ///
  /// * [int] offset:
  ///
  /// * [int] limit:
  ///
  /// * [RequestState] state:
  Future<RequestPage?> listPlanningRequests(String employeeId, { int? offset, int? limit, RequestState? state, Future<void>? abortTrigger, }) async {
    final response = await listPlanningRequestsWithHttpInfo(employeeId, offset: offset, limit: limit, state: state, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RequestPage',) as RequestPage;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/planning/{employeeId}/patterns' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [int] offset:
  ///
  /// * [int] limit:
  Future<Response> listWeeklyPatternsWithHttpInfo(String employeeId, { int? offset, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/patterns'
      .replaceAll('{employeeId}', employeeId);

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
  /// * [String] employeeId (required):
  ///
  /// * [int] offset:
  ///
  /// * [int] limit:
  Future<PatternPage?> listWeeklyPatterns(String employeeId, { int? offset, int? limit, Future<void>? abortTrigger, }) async {
    final response = await listWeeklyPatternsWithHttpInfo(employeeId, offset: offset, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PatternPage',) as PatternPage;

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/planning/date-preview' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [DateTime] from (required):
  ///
  /// * [DateTime] to (required):
  ///
  /// * [bool] includeWeekends:
  Future<Response> previewPlanningDatesWithHttpInfo(DateTime from, DateTime to, { bool? includeWeekends, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/date-preview';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'from', _dateFormatter.format(from)));
      queryParams.addAll(_queryParams('', 'to', _dateFormatter.format(to)));
    if (includeWeekends != null) {
      queryParams.addAll(_queryParams('', 'includeWeekends', includeWeekends));
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
  /// * [DateTime] from (required):
  ///
  /// * [DateTime] to (required):
  ///
  /// * [bool] includeWeekends:
  Future<DatePreview?> previewPlanningDates(DateTime from, DateTime to, { bool? includeWeekends, Future<void>? abortTrigger, }) async {
    final response = await previewPlanningDatesWithHttpInfo(from, to, includeWeekends: includeWeekends, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DatePreview',) as DatePreview;

    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/planning/{employeeId}/requests/{requestId}/proposals/{proposalId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [String] proposalId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [ProposalInput] proposalInput (required):
  Future<Response> reviseCounterproposalWithHttpInfo(String employeeId, String requestId, String proposalId, String idempotencyKey, ProposalInput proposalInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/requests/{requestId}/proposals/{proposalId}'
      .replaceAll('{employeeId}', employeeId)
      .replaceAll('{requestId}', requestId)
      .replaceAll('{proposalId}', proposalId);

    // ignore: prefer_final_locals
    Object? postBody = proposalInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);

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
  /// * [String] requestId (required):
  ///
  /// * [String] proposalId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [ProposalInput] proposalInput (required):
  Future<MutationReceipt?> reviseCounterproposal(String employeeId, String requestId, String proposalId, String idempotencyKey, ProposalInput proposalInput, { Future<void>? abortTrigger, }) async {
    final response = await reviseCounterproposalWithHttpInfo(employeeId, requestId, proposalId, idempotencyKey, proposalInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MutationReceipt',) as MutationReceipt;

    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/planning/{employeeId}/patterns' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [PatternInput] patternInput (required):
  Future<Response> setWeeklyPatternWithHttpInfo(String employeeId, String idempotencyKey, PatternInput patternInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/patterns'
      .replaceAll('{employeeId}', employeeId);

    // ignore: prefer_final_locals
    Object? postBody = patternInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);

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
  /// * [String] employeeId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [PatternInput] patternInput (required):
  Future<MutationReceipt?> setWeeklyPattern(String employeeId, String idempotencyKey, PatternInput patternInput, { Future<void>? abortTrigger, }) async {
    final response = await setWeeklyPatternWithHttpInfo(employeeId, idempotencyKey, patternInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MutationReceipt',) as MutationReceipt;

    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/planning/{employeeId}/requests/{requestId}/submit' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [SubmitInput] submitInput (required):
  Future<Response> submitPlanningRequestWithHttpInfo(String employeeId, String requestId, String idempotencyKey, SubmitInput submitInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/requests/{requestId}/submit'
      .replaceAll('{employeeId}', employeeId)
      .replaceAll('{requestId}', requestId);

    // ignore: prefer_final_locals
    Object? postBody = submitInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);

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
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [SubmitInput] submitInput (required):
  Future<MutationReceipt?> submitPlanningRequest(String employeeId, String requestId, String idempotencyKey, SubmitInput submitInput, { Future<void>? abortTrigger, }) async {
    final response = await submitPlanningRequestWithHttpInfo(employeeId, requestId, idempotencyKey, submitInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MutationReceipt',) as MutationReceipt;

    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/planning/{employeeId}/requests/{requestId}/withdraw' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [WithdrawInput] withdrawInput (required):
  Future<Response> withdrawPlanningDaysWithHttpInfo(String employeeId, String requestId, String idempotencyKey, WithdrawInput withdrawInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/planning/{employeeId}/requests/{requestId}/withdraw'
      .replaceAll('{employeeId}', employeeId)
      .replaceAll('{requestId}', requestId);

    // ignore: prefer_final_locals
    Object? postBody = withdrawInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);

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
  /// * [String] employeeId (required):
  ///
  /// * [String] requestId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [WithdrawInput] withdrawInput (required):
  Future<MutationReceipt?> withdrawPlanningDays(String employeeId, String requestId, String idempotencyKey, WithdrawInput withdrawInput, { Future<void>? abortTrigger, }) async {
    final response = await withdrawPlanningDaysWithHttpInfo(employeeId, requestId, idempotencyKey, withdrawInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MutationReceipt',) as MutationReceipt;

    }
    return null;
  }
}
