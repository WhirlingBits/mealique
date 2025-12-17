class ShoppingItem {
  final String id;
  final String name;
  final bool isChecked;

  ShoppingItem({
    required this.id,
    required this.name,
    this.isChecked = false,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id']?.toString() ?? '',
      name: (json['note'] ?? json['name'] ?? '') as String,
      isChecked: (json['checked'] ?? false) as bool,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'note': name,
      'checked': isChecked,
    };
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isChecked,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}