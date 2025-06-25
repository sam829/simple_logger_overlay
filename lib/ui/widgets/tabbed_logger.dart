import 'package:flutter/material.dart';

import '../../core/log_storage_service.dart';
import '../../models/network_log.dart';
import '../../models/simple_log.dart';
import 'log_card.dart';

/// A widget that displays application logs in a tabbed interface.
/// 
/// This widget provides a tabbed interface with two tabs:
/// 1. Logs - Shows application logs ([SimpleLog] entries)
/// 2. Network - Shows network request/response logs ([NetworkLog] entries)
/// 
/// Features:
/// - Search functionality across log messages and tags
/// - Sort logs by timestamp (newest/oldest first)
/// - Pull-to-refresh to reload logs
/// - Responsive layout that works on different screen sizes
/// 
/// Example usage:
/// ```dart
/// const TabbedLogger();
/// ```
class TabbedLogger extends StatefulWidget {
  /// Creates a new [TabbedLogger] instance.
  const TabbedLogger({super.key});

  @override
  State<TabbedLogger> createState() => _TabbedLoggerState();
}

class _TabbedLoggerState extends State<TabbedLogger>
    with SingleTickerProviderStateMixin {
  /// Service for loading logs from persistent storage
  final _storage = LogStorageService();
  
  /// Controls the tab selection and animation
  late final TabController _tabController;
  
  /// List of application logs
  List<SimpleLog> _simpleLogs = [];
  
  /// List of network logs
  List<NetworkLog> _networkLogs = [];
  
  /// Current search query text
  String? _searchText;
  
  /// Sort direction (true = newest first, false = oldest first)
  bool _sortDesc = true;

  /// Controller for the search text field
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize tab controller with 2 tabs (Logs and Network)
    _tabController = TabController(length: 2, vsync: this);
    // Load initial logs
    _loadLogs();
  }

  /// Loads logs from storage and updates the UI
  /// 
  /// This method is called on init and when the user pulls to refresh.
  /// It loads both simple logs and network logs in parallel.
  Future<void> _loadLogs() async {
    // Load both types of logs in parallel
    final (simple, network) = await (
      _storage.getSimpleLogs(),
      _storage.getNetworkLogs(),
    ).wait;

    if (mounted) {
      setState(() {
        // Store logs in reverse chronological order (newest first by default)
        _simpleLogs = simple.reversed.toList();
        _networkLogs = network.reversed.toList();
      });
    }
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _controller.dispose();
    _tabController.dispose();
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

  /// Builds the search and sort control bar
  /// 
  /// Returns a row containing:
  /// - A search text field for filtering logs
  /// - A sort direction toggle button
  Widget _buildSearchAndSortBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Search text field
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (val) => setState(() => _searchText = val),
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Filter logs...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Sort direction toggle
          Tooltip(
            message: _sortDesc ? 'Newest first' : 'Oldest first',
            child: IconButton(
              icon: Icon(_sortDesc ? Icons.arrow_downward : Icons.arrow_upward),
              onPressed: () => setState(() => _sortDesc = !_sortDesc),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Filters and sorts simple logs based on the current search query and sort direction
  /// 
  /// Returns:
  /// A list of [SimpleLog] entries that match the search criteria,
  /// sorted according to the current sort direction.
  List<SimpleLog> _filteredSimpleLogs() {
    // Filter logs based on search text (if any)
    final filtered = _simpleLogs.where((log) {
      if (_searchText == null || _searchText!.isEmpty) {
        return true; // No search text, include all logs
      }
      
      final searchLower = _searchText!.toLowerCase();
      return log.message.toLowerCase().contains(searchLower) ||
          log.tag.toLowerCase().contains(searchLower);
    }).toList();

    // Sort logs by timestamp
    filtered.sort((a, b) => _sortDesc
        ? b.timestamp.compareTo(a.timestamp) // Newest first
        : a.timestamp.compareTo(b.timestamp)); // Oldest first

    return filtered;
  }

  /// Filters and sorts network logs based on the current search query and sort direction
  /// 
  /// Returns:
  /// A list of [NetworkLog] entries that match the search criteria,
  /// sorted according to the current sort direction.
  List<NetworkLog> _filteredNetworkLogs() {
    // Filter logs based on search text (if any)
    final filtered = _networkLogs.where((log) {
      if (_searchText == null || _searchText!.isEmpty) {
        return true; // No search text, include all logs
      }
      
      final searchLower = _searchText!.toLowerCase();
      return log.url.toLowerCase().contains(searchLower) ||
          log.method.toLowerCase().contains(searchLower);
    }).toList();

    // Sort logs by timestamp
    filtered.sort((a, b) => _sortDesc
        ? b.timestamp.compareTo(a.timestamp) // Newest first
        : a.timestamp.compareTo(b.timestamp)); // Oldest first

    return filtered;
  }
}
