// test/shared/models/luggage_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/luggage.dart';

void main() {
  group('LuggageItem', () {
    test('fromJson / toJson round-trips', () {
      final json = {'id': 'abc', 'text': '护照'};
      final item = LuggageItem.fromJson(json);
      expect(item.id, 'abc');
      expect(item.text, '护照');
      expect(item.toJson(), json);
    });
  });

  group('LuggageCategory', () {
    test('fromJson parses name, emoji, and items', () {
      final json = {
        'id': 'cat1',
        'name': '证件',
        'emoji': '📋',
        'items': [
          {'id': 'i1', 'text': '护照'},
          {'id': 'i2', 'text': '签证'},
        ],
      };
      final cat = LuggageCategory.fromJson(json);
      expect(cat.name, '证件');
      expect(cat.emoji, '📋');
      expect(cat.items.length, 2);
      expect(cat.items.first.text, '护照');
    });

    test('fromJson defaults emoji to 📦 when missing', () {
      final json = {'id': 'cat2', 'name': '杂项', 'items': <dynamic>[]};
      final cat = LuggageCategory.fromJson(json);
      expect(cat.emoji, '📦');
    });

    test('toJson round-trips', () {
      final cat = LuggageCategory(
        id: 'c1',
        name: '证件',
        emoji: '📋',
        items: [const LuggageItem(id: 'i1', text: '护照')],
      );
      final json = cat.toJson();
      expect(json['name'], '证件');
      expect(json['emoji'], '📋');
      expect((json['items'] as List).length, 1);
    });

    test('copyWith replaces name and items independently', () {
      final cat =
          const LuggageCategory(id: 'c1', name: 'A', emoji: '📦', items: []);
      final withName = cat.copyWith(name: 'B');
      expect(withName.name, 'B');
      expect(withName.id, 'c1');
      expect(withName.emoji, '📦');
      expect(withName.items, isEmpty);
    });
  });
}
