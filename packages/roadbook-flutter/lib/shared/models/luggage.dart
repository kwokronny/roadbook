// lib/shared/models/luggage.dart

class LuggageItem {
  const LuggageItem({required this.id, required this.text});
  final String id;
  final String text;

  factory LuggageItem.fromJson(Map<String, dynamic> json) =>
      LuggageItem(id: json['id'] as String, text: json['text'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}

class LuggageCategory {
  const LuggageCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.items,
  });
  final String id;
  final String name;
  final String emoji;
  final List<LuggageItem> items;

  factory LuggageCategory.fromJson(Map<String, dynamic> json) =>
      LuggageCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: (json['emoji'] as String?) ?? '📦',
        items: (json['items'] as List<dynamic>)
            .map((e) => LuggageItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'items': items.map((i) => i.toJson()).toList(),
      };

  LuggageCategory copyWith({String? name, List<LuggageItem>? items}) =>
      LuggageCategory(
        id: id,
        name: name ?? this.name,
        emoji: emoji,
        items: items ?? this.items,
      );
}
