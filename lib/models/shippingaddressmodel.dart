class ShippingAddress {
  final String id;
  final String userId;
  final String address;
  final String city;
  final String province;
  final String postalCode;
  final String phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShippingAddress({
    required this.id,
    required this.userId,
    required this.address,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.phone,
    this.createdAt,
    this.updatedAt,
  });

  // Create from JSON (API response)
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      postalCode: json['postal_code'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Convert to JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'province': province,
      'postal_code': postalCode,
      'phone': phone,
    };
  }

  // Get formatted full address
  String get fullAddress {
    return '$address, $city, $province $postalCode';
  }

  // Get formatted phone with country code display
  String get formattedPhone {
    if (phone.startsWith('0')) {
      return '(+62)${phone.substring(1)}';
    } else if (phone.startsWith('62')) {
      return '(+62)${phone.substring(2)}';
    } else if (phone.startsWith('+62')) {
      return '(+62)${phone.substring(3)}';
    }
    return phone;
  }
}
