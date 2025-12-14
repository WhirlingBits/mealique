class Recipe {
  final String id;
  final String name;
  final String slug;
  final String? image;
  final String? description;
  final String? totalTime;
  final String? prepTime;
  final String? performTime;

  Recipe({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.description,
    this.totalTime,
    this.prepTime,
    this.performTime,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unbenannt',
      slug: json['slug'] ?? '',
      image: json['image'],
      description: json['description'],
      totalTime: json['totalTime'],
      prepTime: json['prepTime'],
      performTime: json['performTime'],
    );
  }
}