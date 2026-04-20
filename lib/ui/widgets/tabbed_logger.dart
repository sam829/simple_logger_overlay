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

  bool get _isFiltering => _searchText != null && _searchText!.isNotEmpty;

  List<SimpleOverlayLog> get _filteredSimpleLogs {
    final filtered = _simpleLogs.where((log) {
      final q = _searchText!.toLowerCase();
      return log.message.toLowerCase().contains(q) ||
          log.tag.toLowerCase().contains(q);
    }).toList();
    filtered.sort((a, b) => _sortDesc
        ? b.timestamp.compareTo(a.timestamp)
        : a.timestamp.compareTo(b.timestamp));
    return filtered;
  }

  List<SimpleOverlayNetworkLog> get _filteredNetworkLogs {
    final filtered = _networkLogs.where((log) {
      final q = _searchText!.toLowerCase();
      return log.url.toLowerCase().contains(q) ||
          log.method.toLowerCase().contains(q);
    }).toList();
    filtered.sort((a, b) => _sortDesc
        ? b.timestamp.compareTo(a.timestamp)
        : a.timestamp.compareTo(b.timestamp));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SimpleOverlayLocalizations.of(context);

    return Column(
      children: [
        _buildSearchBar(l10n),
        const SizedBox(height: 4),
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

  Widget _buildLogList(SimpleOverlayLocalizations l10n) {
    final logs = _isFiltering ? _filteredSimpleLogs : _simpleLogs;

    if (logs.isEmpty) {
      if (_isFiltering) {
        return _emptyState(Icons.search_off, l10n.noResultsTitle,
            l10n.noResultsSubtitle(_searchText!));
      }
      return _emptyState(
          Icons.receipt_long_outlined, l10n.noLogsTitle, l10n.noLogsSubtitle);
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
    final logs = _isFiltering ? _filteredNetworkLogs : _networkLogs;

    if (logs.isEmpty) {
      if (_isFiltering) {
        return _emptyState(Icons.search_off, l10n.noResultsTitle,
            l10n.noNetworkResultsSubtitle(_searchText!));
      }
      return _emptyState(Icons.wifi_off_outlined, l10n.noNetworkTitle,
          l10n.noNetworkSubtitle);
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
