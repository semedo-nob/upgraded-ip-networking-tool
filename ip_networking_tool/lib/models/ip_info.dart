import 'lan_model.dart';

class IpInfo {
  final String baseIp;
  final String cidr;
  final String subnetMask;
  final List<LanModel> lans;

  IpInfo({
    required this.baseIp,
    required this.cidr,
    required this.subnetMask,
    required this.lans,
  });

  Map<String, dynamic> toJson() => {
    'baseIp': baseIp,
    'cidr': cidr,
    'subnetMask': subnetMask,
    'lans': lans.map((lan) => lan.toJson()).toList(),
  };

  factory IpInfo.fromJson(Map<String, dynamic> json) => IpInfo(
    baseIp: json['baseIp'] ?? '0.0.0.0',
    cidr: json['cidr'] ?? '/0',
    subnetMask: json['subnetMask'] ?? '0.0.0.0',
    lans: (json['lans'] as List<dynamic>?)
        ?.map((item) => LanModel.fromJson(item as Map<String, dynamic>))
        .toList() ??
        [],
  );
}