import 'package:example/app/simple_overlay_logger_app.dart';
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
                const SizedBox(height: 24),
                _SectionHeader('Settings'),
                _SettingsTiles(),
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

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

class _SettingsTiles extends StatefulWidget {
  @override
  State<_SettingsTiles> createState() => _SettingsTilesState();
}

class _SettingsTilesState extends State<_SettingsTiles> {
  @override
  void initState() {
    super.initState();
    appSettings.addListener(_rebuild);
  }

  @override
  void dispose() {
    appSettings.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        _ThemeModeTile(cs: cs),
        const SizedBox(height: 8),
        _DynamicThemeTile(cs: cs),
        const SizedBox(height: 8),
        _SeedColorTile(cs: cs),
        const SizedBox(height: 8),
        _LocaleTile(cs: cs),
      ],
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final modes = [
      (ThemeMode.system, 'System', Icons.brightness_auto_outlined),
      (ThemeMode.light, 'Light', Icons.light_mode_outlined),
      (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
    ];

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined, color: cs.onSurfaceVariant, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Theme Mode',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                segments: modes
                    .map((m) => ButtonSegment<ThemeMode>(
                          value: m.$1,
                          label: Text(m.$2),
                          icon: Icon(m.$3),
                        ))
                    .toList(),
                selected: {appSettings.themeMode},
                onSelectionChanged: (s) => appSettings.setThemeMode(s.first),
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(0, 40)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicThemeTile extends StatelessWidget {
  const _DynamicThemeTile({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        secondary: Icon(Icons.auto_awesome_outlined, color: cs.onSurfaceVariant),
        title: Text(
          'Dynamic Color',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Use wallpaper-derived colors (Android 12+)',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        value: appSettings.isDynamicTheme,
        onChanged: (v) => appSettings.setDynamicTheme(v),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _LocaleTile extends StatelessWidget {
  const _LocaleTile({required this.cs});
  final ColorScheme cs;

  static const _locales = [
    (null, 'System'),
    (Locale('en'), 'English'),
    (Locale('es'), 'Español'),
    (Locale('fr'), 'Français'),
    (Locale('ar'), 'العربية'),
    (Locale('de'), 'Deutsch'),
    (Locale('ja'), '日本語'),
  ];

  @override
  Widget build(BuildContext context) {
    final current = appSettings.locale;
    final label = _locales
        .firstWhere((e) => e.$1 == current, orElse: () => _locales.first)
        .$2;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(Icons.language_outlined, color: cs.onSurfaceVariant),
        title: Text(
          'Locale',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
        trailing: Icon(Icons.expand_more_rounded,
            color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
        onTap: () => _showPicker(context),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Locale',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onSurface,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ..._locales.map((entry) {
              final isSelected = appSettings.locale == entry.$1;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                title: Text(entry.$2,
                    style: TextStyle(
                      color: isSelected ? cs.primary : cs.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    )),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: cs.primary)
                    : null,
                onTap: () {
                  appSettings.setLocale(entry.$1);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SeedColorTile extends StatelessWidget {
  const _SeedColorTile({required this.cs});
  final ColorScheme cs;

  static const _presets = [
    (Color(0xFF546E7A), 'Blue Grey'),
    (Color(0xFF52B788), 'Sage Mint'),
    (Color(0xFF6750A4), 'Material Purple'),
    (Color(0xFF0077B6), 'Ocean Blue'),
    (Color(0xFFE63946), 'Coral Red'),
    (Color(0xFFE76F51), 'Burnt Orange'),
    (Color(0xFF2A9D8F), 'Teal'),
    (Color(0xFFF4A261), 'Sandy Amber'),
    (Color(0xFF457B9D), 'Steel Blue'),
    (Color(0xFF6D6875), 'Dusty Mauve'),
    (Color(0xFF2D6A4F), 'Forest Green'),
    (Color(0xFFE9C46A), 'Golden Yellow'),
  ];

  @override
  Widget build(BuildContext context) {
    final disabled = appSettings.isDynamicTheme;
    final fg = disabled
        ? cs.onSurface.withValues(alpha: 0.38)
        : cs.onSurface;
    final fgSub = disabled
        ? cs.onSurfaceVariant.withValues(alpha: 0.38)
        : cs.onSurfaceVariant;

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerHighest,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(
            radius: 12,
            backgroundColor:
                disabled ? cs.onSurface.withValues(alpha: 0.2) : appSettings.seedColor,
          ),
          title: Text(
            'Seed Color',
            style: TextStyle(color: fg, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            disabled ? 'Disabled — dynamic color is on' : _labelForColor(appSettings.seedColor),
            style: TextStyle(color: fgSub),
          ),
          trailing: Icon(Icons.color_lens_outlined,
              color: fgSub.withValues(alpha: 0.6)),
          onTap: disabled ? null : () => _showColorPicker(context),
        ),
      ),
    );
  }

  String _labelForColor(Color color) {
    final match = _presets
        .where((e) => e.$1.toARGB32() == color.toARGB32())
        .firstOrNull;
    return match?.$2 ?? 'Custom';
  }

  void _showColorPicker(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Seed Color',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: cs.onSurface,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a seed — both app and overlay update live.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _presets.map((entry) {
                  final isSelected =
                      appSettings.seedColor.toARGB32() == entry.$1.toARGB32();
                  return GestureDetector(
                    onTap: () {
                      appSettings.setSeedColor(entry.$1);
                      Navigator.pop(context);
                    },
                    child: Tooltip(
                      message: entry.$2,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: entry.$1,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: cs.onSurface,
                                  width: 3,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: entry.$1.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? Icon(Icons.check_rounded,
                                color: _contrastColor(entry.$1), size: 20)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Color _contrastColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.4 ? Colors.black87 : Colors.white;
  }
}
