import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/log_storage_service.dart';
import '../../core/simple_overlay_localizations.dart';
import '../../models/network_log.dart';
import '../../models/simple_log.dart';
import 'log_card.dart';

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

  // Filter state: empty set = show all levels
  final Set<LogLevel> _levelFilter = {};
  // null = all, true = success only, false = error only
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
    var logs = _simpleLogs.where((log) {
      if (_levelFilter.isNotEmpty && !_levelFilter.contains(log.level)) {
        return false;
      }
      if (_searchText != null && _searchText!.isNotEmpty) {
        final q = _searchText!.toLowerCase();
        if (!log.message.toLowerCase().contains(q) &&
            !log.tag.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    logs.sort((a, b) => _sortDesc
        ? b.timestamp.compareTo(a.timestamp)
        : a.timestamp.compareTo(b.timestamp));
    return logs;
  }

  List<SimpleOverlayNetworkLog> get _displayedNetworkLogs {
    var logs = _networkLogs.where((log) {
      if (_networkSuccessFilter != null &&
          log.isSuccess != _networkSuccessFilter) {
        return false;
      }
      if (_searchText != null && _searchText!.isNotEmpty) {
        final q = _searchText!.toLowerCase();
        if (!log.url.toLowerCase().contains(q) &&
            !log.method.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    logs.sort((a, b) => _sortDesc
        ? b.timestamp.compareTo(a.timestamp)
        : a.timestamp.compareTo(b.timestamp));
    return logs;
  }

  bool get _hasActiveFilters =>
      _levelFilter.isNotEmpty || _networkSuccessFilter != null;

  @override
  Widget build(BuildContext context) {
    final l10n = SimpleOverlayLocalizations.of(context);

    return Column(
      children: [
        _buildSearchBar(l10n),
        _buildFilterRow(),
        TabBar.secondary(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.logsTab(_simpleLogs.length)),
            Tab(text: l10n.networkTab(_networkLogs.length)),
          ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
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
          const SizedBox(width: 8),
          Tooltip(
            message: _sortDesc ? l10n.sortNewest : l10n.sortOldest,
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
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (_, __) {
        final onSimple = _tabController.index == 0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
          child: Row(
            children: [
              if (onSimple) ..._simpleLevelChips(),
              if (!onSimple) ..._networkStatusChips(),
              if (_hasActiveFilters) ...[
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Clear'),
                  avatar: const Icon(Icons.close, size: 14),
                  onPressed: () => setState(() {
                    _levelFilter.clear();
                    _networkSuccessFilter = null;
                  }),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<Widget> _simpleLevelChips() {
    return LogLevel.values.map((level) {
      final selected = _levelFilter.contains(level);
      final (label, icon) = switch (level) {
        LogLevel.debug => ('Debug', Icons.bug_report_outlined),
        LogLevel.info => ('Info', Icons.info_outline),
        LogLevel.error => ('Error', Icons.error_outline),
      };
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: FilterChip(
          label: Text(label),
          avatar: Icon(icon, size: 14),
          selected: selected,
          onSelected: (val) => setState(() {
            if (val) {
              _levelFilter.add(level);
            } else {
              _levelFilter.remove(level);
            }
          }),
          visualDensity: VisualDensity.compact,
        ),
      );
    }).toList();
  }

  List<Widget> _networkStatusChips() {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 6),
        child: FilterChip(
          label: const Text('Success'),
          avatar: const Icon(Icons.check_circle_outline, size: 14),
          selected: _networkSuccessFilter == true,
          onSelected: (val) => setState(() {
            _networkSuccessFilter = val ? true : null;
          }),
          visualDensity: VisualDensity.compact,
        ),
      ),
      FilterChip(
        label: const Text('Error'),
        avatar: const Icon(Icons.cancel_outlined, size: 14),
        selected: _networkSuccessFilter == false,
        onSelected: (val) => setState(() {
          _networkSuccessFilter = val ? false : null;
        }),
        visualDensity: VisualDensity.compact,
      ),
    ];
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
        itemBuilder: (_, i) {
          final log = logs[i];
          return _animatedCard(
            key: ValueKey(log.timestamp.microsecondsSinceEpoch),
            child: SimpleOverlayLogCard.simple(simple: log),
          );
        },
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
        itemBuilder: (_, i) {
          final log = logs[i];
          return _animatedCard(
            key: ValueKey(log.timestamp.microsecondsSinceEpoch),
            child: SimpleOverlayLogCard.network(network: log),
          );
        },
      ),
    );
  }

  Widget _animatedCard({required Key key, required Widget child}) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (_, value, c) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 16),
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
                style:
                    theme.textTheme.bodySmall?.copyWith(color: cs.outline)),
          ],
        ),
      ),
    );
  }
}
