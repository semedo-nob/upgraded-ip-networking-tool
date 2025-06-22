import 'package:flutter/material.dart';
import '../logic/subnet_calculator.dart';
import '../utils/history_storage.dart';
import '../models/ip_info.dart';
import '../models/lan_model.dart';
import '../widgets/lan_input_tile.dart';

class InputTab extends StatefulWidget {
  final VoidCallback onCalculationComplete;

  const InputTab({super.key, required this.onCalculationComplete});

  @override
  State<InputTab> createState() => _InputTabState();
}

class _InputTabState extends State<InputTab> {
  final _ipController = TextEditingController();
  final _numLansController = TextEditingController();
  String _mode = 'Manual';
  bool _isCalculating = false;
  String? _errorMessage;
  final List<Map<String, dynamic>> _lans = [];

  @override
  void dispose() {
    _ipController.dispose();
    _numLansController.dispose();
    for (var lan in _lans) {
      lan['nameController'].dispose();
      lan['usersController'].dispose();
    }
    super.dispose();
  }

  void _addLan() {
    setState(() {
      _lans.add({
        'nameController': TextEditingController(),
        'usersController': TextEditingController(),
      });
    });
  }

  void _resetLans() {
    setState(() {
      for (var lan in _lans) {
        lan['nameController'].dispose();
        lan['usersController'].dispose();
      }
      _lans.clear();
    });
  }

  Future<void> _processInput() async {
    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    try {
      final ipInput = _ipController.text.trim();
      if (ipInput.isEmpty) {
        throw Exception('Please enter an IP address.');
      }

      final networkInfo = await SubnetCalculator.parseInputAsync(ipInput);
      final network = networkInfo['network'] as IPv4Network;
      final subnetMask = networkInfo['netmask'] as String;
      final cidr = '/${network.prefixlen}';

      List<Map<String, dynamic>> lans = [];
      if (_mode == 'Manual') {
        if (_lans.isEmpty) {
          throw Exception('Add at least one LAN in Manual mode.');
        }
        for (var lan in _lans) {
          final name = lan['nameController'].text.trim();
          final usersText = lan['usersController'].text.trim();
          if (name.isEmpty || usersText.isEmpty) {
            throw Exception('LAN name and user count are required.');
          }
          final users = int.tryParse(usersText);
          if (users == null || users <= 0 || users > 1000) {
            throw Exception('Invalid user count for $name: $usersText (1-1000 allowed).');
          }
          lans.add({'name': name, 'users': users});
        }
      } else if (_mode == 'Automatic') {
        final numLansText = _numLansController.text.trim();
        if (numLansText.isEmpty) {
          throw Exception('Enter the number of LANs in Automatic mode.');
        }
        final numLans = int.tryParse(numLansText);
        if (numLans == null || numLans <= 0 || numLans > 100) {
          throw Exception('Invalid number of LANs: $numLansText (1-100 allowed).');
        }
        for (int i = 1; i <= numLans; i++) {
          lans.add({'name': 'LAN $i', 'users': 2});
        }
      } else {
        throw Exception('Select a mode (Manual or Automatic).');
      }

      print('Processing input: $ipInput, mode: $_mode, lans: ${lans.length}');

      final subnets = SubnetCalculator.calculateVlsm(network, lans);
      if (subnets.length > 1000) {
        throw Exception('Too many subnets generated (${subnets.length}). Limit to 1000.');
      }

      final ipInfo = IpInfo(
        baseIp: network.networkAddress,
        cidr: cidr,
        subnetMask: subnetMask,
        lans: subnets.map((s) => LanModel.fromJson(s)).toList(),
      );

      final entry = {
        'date': DateTime.now().toIso8601String(),
        'baseIp': ipInfo.baseIp,
        'mode': _mode,
        'ipInfo': ipInfo.toJson(),
      };
      print('Saving history entry: ${entry['baseIp']}');
      await HistoryStorage.saveHistory(entry);
      print('History entry saved successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calculation successful!')),
      );

      widget.onCalculationComplete();
    } catch (e, stackTrace) {
      print('Error in _processInput: $e\n$stackTrace');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text('Manual'),
                    value: 'Manual',
                    groupValue: _mode,
                    onChanged: (value) => setState(() => _mode = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text('Automatic'),
                    value: 'Automatic',
                    groupValue: _mode,
                    onChanged: (value) => setState(() => _mode = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP Address (e.g., 192.168.1.0/24 or 192.168.1.0,255.255.255.0)',
                border: OutlineInputBorder(),
                hintText: 'Enter IP alone for default /24',
              ),
            ),
            const SizedBox(height: 16),
            if (_mode == 'Manual') ...[
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _addLan,
                    child: const Text('Add LAN'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _resetLans,
                    child: const Text('Reset LANs'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._lans.asMap().entries.map((entry) {
                final index = entry.key;
                final lan = entry.value;
                return LanInputTile(
                  nameController: lan['nameController'],
                  usersController: lan['usersController'],
                  onRemove: () {
                    setState(() {
                      lan['nameController'].dispose();
                      lan['usersController'].dispose();
                      _lans.removeAt(index);
                    });
                  },
                );
              }),
            ],
            if (_mode == 'Automatic') ...[
              TextField(
                controller: _numLansController,
                decoration: const InputDecoration(
                  labelText: 'Number of LANs (1-100)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
            ],
            Center(
              child: ElevatedButton(
                onPressed: _isCalculating ? null : _processInput,
                child: _isCalculating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Calculate Subnets'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}