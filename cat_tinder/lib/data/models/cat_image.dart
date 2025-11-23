class CatImage {
  final String id;
  final String url;
  final int width;
  final int height;
  final List<String>? breeds;

  CatImage({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
    this.breeds,
  });

  factory CatImage.fromJson(Map<String, dynamic> json) {
    return CatImage(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      breeds: json['breeds'] != null
          ? List<String>.from(json['breeds'].map((x) => x['id']))
          : null,
    );
  }
}
