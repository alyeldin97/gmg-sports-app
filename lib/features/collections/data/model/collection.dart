import 'package:equatable/equatable.dart';

class Collection extends Equatable {
  final String id;
  final String title;
  final String? titleAr;
  final String? description;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;

  const Collection({
    required this.id,
    required this.title,
    this.titleAr,
    this.description,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  String localizedTitle(bool isArabic) =>
      (isArabic && titleAr != null && titleAr!.isNotEmpty) ? titleAr! : title;

  factory Collection.fromJson(Map<String, dynamic> j) => Collection(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        titleAr: j['title_ar'] as String?,
        description: j['description'] as String?,
        imageUrl: j['image_url'] as String?,
        sortOrder: j['sort_order'] as int? ?? 0,
        isActive: j['is_active'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [id, title, sortOrder, isActive];
}
