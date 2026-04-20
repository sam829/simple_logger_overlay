import 'package:example/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/simple_logger_overlay.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Logger Showcase'),
            backgroundColor: cs.surface,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList.list(
              children: [
                _SectionHeader('Log Levels'),
                _LogLevelTiles(),
                const SizedBox(height: 24),
                _SectionHeader('Burst & Stress'),
                _BurstTiles(),
                const SizedBox(height: 24),
                _SectionHeader('Integrations'),
                _IntegrationTiles(),
                const SizedBox(height: 24),
                _SectionHeader('Open Overlay'),
                _OverlayTile(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _LogLevelTiles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final levels = [
      (
        'Debug',
        'Tap to fire a debug log',
        Icons.bug_report_outlined,
        cs.tertiaryContainer,
        cs.onTertiaryContainer,
        LogLevel.debug,
      ),
      (
        'Info',
        'Tap to fire an info log',
        Icons.info_outline,
        cs.primaryContainer,
        cs.onPrimaryContainer,
        LogLevel.info,
      ),
      (
        'Error',
        'Tap to fire an error log',
        Icons.error_outline,
        cs.errorContainer,
        cs.onErrorContainer,
        LogLevel.error,
      ),
    ];

    return Column(
      children: levels.map((item) {
        final (label, subtitle, icon, bg, fg, level) = item;
        return Card(
          elevation: 0,
          color: bg,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Icon(icon, color: fg),
            title: Text(label,
                style: TextStyle(
                    color: fg, fontWeight: FontWeight.w600)),
            subtitle:
                Text(subtitle, style: TextStyle(color: fg.withValues(alpha: 0.7))),
            trailing:
                Icon(Icons.send_outlined, color: fg.withValues(alpha: 0.6)),
            onTap: () {
              SimpleLoggerOverlay.log(
                '$label log fired at ${DateTime.now().toIso8601String()}',
                level: level,
                tag: 'Dashboard',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label log sent'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

class _BurstTiles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Card(
          elevation: 0,
          color: cs.secondaryContainer,
          margin: const EdgeInsets.only(bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading:
                Icon(Icons.bolt_outlined, color: cs.onSecondaryContainer),
            title: Text('Fire 10 logs (mixed levels)',
                style: TextStyle(
                    color: cs.onSecondaryContainer,
                    fontWeight: FontWeight.w600)),
            subtitle: Text('Tests AnimatedList live-insert',
                style: TextStyle(
                    color: cs.onSecondaryContainer.withValues(alpha: 0.7))),
            trailing: Icon(Icons.play_arrow_outlined,
                color: cs.onSecondaryContainer.withValues(alpha: 0.6)),
            onTap: () => _fireBurst(context),
          ),
        ),
        Card(
          elevation: 0,
          color: cs.surfaceContainerHighest,
          margin: const EdgeInsets.only(bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Icon(Icons.timer_outlined,
                color: cs.onSurfaceVariant),
            title: Text('Slow drip (1 log/sec × 5)',
                style: TextStyle(
                    color: cs.onSurface, fontWeight: FontWeight.w600)),
            subtitle: Text('Watch FAB pulse + live append',
                style: TextStyle(color: cs.onSurfaceVariant)),
            trailing: Icon(Icons.play_arrow_outlined,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
            onTap: () => _fireDrip(context),
          ),
        ),
      ],
    );
  }

  Future<void> _fireBurst(BuildContext context) async {
    final levels = [
      LogLevel.debug,
      LogLevel.info,
      LogLevel.error,
      LogLevel.info,
      LogLevel.debug,
      LogLevel.error,
      LogLevel.info,
      LogLevel.debug,
      LogLevel.info,
      LogLevel.error,
    ];
    for (int i = 0; i < levels.length; i++) {
      await SimpleLoggerOverlay.log(
        'Burst log #${i + 1} — level ${levels[i].name}',
        level: levels[i],
        tag: 'BurstTest',
      );
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('10 logs fired'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _fireDrip(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Drip started — watch the FAB pulse'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    for (int i = 1; i <= 5; i++) {
      await Future.delayed(const Duration(seconds: 1));
      await SimpleLoggerOverlay.log(
        'Drip log #$i at ${DateTime.now().toIso8601String()}',
        level: i.isOdd ? LogLevel.info : LogLevel.debug,
        tag: 'DripTest',
      );
    }
  }
}

class _IntegrationTiles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Card(
          elevation: 0,
          color: cs.surfaceContainerHighest,
          margin: const EdgeInsets.only(bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Icon(Icons.view_list_outlined,
                color: cs.onSurfaceVariant),
            title: Text('BLoC Example',
                style: TextStyle(
                    color: cs.onSurface, fontWeight: FontWeight.w600)),
            subtitle: Text(
                'Fetch users — logs BLoC events + Dio network calls',
                style: TextStyle(color: cs.onSurfaceVariant)),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: cs.onSurfaceVariant),
            onTap: () => BlocUserListRoute().push(context),
          ),
        ),
      ],
    );
  }
}

class _OverlayTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () =>
          SimpleLoggerOverlay.show(context, navigatorKey: rootNavigatorKey),
      icon: const Icon(Icons.open_in_new_outlined),
      label: const Text('Open Logger Overlay'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
