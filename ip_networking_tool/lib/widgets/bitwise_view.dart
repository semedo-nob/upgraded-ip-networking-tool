import 'package:flutter/material.dart';

class BitwiseView extends StatelessWidget {
  final String lanName;
  final String ipAddress;
  final String subnetMask;
  final String networkAddress;
  final String broadcastAddress;

  const BitwiseView({
    super.key,
    required this.lanName,
    required this.ipAddress,
    required this.subnetMask,
    required this.networkAddress,
    required this.broadcastAddress,
  });

  String _toBinary(String ip) {
    return ip.split('.').map((octet) => int.parse(octet).toRadixString(2).padLeft(8, '0')).join('.');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bitwise Visualization: $lanName'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IP Address: $ipAddress'),
            Text('Binary: ${_toBinary(ipAddress)}'),
            const SizedBox(height: 8),
            Text('Subnet Mask: $subnetMask'),
            Text('Binary: ${_toBinary(subnetMask)}'),
            const Divider(),
            Text('AND Result (Network): $networkAddress'),
            Text('Binary: ${_toBinary(networkAddress)}'),
            const SizedBox(height: 8),
            Text('OR Result (Broadcast): $broadcastAddress'),
            Text('Binary: ${_toBinary(broadcastAddress)}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}