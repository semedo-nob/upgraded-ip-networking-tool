class LanModel {
  final String name;
  final int requiredUsers;
  final String cidr;
  final String subnetMask;
  final String networkAddress;
  final String broadcastAddress;
  final String usableIps;
  final int ipWaste;

  LanModel({
    required this.name,
    required this.requiredUsers,
    required this.cidr,
    required this.subnetMask,
    required this.networkAddress,
    required this.broadcastAddress,
    required this.usableIps,
    required this.ipWaste,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'requiredUsers': requiredUsers,
    'cidr': cidr,
    'subnetMask': subnetMask,
    'networkAddress': networkAddress,
    'broadcastAddress': broadcastAddress,
    'usableIps': usableIps,
    'ipWaste': ipWaste,
  };

  factory LanModel.fromJson(Map<String, dynamic> json) => LanModel(
    name: json['name'] ?? 'Unknown',
    requiredUsers: json['requiredUsers'] ?? 0,
    cidr: json['cidr'] ?? '/0',
    subnetMask: json['subnetMask'] ?? '0.0.0.0',
    networkAddress: json['networkAddress'] ?? '0.0.0.0',
    broadcastAddress: json['broadcastAddress'] ?? '0.0.0.0',
    usableIps: json['usableIps'] ?? 'N/A',
    ipWaste: json['ipWaste'] ?? 0,
  );
}