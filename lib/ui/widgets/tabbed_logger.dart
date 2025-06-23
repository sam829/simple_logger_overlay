import 'package:flutter/material.dart';

import '../../core/log_storage_service.dart';
import '../../models/network_log.dart';
import '../../models/simple_log.dart';
import 'log_card.dart';

class TabbedLogger extends StatefulWidget {
  const TabbedLogger({super.key});

  @override
  State<TabbedLogger> createState() => _TabbedLoggerState();
}

class _TabbedLoggerState extends State<TabbedLogger>
    with SingleTickerProviderStateMixin {
  final _storage = LogStorageService();
  late TabController _tabController;
  List<SimpleLog> _simpleLogs = [];
  List<NetworkLog> _networkLogs = [];
  String? _searchText;
  bool _sortDesc = true;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final simple = await _storage.getSimpleLogs();
    final network = await _storage.getNetworkLogs();

    setState(() {
      _simpleLogs = simple.reversed.toList();
      _networkLogs = network.reversed.toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildSearchAndSortBar(),
        TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Logs'),
            Tab(text: 'Network'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              RefreshIndicator(
                onRefresh: _loadLogs,
                child: ListView.builder(
                  itemCount: _filteredSimpleLogs().length,
                  itemBuilder: (_, index) =>
                      LogCard.simple(simple: _filteredSimpleLogs()[index]),
                ),
              ),
              RefreshIndicator(
                onRefresh: _loadLogs,
                child: ListView.builder(
                  itemCount: _filteredNetworkLogs().length,
                  itemBuilder: (_, index) =>
                      LogCard.network(network: _filteredNetworkLogs()[index]),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSearchAndSortBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (val) => setState(() => _searchText = val),
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          IconButton(
            icon: Icon(_sortDesc ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: () => setState(() => _sortDesc = !_sortDesc),
          ),
        ],
      ),
    );
  }

  List<SimpleLog> _filteredSimpleLogs() {
    final filtered = _simpleLogs.where((log) {
      return _searchText == null || _searchText!.isEmpty
          ? true
          : log.message.toLowerCase().contains(_searchText!.toLowerCase()) ||
              log.tag.toLowerCase().contains(_searchText!.toLowerCase());
    }).toList();

    filtered.sort((a, b) => _sortDesc
        ? b.timestamp.compareTo(a.timestamp)
        : a.timestamp.compareTo(b.timestamp));

    return filtered;
  }

  List<NetworkLog> _filteredNetworkLogs() {
    final filtered = _networkLogs.where((log) {
      return _searchText == null || _searchText!.isEmpty
          ? true
          : log.url.toLowerCase().contains(_searchText!.toLowerCase()) ||
              log.method.toLowerCase().contains(_searchText!.toLowerCase());
    }).toList();

    filtered.sort((a, b) => _sortDesc
        ? b.timestamp.compareTo(a.timestamp)
        : a.timestamp.compareTo(b.timestamp));

    return filtered;
  }
}
