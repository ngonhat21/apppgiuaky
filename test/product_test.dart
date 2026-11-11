import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:apppgiuaky/product.dart';
import 'package:apppgiuaky/main.dart';

void main() {
  test('File CSDL nhập được, chỉ có đúng bốn trường và ảnh PNG thật', () {
    final data =
        jsonDecode(
              File('database/products.json').readAsStringSync(),
            )['products']
            as Map;
    expect(data, isNotEmpty);
    for (final entry in data.entries) {
      final product = Product.fromJson(
        entry.key,
        Map<String, dynamic>.from(entry.value),
      );
      expect(product.toJson().keys.toSet(), {
        'name',
        'price',
        'soluong',
        'image',
      });
      expect(base64Decode(product.image.split(',').last).take(8), [
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
      ]);
      expect(
        Product.fromJson(product.id, product.toJson()).soluong,
        product.soluong,
      );
    }
  });
  test('Không nhận trường dư, giá âm, số lượng thập phân', () {
    final valid = {
      'name': 'Sản phẩm',
      'price': 10,
      'soluong': 2,
      'image': 'https://example.com/a.png',
    };
    for (final invalid in [
      {...valid, 'id': 'x'},
      {...valid, 'price': -1},
      {...valid, 'soluong': 2.5},
      {...valid, 'name': '  '},
    ]) {
      expect(() => Product.fromJson('x', invalid), throwsFormatException);
    }
  });
  testWidgets(
    'Không cấu hình Firebase: hiện hướng dẫn thay vì khởi tạo CRUD giả',
    (tester) async {
      await tester.pumpWidget(const AdminApp());
      expect(find.text('Kết nối kho hàng'), findsOneWidget);
      expect(find.textContaining('Firebase Authentication'), findsOneWidget);
    },
  );
}
