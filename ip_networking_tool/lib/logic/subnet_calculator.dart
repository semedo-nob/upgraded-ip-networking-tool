import 'dart:math';

class IPv4Network {
  final String networkAddress;
  final int prefixlen;

  IPv4Network({required this.networkAddress, required this.prefixlen});
}

class SubnetCalculator {
  static List<Map<String, dynamic>> calculateVlsm(IPv4Network network, List<Map<String, dynamic>> lans) {
    final sortedLans = List.from(lans)
      ..sort((a, b) => (b['users'] as int).compareTo(a['users'] as int));

    final List<Map<String, dynamic>> subnets = [];
    var currentIp = network.networkAddress.split('.').map(int.parse).toList();

    for (var lan in sortedLans) {
      final users = lan['users'] as int;
      final name = lan['name'] as String;
      final requiredHosts = users + 2; // +2 for network and broadcast
      final prefixLen = 32 - (log(requiredHosts) / log(2)).ceil();
      final subnetSize = pow(2, 32 - prefixLen).toInt();
      final ipWaste = subnetSize - requiredHosts;

      final networkAddr = currentIp.join('.');
      final subnetMask = cidrToMask('/$prefixLen');
      final broadcastAddr = _calculateBroadcast(networkAddr, subnetSize);
      // Correct usable IPs: exclude network and broadcast
      final usableIps = subnetSize > 2
          ? '${incrementIp(networkAddr, 1)} → ${incrementIp(networkAddr, subnetSize - 2)}'
          : ''; // Empty for /31 or /32

      subnets.add({
        'name': name,
        'requiredUsers': users,
        'cidr': '/$prefixLen',
        'subnetMask': subnetMask,
        'networkAddress': networkAddr,
        'broadcastAddress': broadcastAddr,
        'usableIps': usableIps,
        'ipWaste': ipWaste,
      });

      currentIp = incrementIpList(currentIp, subnetSize);
    }

    return subnets;
  }

  static String _calculateBroadcast(String networkAddr, int subnetSize) {
    final ipOctets = networkAddr.split('.').map(int.parse).toList();
    final broadcastIp = List<int>.from(ipOctets);
    int increment = subnetSize - 1; // Total IPs minus network address

    for (int i = 3; i >= 0; i--) {
      broadcastIp[i] += increment & 0xff;
      increment >>= 8;
      if (broadcastIp[i] > 255) {
        broadcastIp[i] -= 256;
        if (i > 0) broadcastIp[i - 1]++;
      }
    }

    return broadcastIp.join('.');
  }

  static String cidrToMask(String cidr) {
    final prefix = int.parse(cidr.replaceAll('/', ''));
    int mask = 0xffffffff << (32 - prefix);
    return [
      (mask >> 24) & 0xff,
      (mask >> 16) & 0xff,
      (mask >> 8) & 0xff,
      mask & 0xff,
    ].join('.');
  }

  static String incrementIp(String ip, int increment) {
    final octets = ip.split('.').map(int.parse).toList();
    final result = incrementIpList(octets, increment);
    return result.join('.');
  }

  static List<int> incrementIpList(List<int> ip, int increment) {
    final result = List<int>.from(ip);
    for (int i = 3; i >= 0; i--) {
      result[i] += increment & 0xff;
      increment >>= 8;
      if (result[i] > 255) {
        result[i] -= 256;
        if (i > 0) result[i - 1]++;
      }
    }
    return result;
  }

  static Future<Map<String, dynamic>> parseInputAsync(String input) async {
    try {
      String ip;
      int prefixlen;
      String netmask;

      if (input.contains('/')) {
        final parts = input.split('/');
        ip = parts[0];
        prefixlen = int.parse(parts[1]);
        netmask = cidrToMask('/$prefixlen');
      } else if (input.contains(',')) {
        final parts = input.split(',');
        ip = parts[0];
        netmask = parts[1];
        prefixlen = netmask
            .split('.')
            .map((octet) => int.parse(octet).toRadixString(2).padLeft(8, '0'))
            .join()
            .split('')
            .takeWhile((bit) => bit == '1')
            .length;
      } else {
        ip = input.trim();
        prefixlen = 24;
        netmask = cidrToMask('/24');
      }

      final octets = ip.split('.').map(int.tryParse).toList();
      if (octets.length != 4 || octets.any((o) => o == null || o < 0 || o > 255)) {
        throw Exception('Invalid IP address: $ip');
      }

      final ipInt = octets[0]! << 24 | octets[1]! << 16 | octets[2]! << 8 | octets[3]!;
      final maskInt = int.parse(netmask.split('.').map((o) => int.parse(o)).reduce((a, b) => (a << 8) | b).toString());
      final networkInt = ipInt & maskInt;
      final networkAddress = [
        (networkInt >> 24) & 0xff,
        (networkInt >> 16) & 0xff,
        (networkInt >> 8) & 0xff,
        networkInt & 0xff,
      ].join('.');

      return {
        'network': IPv4Network(networkAddress: networkAddress, prefixlen: prefixlen),
        'netmask': netmask,
      };
    } catch (e) {
      throw Exception('Invalid input format. Use IP/CIDR (e.g., 192.168.1.0/24) or IP,netmask (e.g., 192.168.1.0,255.255.255.0).');
    }
  }
}