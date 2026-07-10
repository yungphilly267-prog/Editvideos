class ProductMetadata {
  final String title;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String? sourceUrl;

  ProductMetadata({
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrls,
    this.sourceUrl,
  });

  factory ProductMetadata.empty() {
    return ProductMetadata(
      title: '',
      description: '',
      price: 0.0,
      imageUrls: [],
    );
  }

  ProductMetadata copyWith({
    String? title,
    String? description,
    double? price,
    List<String>? imageUrls,
    String? sourceUrl,
  }) {
    return ProductMetadata(
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }
}
