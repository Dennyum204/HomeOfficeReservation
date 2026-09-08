import 'package:homeoffice_api/api.dart';

class WorkspaceRepository {
  WorkspaceRepository(this.api);
  final WorkspaceApi api;

  Future<WorkspaceInfo> load() async {
    final data = await api.getWorkspaceInfo(
      abortTrigger: Future<void>.delayed(const Duration(seconds: 8)),
    );
    if (data == null) throw StateError('Empty workspace response');
    return data;
  }

  void dispose() => api.apiClient.client.close();
}
