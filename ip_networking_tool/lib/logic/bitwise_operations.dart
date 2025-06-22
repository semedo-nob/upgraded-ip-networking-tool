class BitwiseOperations {
  static Map<String, String> performBitwiseOperation(String ip, String mask, String operation) {
    final ipOctets = ip.split('.').map(int.parse).toList();
    final maskOctets = mask.split('.').map(int.parse).toList();
    final resultOctets = List<int>.filled(4, 0);

    for (int i = 0; i < 4; i++) {
      if (operation == 'AND') {
        resultOctets[i] = ipOctets[i] & maskOctets[i];
      } else if (operation == 'OR') {
        resultOctets[i] = ipOctets[i] | maskOctets[i];
      }
    }

    final binaryIp = ipOctets.map((o) => o.toRadixString(2).padLeft(8, '0')).join('.');
    final binaryMask = maskOctets.map((o) => o.toRadixString(2).padLeft(8, '0')).join('.');
    final binaryResult = resultOctets.map((o) => o.toRadixString(2).padLeft(8, '0')).join('.');

    return {
      'ip': ip,
      'binaryIp': binaryIp,
      'mask': mask,
      'binaryMask': binaryMask,
      'result': resultOctets.join('.'),
      'binaryResult': binaryResult,
      'operation': operation,
    };
  }
}