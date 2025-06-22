import 'package:flutter/material.dart';
import '../models/lan_model.dart';

class LanOutputTile extends StatelessWidget {
  final LanModel lan;
  final VoidCallback onVisualize;

  const LanOutputTile({super.key, required this.lan, required this.onVisualize});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LAN: ${lan.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Required Users: ${lan.requiredUsers}'),
            Text('CIDR: ${lan.cidr}'),
            Text('Subnet Mask: ${lan.subnetMask}'),
            Text('Network Address: ${lan.networkAddress}'),
            Text('Broadcast Address: ${lan.broadcastAddress}'),
            Text('Usable IPs: ${lan.usableIps}'),
            Text('IP Waste: ${lan.ipWaste}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onVisualize,
              child: const Text('Visualize Bitwise Operations'),
            ),
          ],
        ),
      ),
    );
  }
}