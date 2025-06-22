import 'dart:math';

class IPv4Network {
  final String networkAddress;
  final String netmask;
  final int prefixlen;
  final String broadcastAddress;
  final List<String> hosts;

  IPv4Network(this.networkAddress, this.netmask, this.prefixlen, this.broadcastAddress, this.hosts);

  List<IPv4Network> subnets({required int newPrefix}) {
    if (newPrefix < prefixlen || newPrefix > 30) {
      throw Exception('Invalid new prefix for subnetting.');
    }

    final subnetCount = pow(2, newPrefix - prefixlen).toInt();
    final hostCount = pow(2, 32 - newPrefix).toInt();
    final networkInt = _ipToInt(networkAddress);
    final subnets = <IPv4Network>[];

    for (int i = 0; i < subnetCount; i++) {
      final subnetNetworkInt = networkInt + i * hostCount;
      final subnetNetwork = _intToIp(subnetNetworkInt);
      final subnetBroadcast = _intToIp(subnetNetworkInt + hostCount - 1);
      final subnetMask = _cidrToNetmask(newPrefix);
      final hosts = _calculateHosts(subnetNetwork, subnetBroadcast, newPrefix);

      subnets.add(IPv4Network(
          subnetNetwork,
          subnetMask,
          newPrefix,
          subnetBroadcast,
          hosts
      ));
    }

    return subnets;
  }

  // Helper function to convert IP string to integer
  int _ipToInt(String ip) {
    final octets = ip.split('.').map(int.parse).toList();
    return (octets[0] << 24) | (octets[1] << 16) | (octets[2] << 8) | octets[3];
  }

  // Helper function to convert integer to IP string
  String _intToIp(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF
    ].join('.');
  }
}

Map<String, dynamic> parseInput(String ipInput) {
  try {
    String ip;
    int cidr;
    String netmask;

    if (ipInput.contains('/')) {
      final parts = ipInput.split('/');
      ip = parts[0].trim();
      cidr = int.parse(parts[1].trim());
      netmask = _cidrToNetmask(cidr);
    } else if (ipInput.contains(',')) {
      final parts = ipInput.split(',').map((s) => s.trim()).toList();
      ip = parts[0];
      netmask = parts[1];
      cidr = _netmaskToCidr(netmask);
    } else {
      ip = ipInput.trim();
      cidr = 24; // Default CIDR
      netmask = _cidrToNetmask(cidr);
    }

    if (!_isValidIp(ip)) {
      throw Exception('Invalid IP address.');
    }
    if (!_isValidNetmask(netmask) || cidr < 0 || cidr > 32) {
      throw Exception('Invalid netmask or CIDR.');
    }

    final networkAddress = _calculateNetworkAddress(ip, netmask);
    final broadcastAddress = _calculateBroadcastAddress(networkAddress, cidr);
    final hosts = _calculateHosts(networkAddress, broadcastAddress, cidr);

    return {
      'network': IPv4Network(networkAddress, netmask, cidr, broadcastAddress, hosts),
      'network_address': networkAddress,
      'netmask': netmask,
      'prefixlen': cidr,
    };
  } catch (e) {
    throw Exception('Invalid input: $e');
  }
}

bool _isValidIp(String ip) {
  final octets = ip.split('.');
  if (octets.length != 4) return false;
  return octets.every((octet) {
    try {
      final value = int.parse(octet);
      return value >= 0 && value <= 255;
    } catch (_) {
      return false;
    }
  });
}

bool _isValidNetmask(String netmask) {
  try {
    final octets = netmask.split('.').map(int.parse).toList();
    if (octets.length != 4) return false;
    final binary = octets.map((o) => o.toRadixString(2).padLeft(8, '0')).join();
    return !binary.contains('01');
  } catch (_) {
    return false;
  }
}

String _cidrToNetmask(int cidr) {
  if (cidr < 0 || cidr > 32) throw Exception('Invalid CIDR.');
  final mask = (0xFFFFFFFF << (32 - cidr)) & 0xFFFFFFFF;
  return [
    (mask >> 24) & 0xFF,
    (mask >> 16) & 0xFF,
    (mask >> 8) & 0xFF,
    mask & 0xFF,
  ].join('.');
}

int _netmaskToCidr(String netmask) {
  if (!_isValidNetmask(netmask)) throw Exception('Invalid netmask.');
  final binary = netmask.split('.')
      .map((o) => int.parse(o).toRadixString(2).padLeft(8, '0'))
      .join('');
  return binary.split('').takeWhile((bit) => bit == '1').length;
}

String _calculateNetworkAddress(String ip, String netmask) {
  final ipInt = _ipToInt(ip);
  final maskInt = _ipToInt(netmask);
  final networkInt = ipInt & maskInt;
  return _intToIp(networkInt);
}

String _calculateBroadcastAddress(String networkAddress, int cidr) {
  final networkInt = _ipToInt(networkAddress);
  final hostBits = 32 - cidr;
  final broadcastInt = networkInt | ((1 << hostBits) - 1);
  return _intToIp(broadcastInt);
}

List<String> _calculateHosts(String networkAddress, String broadcastAddress, int cidr) {
  if (cidr >= 31) return []; // No usable IPs for /31 or /32
  final networkInt = _ipToInt(networkAddress);
  final broadcastInt = _ipToInt(broadcastAddress);
  final firstHost = _intToIp(networkInt + 1);
  final lastHost = _intToIp(broadcastInt - 1);
  return [firstHost, lastHost];
}

int _ipToInt(String ip) {
  final octets = ip.split('.').map(int.parse).toList();
  return (octets[0] << 24) | (octets[1] << 16) | (octets[2] << 8) | octets[3];
}

String _intToIp(int value) {
  return [
    (value >> 24) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 8) & 0xFF,
    value & 0xFF
  ].join('.');
}

String ipToBinary(String ip) {
  if (!_isValidIp(ip)) throw Exception('Invalid IP address.');
  return ip.split('.').map((octet) {
    return int.parse(octet).toRadixString(2).padLeft(8, '0');
  }).join('');
}

String binaryToIp(String binary) {
  if (binary.length != 32) throw Exception('Invalid binary length.');
  return [
    binary.substring(0, 8),
    binary.substring(8, 16),
    binary.substring(16, 24),
    binary.substring(24, 32)
  ].map((bin) => int.parse(bin, radix: 2).toString()).join('.');
}

Map<String, String> bitwiseOperation(String ip, String mask, String operation) {
  if (!_isValidIp(ip) || !_isValidNetmask(mask)) {
    throw Exception('Invalid IP or mask.');
  }

  final ipBin = ipToBinary(ip);
  final maskBin = ipToBinary(mask);
  String resultBin = '';

  if (operation == 'AND') {
    resultBin = List.generate(32, (i) =>
    (ipBin[i] == '1' && maskBin[i] == '1') ? '1' : '0').join();
  } else if (operation == 'OR') {
    resultBin = List.generate(32, (i) =>
    (ipBin[i] == '1' || maskBin[i] == '1') ? '1' : '0').join();
  } else {
    throw Exception('Invalid operation. Choose AND or OR.');
  }

  return {
    'binary': resultBin,
    'ip': binaryToIp(resultBin),
  };
}

List<Map<String, dynamic>> calculateLans(IPv4Network network, int? numLans) {
  try {
    if (numLans != null) {
      final newPrefix = network.prefixlen + (log(numLans) / log(2)).ceil();
      if (newPrefix > 30) {
        throw Exception('Too many LANs for given network size.');
      }
      final subnets = network.subnets(newPrefix: newPrefix);
      return subnets.map((subnet) {
        return {
          'network_address': subnet.networkAddress,
          'broadcast_address': subnet.broadcastAddress,
          'usable_ips': subnet.hosts.isNotEmpty ?
          '${subnet.hosts.first} - ${subnet.hosts.last}' : 'None',
          'prefixlen': subnet.prefixlen,
          'netmask': subnet.netmask,
        };
      }).toList();
    } else {
      final maxSubnets = pow(2, 30 - network.prefixlen).toInt();
      final subnets = network.subnets(newPrefix: 30).take(maxSubnets).toList();
      return subnets.map((subnet) {
        return {
          'network_address': subnet.networkAddress,
          'broadcast_address': subnet.broadcastAddress,
          'usable_ips': subnet.hosts.isNotEmpty ?
          '${subnet.hosts.first} - ${subnet.hosts.last}' : 'None',
          'prefixlen': subnet.prefixlen,
          'netmask': subnet.netmask,
        };
      }).toList();
    }
  } catch (e) {
    throw Exception('Error calculating subnets: $e');
  }
}