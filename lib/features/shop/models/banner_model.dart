class BannerModel {
  String id;
  String name;
  String imageUrl;
  String status; // 'en_attente', 'publiee', 'refusee'
  String? link; // ID du produit, catégorie ou établissement
  String? linkType; // 'product', 'category', 'establishment'
  DateTime? createdAt;
  DateTime? updatedAt;

  BannerModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.status = 'en_attente',
    this.link,
    this.linkType,
    this.createdAt,
    this.updatedAt,
  });

  static BannerModel empty() {
    return BannerModel(
      id: '',
      imageUrl: '',
      name: '',
      status: 'en_attente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'status': status,
      'link': link,
      'link_type': linkType,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory BannerModel.fromJson(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return BannerModel.empty();
    }
    return BannerModel(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? '',
      imageUrl: data['image_url'] ?? '',
      status: data['status']?.toString() ?? 'en_attente',
      link: data['link']?.toString(),
      linkType: data['link_type']?.toString(),
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : null,
    );
  }

  factory BannerModel.fromMap(Map<String, dynamic> data) {
    return BannerModel.fromJson(data);
  }
}
