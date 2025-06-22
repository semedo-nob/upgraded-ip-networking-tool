import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ip_networking_tool/screens/home_screen.dart';
import '../utils/history_storage.dart';
import '../utils/export_to_csv.dart';
import '../models/ip_info.dart';
import '../widgets/lan_output_tile.dart';
import '../widgets/bitwise_view.dart';

class OutputTab extends StatefulWidget {
  const OutputTab({super.key});

  @override
  State<OutputTab> createState() => _OutputTabState();
}

class _OutputTabState extends State<OutputTab> {
  String _searchQuery = '';
  int _currentPage = 0;
  final int _rowsPerPage = 10;
  bool _isLoading = false;
  Future<List<Map<String, dynamic>>>? _historyFuture;
  int? _selectedHistoryIndex;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    print('OutputTab: Refreshing history');
    setState(() {
      _isLoading = true;
      _historyFuture = HistoryStorage.getHistory().catchError((e) {
        print('OutputTab: Error fetching history: $e');
        return <Map<String, dynamic>>[];
      }).whenComplete(() {
        print('OutputTab: History future completed');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      });
    });
  }

  Future<void> _exportAllHistory(List<Map<String, dynamic>> history) async {
    setState(() => _isLoading = true);
    try {
      for (var entry in history) {
        if (entry['ipInfo'] is Map<String, dynamic>) {
          final ipInfo = IpInfo.fromJson(entry['ipInfo'] as Map<String, dynamic>);
          await exportToCsv({
            'input': entry['baseIp'] ?? 'Unknown',
            'subnets': ipInfo.lans.map((lan) => lan.toJson()).toList(),
          });
        } else {
          print('OutputTab: Skipping invalid history entry: $entry');
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All valid history exported to CSV files')),
        );
      }
    } catch (e, stackTrace) {
      print('OutputTab: Error exporting all history: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export history')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        print('OutputTab: FutureBuilder state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, hasError: ${snapshot.hasError}');
        if (_isLoading || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('OutputTab: FutureBuilder error: ${snapshot.error}, StackTrace: ${snapshot.stackTrace}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load history.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshHistory,
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final filePath = await HistoryStorage.getHistoryFilePath();
                      await File(filePath).delete();
                      print('OutputTab: History file deleted');
                      _refreshHistory();
                    } catch (e) {
                      print('OutputTab: Error deleting history file: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to clear history')),
                        );
                      }
                    }
                  },
                  child: const Text('Clear History'),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('OutputTab: No history data available');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No calculations yet.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text('Go to Input Tab'),
                ),
              ],
            ),
          );
        }

        final history = snapshot.data!;
        print('OutputTab: Displaying ${history.length} history entries');
        final validHistory = history
            .asMap()
            .entries
            .where((entry) => entry.value['ipInfo'] is Map<String, dynamic>)
            .toList();

        if (validHistory.isEmpty) {
          print('OutputTab: No valid history entries found');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No valid calculations found.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final filePath = await HistoryStorage.getHistoryFilePath();
                      await File(filePath).delete();
                      print('OutputTab: History file deleted');
                      _refreshHistory();
                    } catch (e) {
                      print('OutputTab: Error deleting history file: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to clear history')),
                        );
                      }
                    }
                  },
                  child: const Text('Clear History'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text('Go to Input Tab'),
                ),
              ],
            ),
          );
        }

        // Find the entry to display
        MapEntry<int, Map<String, dynamic>> selectedEntryInValidHistory;
        if (_selectedHistoryIndex != null) {
          selectedEntryInValidHistory = validHistory.firstWhere(
                (entry) => entry.key == _selectedHistoryIndex,
            orElse: () => validHistory.first,
          );
        } else {
          selectedEntryInValidHistory = validHistory.first;
        }

        final selectedEntry = selectedEntryInValidHistory.value;
        IpInfo ipInfo;
        try {
          ipInfo = IpInfo.fromJson(selectedEntry['ipInfo'] as Map<String, dynamic>);
        } catch (e, stackTrace) {
          print('OutputTab: Error parsing ipInfo: $e\n$stackTrace');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Corrupted history data.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshHistory,
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final filePath = await HistoryStorage.getHistoryFilePath();
                      await File(filePath).delete();
                      print('OutputTab: History file deleted');
                      _refreshHistory();
                    } catch (e) {
                      print('OutputTab: Error deleting history file: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to clear history')),
                        );
                      }
                    }
                  },
                  child: const Text('Clear History'),
                ),
              ],
            ),
          );
        }

        final filteredLans = ipInfo.lans.where((lan) {
          if (_searchQuery.isEmpty) return true;
          final query = _searchQuery.toLowerCase();
          return lan.name.toLowerCase().contains(query) ||
              lan.networkAddress.toLowerCase().contains(query) ||
              lan.broadcastAddress.toLowerCase().contains(query) ||
              lan.usableIps.toLowerCase().contains(query) ||
              lan.subnetMask.toLowerCase().contains(query) ||
              lan.cidr.toLowerCase().contains(query);
        }).toList();
        final pageCount = (filteredLans.length / _rowsPerPage).ceil();
        final startIndex = _currentPage * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage).clamp(0, filteredLans.length);
        final displayedLans = filteredLans.sublist(startIndex, endIndex);

        return RefreshIndicator(
          onRefresh: () async {
            _refreshHistory();
            await _historyFuture;
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Base IP: ${ipInfo.baseIp}/${ipInfo.cidr}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    DropdownButton<int>(
                      hint: const Text('Select History'),
                      value: selectedEntryInValidHistory.key,
                      items: validHistory.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text('Calc ${entry.key + 1}: ${entry.value['baseIp'] ?? 'Unknown'} (${entry.value['mode'] ?? 'Unknown'})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedHistoryIndex = value;
                            _currentPage = 0;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search LANs',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                  ),
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 0;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (displayedLans.isNotEmpty) ...[
                  Text(
                    'LANs (${filteredLans.length}):',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...displayedLans.map((lan) => LanOutputTile(
                    lan: lan,
                    onVisualize: () {
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => BitwiseView(
                            lanName: lan.name,
                            ipAddress: lan.networkAddress,
                            subnetMask: lan.subnetMask,
                            networkAddress: lan.networkAddress,
                            broadcastAddress: lan.broadcastAddress,
                          ),
                        );
                      }
                    },
                  )),
                  if (pageCount > 1) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        Text('Page ${_currentPage + 1} of $pageCount'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < pageCount - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading || validHistory.isEmpty
                      ? null
                      : () async => await _exportAllHistory(validHistory.map((e) => e.value).toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                  child: const Text('Export All to CSV'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    print('OutputTab: Disposing');
    super.dispose();
  }
}