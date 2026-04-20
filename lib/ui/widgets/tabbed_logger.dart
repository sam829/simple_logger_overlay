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
    final logs = _simpleLogs.where((log) {
      if (_levelFilter.isNotEmpty && !_levelFilter.contains(log.level)) {
        return false;
      }
      if (_searchText != null && _searchText!.isNotEmpty) {
        final q = _searchText!.toLowerCase();
        return log.message.toLowerCase().contains(q) ||
            log.tag.toLowerCase().contains(q);
      }
      return true;
    }).toList()
      ..sort((a, b) => _sortDesc
          ? b.timestamp.compareTo(a.timestamp)
          : a.timestamp.compareTo(b.timestamp));
    return logs;
  }

  List<SimpleOverlayNetworkLog> get _displayedNetworkLogs {
    final logs = _networkLogs.where((log) {
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
    }).toList()
      ..sort((a, b) => _sortDesc
          ? b.timestamp.compareTo(a.timestamp)
          : a.timestamp.compareTo(b.timestamp));
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
          builder: (_, __) => TabBar.secondary(
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
            children: [
              _buildLogList(l10n),
              _buildNetworkList(l10n),
            ],
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
                  EdgeInsets.symmetric(horizontal: 12)),
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
          Badge(
            isLabelVisible: _hasActiveFilters,
            backgroundColor: cs.primary,
            child: IconButton.outlined(
              icon: Icon(
                Icons.filter_list,
                size: 18,
                color: _hasActiveFilters ? cs.primary : null,
              ),
              onPressed: _openFilterSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList(SimpleOverlayLocalizations l10n) {
    final logs = _displayedSimpleLogs;

    if (_simpleLogs.isEmpty) {
      return _emptyState(
          Icons.receipt_long_outlined, l10n.noLogsTitle, l10n.noLogsSubtitle);
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
          child: SimpleOverlayLogCard.simple(simple: logs[i]),
        ),
      ),
    );
  }

  Widget _buildNetworkList(SimpleOverlayLocalizations l10n) {
    final logs = _displayedNetworkLogs;

    if (_networkLogs.isEmpty) {
      return _emptyState(Icons.wifi_off_outlined, l10n.noNetworkTitle,
          l10n.noNetworkSubtitle);
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
          child: SimpleOverlayLogCard.network(network: logs[i]),
        ),
      ),
    );
  }

  Widget _animatedCard({required Key key, required Widget child}) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: _kEntryDuration,
      curve: _kEntryEasing,
      builder: (_, value, c) => Opacity(
        opacity: value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 20),
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
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.outline)),
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
              Text('Filter',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: cs.onSurface)),
              const Spacer(),
              if (hasActive)
                TextButton(
                  onPressed: _clear,
                  child: const Text('Clear all'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.isSimpleTab) ...[
            Text('Log Level',
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            _levelOption(context, LogLevel.debug, 'Debug',
                Icons.bug_report_outlined, cs.tertiary),
            _levelOption(context, LogLevel.info, 'Info', Icons.info_outline,
                cs.primary),
            _levelOption(context, LogLevel.error, 'Error', Icons.error_outline,
                cs.error),
          ] else ...[
            Text('Request Status',
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            _networkOption(
                context, true, 'Success', Icons.check_circle_outline, cs.primary),
            _networkOption(
                context, false, 'Error', Icons.cancel_outlined, cs.error),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _apply,
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelOption(BuildContext context, LogLevel level, String label,
      IconData icon, Color accent) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final selected = _levels.contains(level);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() {
          if (selected) {
            _levels.remove(level);
          } else {
            _levels.add(level);
          }
        }),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.12)
                : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? accent.withValues(alpha: 0.5) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: selected ? accent : cs.onSurfaceVariant),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selected ? accent : cs.onSurface,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    )),
              ),
              if (selected)
                Icon(Icons.check_rounded, size: 18, color: accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _networkOption(BuildContext context, bool successValue, String label,
      IconData icon, Color accent) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final selected = _networkSuccess == successValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() {
          _networkSuccess = selected ? null : successValue;
        }),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.12)
                : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? accent.withValues(alpha: 0.5) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: selected ? accent : cs.onSurfaceVariant),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selected ? accent : cs.onSurface,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    )),
              ),
              if (selected)
                Icon(Icons.check_rounded, size: 18, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
