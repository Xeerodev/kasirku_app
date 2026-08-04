class StoreProfile {
  final String name;
  final String address;
  final String phone;
  final String cashierName;
  final String logoUrl;

  StoreProfile({
    required this.name,
    required this.address,
    required this.phone,
    required this.cashierName,
    this.logoUrl = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'cashierName': cashierName,
      'logoUrl': logoUrl,
    };
  }

  factory StoreProfile.fromJson(Map<String, dynamic> json) {
    return StoreProfile(
      name: json['name'] ?? 'Kasirku Store',
      address: json['address'] ?? 'Jl. Merdeka No. 45, Jakarta',
      phone: json['phone'] ?? '0812-3456-7890',
      cashierName: json['cashierName'] ?? 'Kasir Utama',
      logoUrl: json['logoUrl'] ?? '',
    );
  }
}
