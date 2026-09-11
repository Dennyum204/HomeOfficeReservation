import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import 'workspace_repository.dart';
import '../notifications/inbox_controller.dart';
import '../notifications/push_coordinator.dart';
import '../notifications/notification_screen.dart';
import '../planning/planning_controller.dart';
import '../planning/planning_screen.dart';
import '../work/work_screen.dart';
import '../../theme/appearance.dart';
import '../../theme/components.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({
    super.key,
    required this.repository,
    this.inbox,
    this.push,
    this.planning,
    this.accountSection,
  });
  final WorkspaceRepository? repository;
  final InboxController? inbox;
  final PushCoordinator? push;
  final PlanningController? planning;
  final Widget? accountSection;
  @override
  State<WorkspaceScreen> createState() => WorkspaceScreenState();
}

class WorkspaceScreenState extends State<WorkspaceScreen> {
  int _section = 0;
  void selectSection(int value) {
    setState(() => _section = value);
    widget.inbox?.showInbox(value == 3);
    final c = widget.planning;
    if (value == 2 && c != null && c.workId == null && c.workEditor == null) {
      c.loadWork();
    }
  }

  bool _openingNotification = false;
  Future<void> openNotification(String id) async {
    if (_openingNotification) return;
    _openingNotification = true;
    final planning = widget.planning;
    planning?.repository.auth.rememberNotification(id);
    selectSection(3);
    try {
      if (planning != null && !planning.initialized) {
        await planning.initialize();
        if (!mounted || !planning.active || !planning.initialized) return;
      }
      await widget.inbox?.open(id);
      if (!mounted || (planning != null && !planning.active)) return;
      final destination = widget.inbox?.detail?.destination;
      if (destination != null &&
          planning != null &&
          (destination.kind == NotificationContext.request ||
              destination.kind == NotificationContext.proposal)) {
        final opened = await planning.openRequest(
          destination.resourceId,
          target: destination.employeeId,
        );
        if (!mounted || !planning.active) return;
        selectSection(1);
        if (opened ||
            planning.failure == PlanningFailure.missing ||
            planning.failure == PlanningFailure.forbidden) {
          planning.repository.auth.consumeNotification(id);
        }
      } else if (destination != null &&
          planning != null &&
          (destination.kind == NotificationContext.requirement ||
              destination.kind == NotificationContext.task)) {
        final opened = await planning.openWork(
          destination.kind == NotificationContext.requirement
              ? WorkContext.requirement
              : WorkContext.task,
          destination.resourceId,
          target: destination.employeeId,
        );
        if (!mounted || !planning.active) return;
        selectSection(2);
        if (opened ||
            planning.failure == PlanningFailure.missing ||
            planning.failure == PlanningFailure.forbidden) {
          planning.repository.auth.consumeNotification(id);
        }
      } else if (widget.inbox?.detail != null ||
          widget.inbox?.unavailable == true) {
        planning?.repository.auth.consumeNotification(id);
      }
    } finally {
      _openingNotification = false;
    }
  }

  Widget navIcon(int index, IconData icon) => index == 3 && widget.inbox != null
      ? ListenableBuilder(
          listenable: widget.inbox!,
          builder: (context, _) => Badge.count(
            count: widget.inbox!.unreadCount,
            isLabelVisible: widget.inbox!.unreadCount > 0,
            child: Icon(icon),
          ),
        )
      : Icon(icon);
  late Future<WorkspaceInfo?>? _connection;
  Future<WorkspaceInfo?> _loadConnection() async {
    try {
      return await widget.repository!.load();
    } catch (_) {
      // Settings may not be mounted yet, or logout may close this repository.
      // Capture failure immediately; null renders offline and retains retry.
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _connection = widget.repository == null ? null : _loadConnection();
  }

  @override
  void dispose() {
    widget.repository?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final labels = [
      s.calendar,
      s.requests,
      widget.planning == null ? s.tasks : s.workNavigation,
      s.notifications,
      s.settings,
    ];
    final icons = [
      Icons.calendar_month_outlined,
      Icons.north_east,
      Icons.task_alt,
      Icons.notifications_outlined,
      Icons.settings_outlined,
    ];
    final titles = [
      s.calendarTitle,
      s.requestsTitle,
      s.tasksTitle,
      s.notificationsTitle,
      s.settingsTitle,
    ];
    final descriptions = [
      s.calendarDescription,
      s.requestsDescription,
      s.tasksDescription,
      s.notificationsDescription,
      s.settingsDescription,
    ];
    final pending = [
      s.calendarPending,
      s.requestsPending,
      s.tasksPending,
      s.notificationsPending,
      s.settingsPending,
    ];
    final wide = MediaQuery.sizeOf(context).width >= 700;
    return Scaffold(
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _section,
              onDestinationSelected: selectSection,
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 10),
              ),
              destinations: List.generate(
                labels.length,
                (i) => NavigationDestination(
                  icon: navIcon(i, icons[i]),
                  label: labels[i],
                ),
              ),
            ),
      body: SafeArea(
        bottom: wide,
        child: Row(
          children: [
            if (wide)
              NavigationRail(
                extended: true,
                selectedIndex: _section,
                onDestinationSelected: selectSection,
                destinations: List.generate(
                  labels.length,
                  (i) => NavigationRailDestination(
                    icon: navIcon(i, icons[i]),
                    label: Text(labels[i]),
                  ),
                ),
              ),
            Expanded(
              child: (_section == 0 || _section == 1) && widget.planning != null
                  ? PlanningScreen(
                      controller: widget.planning!,
                      requests: _section == 1,
                      onRequests: () => selectSection(1),
                      onRequirement: (id) async {
                        await widget.planning!.openWork(
                          WorkContext.requirement,
                          id,
                        );
                        if (mounted && widget.planning!.active) {
                          selectSection(2);
                        }
                      },
                      onNewRequirement: () async {
                        final c = widget.planning!;
                        await c.selectWorkKind(WorkContext.requirement);
                        if (!mounted || !c.active) return;
                        await c.editWork(creating: true);
                        if (mounted && c.active) selectSection(2);
                      },
                    )
                  : _section == 2 && widget.planning != null
                  ? WorkScreen(
                      widget.planning!,
                      onRequests: () => selectSection(1),
                    )
                  : _section == 3 && widget.inbox != null
                  ? NotificationScreen(
                      controller: widget.inbox!,
                      onOpen: openNotification,
                    )
                  : SingleChildScrollView(
                      key: PageStorageKey('workspace-$_section'),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeading(labels[_section]),
                                if (_section == 4 &&
                                    widget.accountSection != null)
                                  widget.accountSection!,
                                if (_section == 4 && widget.push != null)
                                  PushSettings(controller: widget.push!),
                                if (widget.planning != null) ...[
                                  const AppearancePicker(),
                                  const SizedBox(height: 24),
                                  Text(s.workSettings),
                                  Text(s.workSettingsHint),
                                  Text(s.workOutlookLater),
                                ] else ...[
                                  Text(
                                    s.countries,
                                    style: TextStyle(
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    s.welcome,
                                    style: TextStyle(
                                      fontSize: 30,
                                      height: 1.2,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -1,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    s.introduction,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      height: 1.65,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Chip(
                                    label: Text(
                                      s.foundation,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    avatar: const Icon(
                                      Icons.construction,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            labels[_section].toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              letterSpacing: 1.5,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            titles[_section],
                                            style: TextStyle(
                                              fontSize: 25,
                                              height: 1.25,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            descriptions[_section],
                                            style: TextStyle(
                                              height: 1.65,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 24,
                                              horizontal: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerLow,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.cottage_outlined,
                                                        size: 42,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        s.remote,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.more_horiz,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .landscape_outlined,
                                                        size: 42,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        s.onsite,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          const Divider(),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.schedule,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                s.inPreparation,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            pending[_section],
                                            style: TextStyle(
                                              fontSize: 12,
                                              height: 1.7,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.connectionTitle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        if (_connection == null)
                                          Text(s.configurationError)
                                        else
                                          FutureBuilder<WorkspaceInfo?>(
                                            future: _connection,
                                            builder: (context, snapshot) {
                                              final loading =
                                                  snapshot.connectionState !=
                                                  ConnectionState.done;
                                              final data = loading
                                                  ? null
                                                  : snapshot.data;
                                              final failed =
                                                  !loading &&
                                                  (snapshot.hasError ||
                                                      data == null);
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Semantics(
                                                    liveRegion: true,
                                                    child: Text(
                                                      loading
                                                          ? s.connecting
                                                          : failed
                                                          ? s.offline
                                                          : s.connected,
                                                      key: const Key(
                                                        'connection-state',
                                                      ),
                                                    ),
                                                  ),
                                                  if (failed) ...[
                                                    const SizedBox(height: 8),
                                                    Text(s.offlineHelp),
                                                  ],
                                                  if (data != null) ...[
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      s.received,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                    Text(
                                                      DateFormat.yMd('pt_PT')
                                                          .add_Hms()
                                                          .format(
                                                            data.serverTimeUtc
                                                                .toLocal(),
                                                          ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(
                                                      s.timeZones,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                    Text(
                                                      data.planningTimeZones
                                                          .join(' · '),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                  const SizedBox(height: 16),
                                                  OutlinedButton.icon(
                                                    onPressed: loading
                                                        ? null
                                                        : () => setState(() {
                                                            _connection =
                                                                _loadConnection();
                                                          }),
                                                    icon: const Icon(
                                                      Icons.refresh,
                                                      size: 18,
                                                    ),
                                                    label: Text(
                                                      failed
                                                          ? s.retry
                                                          : s.refresh,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  s.independent,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
