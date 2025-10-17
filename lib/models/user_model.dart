class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role; // 'passenger' or 'driver'
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final bool isActive;

  // Driver specific fields
  final String? licenseNumber;
  final String? vehicleModel;
  final String? vehicleNumber;
  final String? vehicleColor;
  final int? vehicleCapacity;
  final bool? isAvailable;

  // Passenger specific fields
  final double? rating;
  final int? totalRides;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.isActive = true,
    this.licenseNumber,
    this.vehicleModel,
    this.vehicleNumber,
    this.vehicleColor,
    this.vehicleCapacity,
    this.isAvailable,
    this.rating,
    this.totalRides,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'passenger',
      profileImageUrl: map['profileImageUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      licenseNumber: map['licenseNumber'],
      vehicleModel: map['vehicleModel'],
      vehicleNumber: map['vehicleNumber'],
      vehicleColor: map['vehicleColor'],
      vehicleCapacity: map['vehicleCapacity'],
      isAvailable: map['isAvailable'],
      rating: map['rating']?.toDouble(),
      totalRides: map['totalRides'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isVerified': isVerified,
      'isActive': isActive,
      'licenseNumber': licenseNumber,
      'vehicleModel': vehicleModel,
      'vehicleNumber': vehicleNumber,
      'vehicleColor': vehicleColor,
      'vehicleCapacity': vehicleCapacity,
      'isAvailable': isAvailable,
      'rating': rating,
      'totalRides': totalRides,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    bool? isActive,
    String? licenseNumber,
    String? vehicleModel,
    String? vehicleNumber,
    String? vehicleColor,
    int? vehicleCapacity,
    bool? isAvailable,
    double? rating,
    int? totalRides,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehicleCapacity: vehicleCapacity ?? this.vehicleCapacity,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
    );
  }
}
