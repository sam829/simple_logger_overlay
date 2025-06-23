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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
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
                  itemCount: _simpleLogs.length,
                  itemBuilder: (_, index) =>
                      LogCard.simple(simple: _simpleLogs[index]),
                ),
              ),
              RefreshIndicator(
                onRefresh: _loadLogs,
                child: ListView.builder(
                  itemCount: _networkLogs.length,
                  itemBuilder: (_, index) =>
                      LogCard.network(network: _networkLogs[index]),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
