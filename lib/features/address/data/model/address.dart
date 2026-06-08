import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String id;
  final String userId;
  final String? label;
  final String fullName;
  final String phone;
  final String city;
  final String? area;
  final String street;
  final String? building;
  final String? apartment;
  final String? notes;
  final bool isDefault;

  const Address({
    required this.id,
    required this.userId,
    this.label,
    required this.fullName,
    required this.phone,
    required this.city,
    this.area,
    required this.street,
    this.building,
    this.apartment,
    this.notes,
    this.isDefault = false,
  });

  String get displayLabel => (label != null && label!.isNotEmpty) ? label! : 'Address';

  String get fullAddress {
    final parts = <String>[
      street,
      if (building != null && building!.isNotEmpty) 'Bldg $building',
      if (apartment != null && apartment!.isNotEmpty) 'Apt $apartment',
      if (area != null && area!.isNotEmpty) area!,
      city,
    ];
    return parts.join(', ');
  }

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        label: j['label'] as String?,
        fullName: j['full_name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        city: j['city'] as String? ?? '',
        area: j['area'] as String?,
        street: j['street'] as String? ?? '',
        building: j['building'] as String?,
        apartment: j['apartment'] as String?,
        notes: j['notes'] as String?,
        isDefault: j['is_default'] as bool? ?? false,
      );

  Map<String, dynamic> toInsertJson(String userId) => {
        'user_id': userId,
        'label': label,
        'full_name': fullName,
        'phone': phone,
        'city': city,
        'area': area,
        'street': street,
        'building': building,
        'apartment': apartment,
        'notes': notes,
        'is_default': isDefault,
      };

  @override
  List<Object?> get props => [id, isDefault, fullName, phone, city, street];
}
