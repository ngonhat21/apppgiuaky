import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apppgiuaky/catalog.dart';
import 'package:apppgiuaky/product.dart';

void main() {
  testWidgets(
    'Catalog fits desktop/mobile and filters derived stock without database fields',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1440, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var edits = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: shopTheme(),
          home: ProductCatalog(
            products: const [
              Product(
                id: 'a',
                name: 'Áo cotton',
                price: 150000,
                soluong: 20,
                image: '',
              ),
              Product(
                id: 'b',
                name: 'Túi canvas',
                price: 80000,
                soluong: 2,
                image: '',
              ),
              Product(
                id: 'c',
                name: 'Bình nước',
                price: 220000,
                soluong: 0,
                image: '',
              ),
            ],
            onAdd: () {},
            onEdit: (_) => edits++,
            onDelete: (_) {},
            onLogout: () {},
            imageBuilder: (_) => const ColoredBox(color: Colors.white),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Sắp hết  1'));
      await tester.pumpAndSettle();
      expect(find.text('Túi canvas'), findsOneWidget);
      expect(find.text('Áo cotton'), findsNothing);
      await tester.ensureVisible(find.text('Chỉnh sửa'));
      await tester.tap(find.text('Chỉnh sửa'));
      expect(edits, 1);
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField), 'không tồn tại');
      await tester.pumpAndSettle();
      expect(find.text('Không tìm thấy sản phẩm'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
