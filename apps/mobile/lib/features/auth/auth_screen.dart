import 'dart:async';

import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';

import '../../config/api_settings.dart';
import '../../l10n/generated/app_localizations.dart';
import '../workspace/workspace_repository.dart';
import '../workspace/workspace_screen.dart';
import 'auth_controller.dart';
import '../notifications/inbox_controller.dart';
import '../notifications/notification_repository.dart';
import '../notifications/push_coordinator.dart';
import '../notifications/push_gateway.dart';
import '../planning/planning_controller.dart';
import '../planning/planning_repository.dart';
import '../planning/planning_store.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.controller});
  final AuthController controller;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with WidgetsBindingObserver {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  final _form = GlobalKey<FormState>();
  String _mode = 'login';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_authChanged);
    widget.controller.restore();
  }

  void _authChanged() {
    if (widget.controller.member != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.controller.member != null) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).clearSnackBars();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        widget.controller.member != null) {
      widget.controller.check();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_authChanged);
    _email.dispose();
    _password.dispose();
    _code.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  void _switch(String mode) {
    setState(() {
      _mode = mode;
      _password.clear();
      _code.clear();
      widget.controller.message = AuthMessage.none;
    });
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final controller = widget.controller;
    if (_mode == 'login') {
      await controller.login(_email.text.trim(), _password.text);
      if (controller.member != null) {
        _password.clear();
        _code.clear();
      }
    } else if (await controller.account(
      _mode,
      _email.text.trim(),
      _code.text,
      _password.text,
    )) {
      if (!mounted) return;
      setState(() {
        _mode = _mode == 'activation'
            ? 'activate'
            : _mode == 'recovery'
            ? 'reset'
            : 'login';
        _password.clear();
        _code.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final c = widget.controller;
      final s = AppLocalizations.of(context)!;
      final messages = {
        AuthMessage.none: '',
        AuthMessage.invalid: s.authInvalid,
        AuthMessage.expired: s.authExpired,
        AuthMessage.forbidden: s.authForbidden,
        AuthMessage.network: s.authNetwork,
        AuthMessage.limited: s.authLimited,
        AuthMessage.codeInvalid: s.authInvalidCode,
        AuthMessage.sent: s.authSent,
        AuthMessage.completed: s.authCompleted,
        AuthMessage.storage: s.authStorage,
        AuthMessage.pushCleanup: s.authPushCleanup,
      };
      if (c.member case final member?) {
        return _AccountWorkspace(key: ValueKey(member.memberId), controller: c);
      }
      final titles = {
        'login': s.authLoginTitle,
        'activation': s.authActivationTitle,
        'recovery': s.authRecoveryTitle,
        'activate': s.authActivateTitle,
        'reset': s.authResetTitle,
      };
      final actions = {
        'login': s.authLogin,
        'activation': s.authRequestActivation,
        'recovery': s.authRequestRecovery,
        'activate': s.authActivate,
        'reset': s.authReset,
      };
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.holiday_village_outlined, size: 42),
                          const SizedBox(height: 16),
                          Text(
                            titles[_mode]!,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(s.authIntro),
                          if (c.message != AuthMessage.none)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Semantics(
                                liveRegion: true,
                                child: Text(messages[c.message]!),
                              ),
                            ),
                          const SizedBox(height: 20),
                          TextFormField(
                            key: const Key('email'),
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.username],
                            decoration: InputDecoration(labelText: s.authEmail),
                            validator: (value) =>
                                value == null || !value.contains('@')
                                ? s.authEmailRequired
                                : null,
                          ),
                          if (_mode == 'activate' || _mode == 'reset') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const Key('code'),
                              controller: _code,
                              decoration: InputDecoration(
                                labelText: s.authCode,
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? s.authRequired
                                  : null,
                            ),
                          ],
                          if (_mode == 'login' ||
                              _mode == 'activate' ||
                              _mode == 'reset') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const Key('password'),
                              controller: _password,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              autofillHints: [
                                _mode == 'login'
                                    ? AutofillHints.password
                                    : AutofillHints.newPassword,
                              ],
                              decoration: InputDecoration(
                                labelText: s.authPassword,
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? s.authRequired
                                  : null,
                            ),
                          ],
                          if (_mode == 'activate' || _mode == 'reset')
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(s.authPasswordHelp),
                            ),
                          const SizedBox(height: 24),
                          FilledButton(
                            key: const Key('submit'),
                            onPressed: c.busy ? null : _submit,
                            child: Text(c.busy ? s.authWait : actions[_mode]!),
                          ),
                          if (_mode == 'login') ...[
                            TextButton(
                              onPressed: c.busy
                                  ? null
                                  : () => _switch('activation'),
                              child: Text(s.authActivateLink),
                            ),
                            TextButton(
                              onPressed: c.busy
                                  ? null
                                  : () => _switch('recovery'),
                              child: Text(s.authRecoverLink),
                            ),
                          ] else
                            TextButton(
                              onPressed: c.busy ? null : () => _switch('login'),
                              child: Text(s.authBack),
                            ),
                          const SizedBox(height: 12),
                          Text(s.authControlled),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _AccountWorkspace extends StatefulWidget {
  const _AccountWorkspace({super.key, required this.controller});
  final AuthController controller;
  @override
  State<_AccountWorkspace> createState() => _AccountWorkspaceState();
}

class _AccountWorkspaceState extends State<_AccountWorkspace>
    with WidgetsBindingObserver {
  final workspaceKey = GlobalKey<WorkspaceScreenState>();
  late final planning = PlanningController(
    PlanningRepository(widget.controller),
    SecurePlanningStore(ApiSettings.baseUrl),
  );
  late final inbox = InboxController(NotificationRepository(widget.controller));
  late final push = PushCoordinator(
    widget.controller,
    FirebasePushGateway(),
    SecurePushBindingStore(ApiSettings.baseUrl),
    onOpen: (id) {
      if (mounted) workspaceKey.currentState?.openNotification(id);
    },
    onForeground: (id) {
      if (!mounted) return;
      unawaited(inbox.refresh());
      final s = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.notificationNew),
          action: SnackBarAction(
            label: s.notificationOpen,
            onPressed: () => workspaceKey.currentState?.openNotification(id),
          ),
        ),
      );
    },
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(
      planning.initialize().then((_) {
        if (!mounted || !planning.active) return;
        final auth = widget.controller;
        final intended = auth.notificationIntent;
        if (intended == null) return;
        if (auth.notificationActor != null &&
            auth.notificationActor != auth.member?.memberId) {
          auth.consumeNotification(intended);
          return;
        }
        workspaceKey.currentState?.openNotification(intended);
      }),
    );
    unawaited(inbox.refresh());
    unawaited(push.initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    inbox.activity(state == AppLifecycleState.resumed);
    push.activity(state == AppLifecycleState.resumed);
    if (state == AppLifecycleState.resumed && planning.initialized) {
      unawaited(planning.refreshWorkspace());
    } else if (planning.active) {
      unawaited(planning.persist().catchError((Object _) {}));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    planning.dispose();
    inbox.dispose();
    push.dispose();
    super.dispose();
  }

  late final repository = WorkspaceRepository(
    WorkspaceApi(ApiClient(basePath: ApiSettings.baseUrl)),
  );
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final member = c.member!;
    final s = AppLocalizations.of(context)!;
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Material(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    s.workAccount,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    member.displayName,
                    key: const Key('authenticated-member-name'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${member.organizationName} · ${[if (member.isEmployee) s.authEmployee, if (member.isManager) s.authManager, if (member.isAccountAdministrator) s.authAdmin].join(' · ')}',
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: c.busy ? null : c.check,
                        child: Text(s.authCheck),
                      ),
                      TextButton(
                        onPressed: c.logout,
                        child: Text(s.authLogout),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: WorkspaceScreen(
            key: workspaceKey,
            repository: repository,
            inbox: inbox,
            push: push,
            planning: planning,
          ),
        ),
      ],
    );
  }
}
