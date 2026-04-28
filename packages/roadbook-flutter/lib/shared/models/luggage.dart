// lib/shared/models/luggage.dart

class LuggageItem {
  const LuggageItem({required this.id, required this.text});
  final String id;
  final String text;

  factory LuggageItem.fromJson(Map<String, dynamic> json) =>
      LuggageItem(id: json['id'] as String, text: json['text'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'text': text};

  LuggageItem copyWith({String? text}) =>
      LuggageItem(id: id, text: text ?? this.text);

  @override
  bool operator ==(Object other) =>
      other is LuggageItem && other.id == id && other.text == text;

  @override
  int get hashCode => Object.hash(id, text);
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

  @override
  bool operator ==(Object other) =>
      other is LuggageCategory &&
      other.id == id &&
      other.name == name &&
      other.emoji == emoji &&
      _listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(id, name, emoji, Object.hashAll(items));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
