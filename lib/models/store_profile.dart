class StoreProfile {
  final String name;
  final String address;
  final String phone;
  final String cashierName;
  final String logoUrl;
  final bool isConfigured;

  StoreProfile({
    required this.name,
    required this.address,
    required this.phone,
    required this.cashierName,
    this.logoUrl = '',
    this.isConfigured = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'cashierName': cashierName,
      'logoUrl': logoUrl,
      'isConfigured': isConfigured,
    };
  }

  factory StoreProfile.fromJson(Map<String, dynamic> json) {
    return StoreProfile(
      name: json['name'] ?? 'Kasirku Store',
      address: json['address'] ?? 'Jl. Merdeka No. 45, Jakarta',
      phone: json['phone'] ?? '0812-3456-7890',
      cashierName: json['cashierName'] ?? 'Kasir Utama',
      logoUrl: json['logoUrl'] ?? '',
      isConfigured: json['isConfigured'] ?? false,
    );
  }

  StoreProfile copyWith({
    String? name,
    String? address,
    String? phone,
    String? cashierName,
    String? logoUrl,
    bool? isConfigured,
  }) {
    return StoreProfile(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      cashierName: cashierName ?? this.cashierName,
      logoUrl: logoUrl ?? this.logoUrl,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }
}
