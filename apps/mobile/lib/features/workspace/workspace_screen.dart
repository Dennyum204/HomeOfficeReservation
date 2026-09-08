import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import 'workspace_repository.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key, required this.repository});
  final WorkspaceRepository? repository;
  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  int _section = 0;
  late Future<WorkspaceInfo>? _connection;
  @override
  void initState() {
    super.initState();
    _connection = widget.repository?.load();
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
      s.tasks,
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
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.holiday_village_outlined,
              color: Color(0xff264e3e),
            ),
            const SizedBox(width: 10),
            Text(
              s.appName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _section,
              onDestinationSelected: (value) =>
                  setState(() => _section = value),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 10),
              ),
              destinations: List.generate(
                labels.length,
                (i) => NavigationDestination(
                  icon: Icon(icons[i]),
                  label: labels[i],
                ),
              ),
            ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              extended: true,
              selectedIndex: _section,
              onDestinationSelected: (value) =>
                  setState(() => _section = value),
              destinations: List.generate(
                labels.length,
                (i) => NavigationRailDestination(
                  icon: Icon(icons[i]),
                  label: Text(labels[i]),
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.countries,
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: Color(0xff6d806b),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.welcome,
                          style: const TextStyle(
                            fontSize: 30,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -1,
                            color: Color(0xff203d38),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.introduction,
                          style: const TextStyle(
                            color: Color(0xff637268),
                            height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Chip(
                          label: Text(
                            s.foundation,
                            style: const TextStyle(fontSize: 11),
                          ),
                          avatar: const Icon(Icons.construction, size: 14),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  labels[_section].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                    color: Color(0xff6d806b),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  titles[_section],
                                  style: const TextStyle(
                                    fontSize: 25,
                                    height: 1.25,
                                    color: Color(0xff203d38),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  descriptions[_section],
                                  style: const TextStyle(
                                    height: 1.65,
                                    color: Color(0xff637268),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffedf1e7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            const Icon(
                                              Icons.cottage_outlined,
                                              size: 42,
                                              color: Color(0xff68805e),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              s.remote,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.more_horiz,
                                        color: Color(0xff98a88f),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            const Icon(
                                              Icons.landscape_outlined,
                                              size: 42,
                                              color: Color(0xff68805e),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              s.onsite,
                                              textAlign: TextAlign.center,
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
                                    const Icon(Icons.schedule, size: 18),
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.7,
                                    color: Color(0xff637268),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  FutureBuilder<WorkspaceInfo>(
                                    future: _connection,
                                    builder: (context, snapshot) {
                                      final loading =
                                          snapshot.connectionState !=
                                          ConnectionState.done;
                                      final data = loading
                                          ? null
                                          : snapshot.data;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Semantics(
                                            liveRegion: true,
                                            child: Text(
                                              loading
                                                  ? s.connecting
                                                  : snapshot.hasError
                                                  ? s.offline
                                                  : s.connected,
                                              key: const Key(
                                                'connection-state',
                                              ),
                                            ),
                                          ),
                                          if (snapshot.hasError &&
                                              !loading) ...[
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
                                              DateFormat.yMd(
                                                'pt_PT',
                                              ).add_Hms().format(
                                                data.serverTimeUtc.toLocal(),
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
                                              data.planningTimeZones.join(
                                                ' · ',
                                              ),
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
                                                    _connection = widget
                                                        .repository!
                                                        .load();
                                                  }),
                                            icon: const Icon(
                                              Icons.refresh,
                                              size: 18,
                                            ),
                                            label: Text(
                                              snapshot.hasError
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
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xff637268),
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
    );
  }
}
