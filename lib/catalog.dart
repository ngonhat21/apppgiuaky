import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'product.dart';

const shopOrange = Color(0xffee4d2d);
const shopInk = Color(0xff202532);

ThemeData shopTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: shopOrange,
    primary: shopOrange,
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xfff6f7f9),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: Color(0xffeceef2)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xfff8f9fb),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xffe6e8ed)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xffe6e8ed)),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: const BorderSide(color: Color(0xffe6e8ed)),
    ),
  ),
);

class ProductCatalog extends StatefulWidget {
  final List<Product> products;
  final VoidCallback onAdd, onLogout;
  final ValueChanged<Product> onEdit, onDelete;
  final Widget Function(String) imageBuilder;
  const ProductCatalog({
    super.key,
    required this.products,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onLogout,
    required this.imageBuilder,
  });
  @override
  State<ProductCatalog> createState() => _ProductCatalogState();
}

class _ProductCatalogState extends State<ProductCatalog> {
  String query = '', sort = 'name';
  int filter = 0;
  final money = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.products;
    final products = all
        .where(
          (p) =>
              p.name.toLowerCase().contains(query.trim().toLowerCase()) &&
              (filter == 0 ||
                  (filter == 1
                      ? p.soluong > 5
                      : filter == 2
                      ? p.soluong > 0 && p.soluong <= 5
                      : p.soluong == 0)),
        )
        .toList();
    products.sort(
      (a, b) => sort == 'price'
          ? a.price.compareTo(b.price)
          : sort == 'quantity'
          ? a.soluong.compareTo(b.soluong)
          : a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    final desktop = MediaQuery.sizeOf(context).width >= 1100;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: shopOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'S-Market',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                letterSpacing: -.8,
              ),
            ),
            if (MediaQuery.sizeOf(context).width > 650) ...[
              const SizedBox(width: 16),
              const Text(
                'KÊNH NGƯỜI BÁN',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.6,
                  color: Color(0xff8d93a1),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (desktop)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Chip(
                avatar: Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: Color(0xff29966b),
                ),
                label: Text('Quản trị cửa hàng'),
                side: BorderSide.none,
                backgroundColor: Color(0xfff0f8f4),
              ),
            ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded, size: 21),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (desktop) sidebar(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final padding = c.maxWidth < 600 ? 18.0 : 32.0;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Cửa hàng  /  Quản lý sản phẩm',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff949aa6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 20,
                        runSpacing: 14,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: c.maxWidth > 650
                                ? c.maxWidth - padding * 2 - 220
                                : c.maxWidth - padding * 2,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gian hàng của bạn',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: shopInk,
                                    letterSpacing: -.8,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Mọi sản phẩm, một nơi quản lý.',
                                  style: TextStyle(
                                    color: Color(0xff838a97),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: widget.onAdd,
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text('Thêm sản phẩm'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xffee4d2d), Color(0xffff8555)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'GỌN KHO HÀNG · SẴN SÀNG BÁN',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      letterSpacing: 1.7,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Chăm chút từng sản phẩm',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Ảnh đẹp, thông tin rõ ràng — gian hàng chuyên nghiệp hơn.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      height: 1.6,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (c.maxWidth > 600)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Icon(
                                  Icons.storefront_rounded,
                                  size: 90,
                                  color: Color(0x66ffffff),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      LayoutBuilder(
                        builder: (context, s) {
                          final width = s.maxWidth >= 700
                              ? (s.maxWidth - 32) / 3
                              : s.maxWidth;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              metric(
                                width,
                                'Tổng sản phẩm',
                                '${all.length}',
                                'Mặt hàng trong gian hàng',
                                Icons.inventory_2_outlined,
                                shopOrange,
                              ),
                              metric(
                                width,
                                'Sản phẩm tồn kho',
                                '${all.fold<int>(0, (s, p) => s + p.soluong)}',
                                'Tổng số lượng hiện có',
                                Icons.layers_outlined,
                                const Color(0xff5b76d6),
                              ),
                              metric(
                                width,
                                'Giá trị kho hàng',
                                money.format(
                                  all.fold<double>(
                                    0,
                                    (s, p) => s + p.price * p.soluong,
                                  ),
                                ),
                                'Giá × số lượng tồn kho',
                                Icons.account_balance_wallet_outlined,
                                const Color(0xff29966b),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 20,
                                runSpacing: 12,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Danh sách sản phẩm',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: shopInk,
                                    ),
                                  ),
                                  Text(
                                    '${all.length} sản phẩm',
                                    style: const TextStyle(
                                      color: Color(0xff949aa6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  tab('Tất cả', 0, all.length),
                                  tab(
                                    'Còn hàng',
                                    1,
                                    all.where((p) => p.soluong > 5).length,
                                  ),
                                  tab(
                                    'Sắp hết',
                                    2,
                                    all
                                        .where(
                                          (p) =>
                                              p.soluong > 0 && p.soluong <= 5,
                                        )
                                        .length,
                                  ),
                                  tab(
                                    'Hết hàng',
                                    3,
                                    all.where((p) => p.soluong == 0).length,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              LayoutBuilder(
                                builder: (context, f) => Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: f.maxWidth < 400
                                          ? f.maxWidth
                                          : 300,
                                      child: TextField(
                                        controller: search,
                                        onChanged: (v) =>
                                            setState(() => query = v),
                                        decoration: InputDecoration(
                                          hintText: 'Tìm tên sản phẩm…',
                                          hintStyle: const TextStyle(
                                            fontSize: 13,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.search_rounded,
                                            size: 21,
                                          ),
                                          suffixIcon: query.isEmpty
                                              ? null
                                              : IconButton(
                                                  tooltip: 'Xóa tìm kiếm',
                                                  onPressed: () {
                                                    search.clear();
                                                    setState(() => query = '');
                                                  },
                                                  icon: const Icon(
                                                    Icons.close,
                                                    size: 18,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xffe6e8ed),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: sort,
                                          style: const TextStyle(
                                            color: shopInk,
                                            fontSize: 13,
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'name',
                                              child: Text('Tên: A - Z'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'price',
                                              child: Text('Giá: thấp đến cao'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'quantity',
                                              child: Text('Tồn kho: tăng dần'),
                                            ),
                                          ],
                                          onChanged: (v) =>
                                              setState(() => sort = v!),
                                        ),
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(
                                            text:
                                                const JsonEncoder.withIndent(
                                                  '  ',
                                                ).convert({
                                                  'products': {
                                                    for (final p in all)
                                                      p.id: p.toJson(),
                                                  },
                                                }),
                                          ),
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Đã sao chép JSON. Dán vào file products.json để lưu.',
                                                  ),
                                                ),
                                              );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.file_download_outlined,
                                        size: 18,
                                      ),
                                      label: const Text('Sao chép JSON'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Hiển thị ${products.length} sản phẩm',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff838a97),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (products.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: Color(0xffc7cbd3),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Không tìm thấy sản phẩm',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Thử tìm tên khác hoặc thay đổi bộ lọc.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  search.clear();
                                  setState(() {
                                    query = '';
                                    filter = 0;
                                  });
                                },
                                child: const Text('Xem tất cả sản phẩm'),
                              ),
                            ],
                          ),
                        ),
                      LayoutBuilder(
                        builder: (context, g) {
                          final cols = g.maxWidth >= 1040
                              ? 4
                              : g.maxWidth >= 740
                              ? 3
                              : g.maxWidth >= 480
                              ? 2
                              : 1;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  mainAxisExtent: 360,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 18,
                                ),
                            itemBuilder: (_, i) => productCard(products[i]),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      const Center(
                        child: Text(
                          'S-Market Seller Center · Quản lý gian hàng mỗi ngày',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xffa2a7b1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget sidebar() => Container(
    width: 218,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: Color(0xffeceef2))),
    ),
    padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12, bottom: 18),
          child: Text(
            'QUẢN LÝ CỬA HÀNG',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              color: Color(0xffa2a7b1),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Material(
          color: Colors.transparent,
          child: ListTile(
            selected: true,
            selectedTileColor: Color(0xffffeee8),
            selectedColor: shopOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            leading: Icon(Icons.widgets_outlined, size: 22),
            title: Text(
              'Sản phẩm',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xfffaf7f4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: shopOrange),
              SizedBox(height: 10),
              Text(
                'Mẹo cho gian hàng',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              SizedBox(height: 8),
              Text(
                'Thêm ảnh thật và cập nhật số lượng để sản phẩm luôn sẵn sàng.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.7,
                  color: Color(0xff92929a),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget tab(String text, int value, int count) => ChoiceChip(
    label: Text(
      '$text  $count',
      style: TextStyle(
        fontSize: 12,
        fontWeight: filter == value ? FontWeight.w700 : FontWeight.w400,
      ),
    ),
    selected: filter == value,
    onSelected: (_) => setState(() => filter = value),
    showCheckmark: false,
    selectedColor: const Color(0xffffeee8),
    backgroundColor: Colors.white,
    side: BorderSide(
      color: filter == value
          ? const Color(0xffffc8b8)
          : const Color(0xffeceef2),
    ),
    labelStyle: TextStyle(
      color: filter == value ? shopOrange : const Color(0xff727987),
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
  );
  Widget metric(
    double width,
    String label,
    String value,
    String detail,
    IconData icon,
    Color color,
  ) => SizedBox(
    width: width,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xff838a97),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: shopInk,
                      letterSpacing: -.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xffa2a7b1),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 25),
            ),
          ],
        ),
      ),
    ),
  );
  Widget productCard(Product p) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: const Color(0xfff4f5f7),
                child: widget.imageBuilder(p.image),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: p.soluong == 0
                        ? const Color(0xfff2f3f5)
                        : p.soluong <= 5
                        ? const Color(0xfffff0e5)
                        : const Color(0xffeaf8f1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p.soluong == 0
                        ? 'Hết hàng'
                        : p.soluong <= 5
                        ? 'Sắp hết hàng'
                        : 'Còn hàng',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: p.soluong == 0
                          ? Colors.grey
                          : p.soluong <= 5
                          ? const Color(0xffd78024)
                          : const Color(0xff29966b),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: shopInk,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                money.format(p.price),
                style: const TextStyle(
                  color: shopOrange,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 13,
                    color: Color(0xff949aa6),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Tồn kho: ${p.soluong}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xff838a97),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xfff0f1f4)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => widget.onEdit(p),
                      icon: const Icon(Icons.edit_outlined, size: 15),
                      label: const Text(
                        'Chỉnh sửa',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Xóa ${p.name}',
                    onPressed: () => widget.onDelete(p),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 19,
                      color: Color(0xffa1a6af),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class LoginBackdrop extends StatelessWidget {
  final Widget child;
  const LoginBackdrop({super.key, required this.child});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => Row(
      children: [
        if (c.maxWidth >= 950)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffee4d2d), Color(0xffff9363)],
                ),
              ),
              padding: const EdgeInsets.all(64),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 56,
                    color: Colors.white,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'S-Market',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Gian hàng nhỏ.\nKhởi đầu lớn.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Quản lý sản phẩm, chăm chút hình ảnh\nvà luôn sẵn sàng cho ngày bán hàng mới.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.8,
                    ),
                  ),
                  SizedBox(height: 48),
                  Icon(
                    Icons.storefront_rounded,
                    size: 130,
                    color: Color(0x88ffffff),
                  ),
                ],
              ),
            ),
          ),
        Expanded(child: child),
      ],
    ),
  );
}
