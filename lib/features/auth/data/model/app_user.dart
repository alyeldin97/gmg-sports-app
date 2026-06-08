import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final bool isAdmin;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.isAdmin = false,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String? ?? '',
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String?,
        isAdmin: json['is_admin'] as bool? ?? false,
      );

  AppUser copyWith({String? name, String? phone}) => AppUser(
        id: id,
        email: email,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        isAdmin: isAdmin,
      );

  @override
  List<Object?> get props => [id, email, name, phone, isAdmin];
}
