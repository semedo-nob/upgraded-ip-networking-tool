import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/history_storage.dart';
import '../utils/export_to_csv.dart';
import '../models/ip_info.dart';

class ExportTab extends StatefulWidget {
  const ExportTab({super.key});

  @override
  State<ExportTab> createState() => _ExportTabState();
}

class _ExportTabState extends State<ExportTab> {
  bool _isLoading = false;

  Future<void> _exportToCsvFile(Map<String, dynamic>? entry) async {
    if (entry == null || entry['ipInfo'] is! Map<String, dynamic>) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid calculation to export')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ipInfo = IpInfo.fromJson(entry['ipInfo'] as Map<String, dynamic>);
      await exportToCsv({
        'input': entry['baseIp'] ?? 'Unknown',
        'subnets': ipInfo.lans.map((lan) => lan.toJson()).toList(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported to CSV')),
        );
      }
    } catch (e, stackTrace) {
      print('ExportTab: Error exporting to CSV: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export to CSV')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportToPdf(Map<String, dynamic>? entry) async {
    if (entry == null || entry['ipInfo'] is! Map<String, dynamic>) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid calculation to export')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ipInfo = IpInfo.fromJson(entry['ipInfo'] as Map<String, dynamic>);
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('IP Networking Results', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Base IP: ${ipInfo.baseIp}/${ipInfo.cidr}'),
              pw.Text('Subnet Mask: ${ipInfo.subnetMask}'),
              pw.SizedBox(height: 10),
              pw.Text('LANs:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...ipInfo.lans.map((lan) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('LAN: ${lan.name}'),
                  pw.Text('Required Users: ${lan.requiredUsers}'),
                  pw.Text('CIDR: ${lan.cidr}'),
                  pw.Text('Subnet Mask: ${lan.subnetMask}'),
                  pw.Text('Network Address: ${lan.networkAddress}'),
                  pw.Text('Broadcast Address: ${lan.broadcastAddress}'),
                  pw.Text('Usable IPs: ${lan.usableIps}'),
                  pw.Text('IP Waste: ${lan.ipWaste}'),
                  pw.SizedBox(height: 10),
                ],
              )),
            ],
          ),
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/ip_networking_results_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported to PDF')),
        );
      }
    } catch (e, stackTrace) {
      print('ExportTab: Error exporting to PDF: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export to PDF')),
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: HistoryStorage.getHistory(),
      builder: (context, snapshot) {
        print('ExportTab: FutureBuilder state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, hasError: ${snapshot.hasError}');
        if (_isLoading || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('ExportTab: FutureBuilder error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load history.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      HistoryStorage.getHistory().whenComplete(() {
                        if (mounted) setState(() => _isLoading = false);
                      });
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('ExportTab: No history data available');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No calculations available to export.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  child: const Text('Go to Input Tab'),
                ),
              ],
            ),
          );
        }

        final history = snapshot.data!;
        final validHistory = history.where((entry) => entry['ipInfo'] is Map<String, dynamic>).toList();
        final latest = validHistory.isNotEmpty ? validHistory.last : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading || validHistory.isEmpty ? null : () async => await _exportToCsvFile(latest),
                    child: const Text('Export as CSV'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading || validHistory.isEmpty ? null : () async => await _exportToPdf(latest),
                    child: const Text('Export as PDF'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Calculation History:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Base IP')),
                    DataColumn(label: Text('Mode')),
                  ],
                  rows: validHistory.asMap().entries.map((entry) {
                    final item = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(Text(item['date']?.substring(0, 10) ?? 'N/A')),
                        DataCell(Text(item['baseIp'] ?? 'N/A')),
                        DataCell(Text(item['mode'] ?? 'N/A')),
                      ],
                      onSelectChanged: (selected) {
                        if (selected ?? false) {
                          _exportToCsvFile(item);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    print('ExportTab: Disposing');
    super.dispose();
  }
}