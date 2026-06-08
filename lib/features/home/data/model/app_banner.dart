import 'package:equatable/equatable.dart';

enum BannerLinkType { none, collection, product }

class AppBanner extends Equatable {
  final String id;
  final String? title;
  final String imageUrl;
  final BannerLinkType linkType;
  final String? linkId;
  final int sortOrder;

  const AppBanner({
    required this.id,
    this.title,
    required this.imageUrl,
    this.linkType = BannerLinkType.none,
    this.linkId,
    this.sortOrder = 0,
  });

  factory AppBanner.fromJson(Map<String, dynamic> j) => AppBanner(
        id: j['id'] as String,
        title: j['title'] as String?,
        imageUrl: j['image_url'] as String? ?? '',
        linkType: switch (j['link_type'] as String?) {
          'collection' => BannerLinkType.collection,
          'product' => BannerLinkType.product,
          _ => BannerLinkType.none,
        },
        linkId: j['link_id'] as String?,
        sortOrder: j['sort_order'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [id, imageUrl, linkType, linkId];
}
