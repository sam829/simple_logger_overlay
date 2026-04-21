import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/log_storage_service.dart';
import '../../core/simple_overlay_localizations.dart';
import '../../models/network_log.dart';
import '../../models/simple_log.dart';
import 'log_card.dart';

// M3 emphasized decelerate — best for elements entering the screen
const _kEntryEasing = Cubic(0.05, 0.7, 0.1, 1.0);
const _kEntryDuration = Duration(milliseconds: 350);

// Spring overshoot for high-severity entries (error logs, failed requests)
const _kErrorEasing = Cubic(0.34, 1.4, 0.64, 1.0);
const _kErrorDuration = Duration(milliseconds: 300);

class SimpleOverlayTabbedLogger extends StatefulWidget {
  const SimpleOverlayTabbedLogger({super.key});

  @override
  State<SimpleOverlayTabbedLogger> createState() =>
      _SimpleOverlayTabbedLoggerState();
}

class _SimpleOverlayTabbedLoggerState extends State<SimpleOverlayTabbedLogger>
    with SingleTickerProviderStateMixin {
  final _storage = SimpleOverlayLogStorageService();

  late final TabController _tabController;

  final List<SimpleOverlayLog> _simpleLogs = [];
  final List<SimpleOverlayNetworkLog> _networkLogs = [];

  String? _searchText;
  bool _sortDesc = true;
  final TextEditingController _searchController = TextEditingController();

  // empty = all levels shown
  final Set<LogLevel> _levelFilter = {};
  // null = all, true = success, false = error
  bool? _networkSuccessFilter;

  StreamSubscription<SimpleOverlayLog>? _simpleSubscription;
  StreamSubscription<SimpleOverlayNetworkLog>? _networkSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLogs();
    _subscribeToLiveUpdates();
  }

  void _subscribeToLiveUpdates() {
    _simpleSubscription = _storage.simpleLogStream.listen((log) {
      if (!mounted) return;
      setState(() => _simpleLogs.insert(0, log));
    });
    _networkSubscription = _storage.networkLogStream.listen((log) {
      if (!mounted) return;
      setState(() => _networkLogs.insert(0, log));
    });
  }

  Future<void> _loadLogs() async {
    final (simple, network) = await (
      _storage.getSimpleLogs(),
      _storage.getNetworkLogs(),
    ).wait;
    if (!mounted) return;
    setState(() {
      _simpleLogs
        ..clear()
        ..addAll(simple.reversed);
      _networkLogs
        ..clear()
        ..addAll(network.reversed);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _simpleSubscription?.cancel();
    _networkSubscription?.cancel();
    super.dispose();
  }

  List<SimpleOverlayLog> get _displayedSimpleLogs {
    final logs =
        _simpleLogs.where((log) {
          if (_levelFilter.isNotEmpty && !_levelFilter.contains(log.level)) {
            return false;
          }
          if (_searchText != null && _searchText!.isNotEmpty) {
            final q = _searchText!.toLowerCase();
            return log.message.toLowerCase().contains(q) ||
                log.tag.toLowerCase().contains(q);
          }
          return true;
        }).toList()..sort(
          (a, b) => _sortDesc
              ? b.timestamp.compareTo(a.timestamp)
              : a.timestamp.compareTo(b.timestamp),
        );
    return logs;
  }

  List<SimpleOverlayNetworkLog> get _displayedNetworkLogs {
    final logs =
        _networkLogs.where((log) {
          if (_networkSuccessFilter != null &&
              log.isSuccess != _networkSuccessFilter) {
            return false;
          }
          if (_searchText != null && _searchText!.isNotEmpty) {
            final q = _searchText!.toLowerCase();
            return log.url.toLowerCase().contains(q) ||
                log.method.toLowerCase().contains(q);
          }
          return true;
        }).toList()..sort(
          (a, b) => _sortDesc
              ? b.timestamp.compareTo(a.timestamp)
              : a.timestamp.compareTo(b.timestamp),
        );
    return logs;
  }

  bool get _hasActiveFilters =>
      _levelFilter.isNotEmpty || _networkSuccessFilter != null;

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (_) => _FilterSheet(
        isSimpleTab: _tabController.index == 0,
        levelFilter: Set.of(_levelFilter),
        networkSuccessFilter: _networkSuccessFilter,
        onApply: (levels, networkSuccess) {
          setState(() {
            _levelFilter
              ..clear()
              ..addAll(levels);
            _networkSuccessFilter = networkSuccess;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SimpleOverlayLocalizations.of(context);

    return Column(
      children: [
        _buildSearchBar(l10n),
        AnimatedBuilder(
          animation: _tabController,
          builder: (_, _) => TabBar.secondary(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.logsTab(_simpleLogs.length)),
              Tab(text: l10n.networkTab(_networkLogs.length)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildLogList(l10n), _buildNetworkList(l10n)],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(SimpleOverlayLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: SearchBar(
              controller: _searchController,
              hintText: l10n.searchHint,
              leading: const Icon(Icons.search, size: 20),
              trailing: [
                if (_searchText?.isNotEmpty == true)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchText = null);
                    },
                  ),
              ],
              onChanged: (val) =>
                  setState(() => _searchText = val.isEmpty ? null : val),
              elevation: const WidgetStatePropertyAll(0),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Tooltip(
            message: _sortDesc ? 'Newest first' : 'Oldest first',
            child: IconButton.outlined(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    RotationTransition(turns: anim, child: child),
                child: Icon(
                  _sortDesc ? Icons.arrow_downward : Icons.arrow_upward,
                  key: ValueKey(_sortDesc),
                  size: 18,
                ),
              ),
              onPressed: () => setState(() => _sortDesc = !_sortDesc),
            ),
          ),
          const SizedBox(width: 4),
          // Animated badge dot — scales in/out with spring overshoot
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton.outlined(
                icon: Icon(
                  Icons.filter_list,
                  size: 18,
                  color: _hasActiveFilters ? cs.primary : null,
                ),
                onPressed: _openFilterSheet,
              ),
              Positioned(
                right: 6,
                top: 6,
                child: AnimatedScale(
                  scale: _hasActiveFilters ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogList(SimpleOverlayLocalizations l10n) {
    final logs = _displayedSimpleLogs;

    if (_simpleLogs.isEmpty) {
      return _emptyState(
        Icons.receipt_long_outlined,
        l10n.noLogsTitle,
        l10n.noLogsSubtitle,
      );
    }
    if (logs.isEmpty) {
      return _emptyState(
        Icons.filter_list_off,
        l10n.noResultsTitle,
        _searchText != null
            ? l10n.noResultsSubtitle(_searchText!)
            : 'No logs match the selected filters',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLogs,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: logs.length,
        itemBuilder: (_, i) => _animatedCard(
          key: ValueKey(logs[i].timestamp.microsecondsSinceEpoch),
          isError: logs[i].level == LogLevel.error,
          child: SimpleOverlayLogCard.simple(simple: logs[i]),
        ),
      ),
    );
  }

  Widget _buildNetworkList(SimpleOverlayLocalizations l10n) {
    final logs = _displayedNetworkLogs;

    if (_networkLogs.isEmpty) {
      return _emptyState(
        Icons.wifi_off_outlined,
        l10n.noNetworkTitle,
        l10n.noNetworkSubtitle,
      );
    }
    if (logs.isEmpty) {
      return _emptyState(
        Icons.filter_list_off,
        l10n.noResultsTitle,
        _searchText != null
            ? l10n.noNetworkResultsSubtitle(_searchText!)
            : 'No requests match the selected filters',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLogs,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: logs.length,
        itemBuilder: (_, i) => _animatedCard(
          key: ValueKey(logs[i].timestamp.microsecondsSinceEpoch),
          isError: !logs[i].isSuccess,
          child: SimpleOverlayLogCard.network(network: logs[i]),
        ),
      ),
    );
  }

  Widget _animatedCard({
    required Key key,
    required Widget child,
    bool isError = false,
  }) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: isError ? _kErrorDuration : _kEntryDuration,
      curve: isError ? _kErrorEasing : _kEntryEasing,
      builder: (_, value, c) => Opacity(
        // Clamp opacity so spring overshoot doesn't cause flicker
        opacity: value.clamp(0.0, 1.0),
        child: Transform.translate(
          // Overshoot curve makes value > 1.0 briefly → element bounces
          // slightly past its final position then settles (only for errors)
          offset: Offset(0, (1 - value) * (isError ? 14.0 : 20.0)),
          child: c,
        ),
      ),
      child: child,
    );
  }

  Widget _emptyState(IconData icon, String title, String subtitle) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: cs.outlineVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bottom sheet
// ---------------------------------------------------------------------------

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.isSimpleTab,
    required this.levelFilter,
    required this.networkSuccessFilter,
    required this.onApply,
  });

  final bool isSimpleTab;
  final Set<LogLevel> levelFilter;
  final bool? networkSuccessFilter;
  final void Function(Set<LogLevel> levels, bool? networkSuccess) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<LogLevel> _levels;
  late bool? _networkSuccess;

  @override
  void initState() {
    super.initState();
    _levels = Set.of(widget.levelFilter);
    _networkSuccess = widget.networkSuccessFilter;
  }

  void _apply() {
    widget.onApply(_levels, _networkSuccess);
    Navigator.of(context).pop();
  }

  void _clear() {
    setState(() {
      _levels.clear();
      _networkSuccess = null;
    });
    widget.onApply({}, null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final hasActive = _levels.isNotEmpty || _networkSuccess != null;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Filter',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              if (hasActive)
                TextButton(onPressed: _clear, child: const Text('Clear all')),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.isSimpleTab) ...[
            Text(
              'Log Level',
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _levelChip(
                  cs: cs,
                  level: LogLevel.debug,
                  label: 'Debug',
                  icon: Icons.bug_report_outlined,
                  selectedBg: cs.tertiaryContainer,
                  selectedFg: cs.onTertiaryContainer,
                  accentBorder: cs.tertiary,
                ),
                _levelChip(
                  cs: cs,
                  level: LogLevel.info,
                  label: 'Info',
                  icon: Icons.info_outline,
                  selectedBg: cs.primaryContainer,
                  selectedFg: cs.onPrimaryContainer,
                  accentBorder: cs.primary,
                ),
                _levelChip(
                  cs: cs,
                  level: LogLevel.error,
                  label: 'Error',
                  icon: Icons.error_outline,
                  selectedBg: cs.errorContainer,
                  selectedFg: cs.onErrorContainer,
                  accentBorder: cs.error,
                ),
              ],
            ),
          ] else ...[
            Text(
              'Request Status',
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _networkChip(
                  cs: cs,
                  value: true,
                  label: 'Success',
                  icon: Icons.check_circle_outline,
                  selectedBg: cs.secondaryContainer,
                  selectedFg: cs.onSecondaryContainer,
                  accentBorder: cs.secondary,
                ),
                _networkChip(
                  cs: cs,
                  value: false,
                  label: 'Error',
                  icon: Icons.cancel_outlined,
                  selectedBg: cs.errorContainer,
                  selectedFg: cs.onErrorContainer,
                  accentBorder: cs.error,
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _apply, child: const Text('Apply')),
          ),
        ],
      ),
    );
  }

  Widget _levelChip({
    required ColorScheme cs,
    required LogLevel level,
    required String label,
    required IconData icon,
    required Color selectedBg,
    required Color selectedFg,
    required Color accentBorder,
  }) {
    final selected = _levels.contains(level);
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? selectedFg : cs.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? selectedFg : cs.onSurfaceVariant,
      ),
      selected: selected,
      selectedColor: selectedBg,
      checkmarkColor: selectedFg,
      showCheckmark: false,
      side: selected
          ? BorderSide(color: accentBorder.withValues(alpha: 0.45), width: 1.5)
          : BorderSide(color: cs.outlineVariant, width: 1.0),
      onSelected: (v) =>
          setState(() => v ? _levels.add(level) : _levels.remove(level)),
    );
  }

  Widget _networkChip({
    required ColorScheme cs,
    required bool value,
    required String label,
    required IconData icon,
    required Color selectedBg,
    required Color selectedFg,
    required Color accentBorder,
  }) {
    final selected = _networkSuccess == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? selectedFg : cs.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? selectedFg : cs.onSurfaceVariant,
      ),
      selected: selected,
      selectedColor: selectedBg,
      checkmarkColor: selectedFg,
      showCheckmark: false,
      side: selected
          ? BorderSide(color: accentBorder.withValues(alpha: 0.45), width: 1.5)
          : BorderSide(color: cs.outlineVariant, width: 1.0),
      onSelected: (_) =>
          setState(() => _networkSuccess = selected ? null : value),
    );
  }
}
