import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

import 'catalog.dart';

import 'product.dart';

const configured = bool.fromEnvironment('FIREBASE_ENABLED');
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? error;
  if (configured) {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
          appId: String.fromEnvironment('FIREBASE_APP_ID'),
          messagingSenderId: String.fromEnvironment('FIREBASE_SENDER_ID'),
          projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
          databaseURL: String.fromEnvironment('FIREBASE_DATABASE_URL'),
          authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
          iosBundleId: 'com.example.apppgiuaky',
        ),
      );
    } catch (e) {
      error = 'Không thể khởi tạo Firebase. Kiểm tra cấu hình: $e';
    }
  }
  runApp(AdminApp(startupError: error));
}

class AdminApp extends StatelessWidget {
  final String? startupError;
  const AdminApp({super.key, this.startupError});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'S-Market · Kênh người bán',
    theme: shopTheme(),
    home: startupError != null
        ? Scaffold(body: Center(child: Text(startupError!)))
        : !configured
        ? const SetupPage()
        : StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return snapshot.data == null
                  ? const LoginPage()
                  : const ProductsPage();
            },
          ),
  );
}

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: shopOrange),
              SizedBox(height: 24),
              Text(
                'Kết nối kho hàng',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Ứng dụng đã sẵn sàng. Hãy tạo Firebase Authentication và Realtime Database, cấu hình UID quản trị viên trong database.rules.json, sau đó chạy với --dart-define-from-file=firebase.config.json.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Xem README.md để thiết lập và nhập file database/products.json.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String friendlyError(Object e) {
  if (e is FirebaseAuthException) {
    return switch (e.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Email hoặc mật khẩu không đúng.',
      'invalid-email' => 'Email không hợp lệ.',
      'too-many-requests' => 'Quá nhiều lần thử. Vui lòng thử lại sau.',
      'network-request-failed' => 'Không có kết nối mạng.',
      _ => 'Không thể đăng nhập (${e.code}).',
    };
  }
  return 'Thao tác thất bại. Kiểm tra mạng và quyền truy cập Firebase.';
}

void message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(), password = TextEditingController();
  bool busy = false, hidden = true;
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (busy || !form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );
    } catch (e) {
      if (mounted) setState(() => error = friendlyError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LoginBackdrop(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 420,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 50,
                        color: shopOrange,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Chào mừng trở lại!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Đăng nhập để quản lý gian hàng của bạn',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) => v != null && v.contains('@')
                            ? null
                            : 'Nhập email hợp lệ',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: password,
                        obscureText: hidden,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => login(),
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => hidden = !hidden),
                            icon: Icon(
                              hidden
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Nhập mật khẩu' : null,
                      ),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: busy ? null : login,
                        child: Text(busy ? 'Đang đăng nhập…' : 'Đăng nhập'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ref = FirebaseDatabase.instance.ref('products');
  late final Stream<DatabaseEvent> events = ref.onValue;
  Future<void> edit([Product? product]) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProductDialog(product: product, reference: ref),
    );
  }

  Future<void> remove(Product p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: Text(
          'Bạn muốn xóa “${p.name}”? Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.child(p.id).remove();
      if (mounted) message(context, 'Đã xóa sản phẩm.');
    } catch (e) {
      if (mounted) message(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<DatabaseEvent>(
    stream: events,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('S-Market'),
            actions: [
              IconButton(
                tooltip: 'Đăng xuất',
                onPressed: logout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Không thể đọc dữ liệu. Kiểm tra kết nối và UID admin trong Firebase Rules.',
              ),
            ),
          ),
        );
      }
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final products = <Product>[];
      try {
        for (final child in snapshot.data!.snapshot.children) {
          products.add(
            Product.fromJson(
              child.key!,
              Map<String, dynamic>.from(child.value as Map),
            ),
          );
        }
      } catch (_) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('S-Market'),
            actions: [
              IconButton(
                tooltip: 'Đăng xuất',
                onPressed: logout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: const Center(
            child: Text('Dữ liệu sai định dạng. Kiểm tra bốn trường sản phẩm.'),
          ),
        );
      }
      return ProductCatalog(
        products: products,
        onAdd: () => edit(),
        onEdit: edit,
        onDelete: remove,
        onLogout: logout,
        imageBuilder: productImage,
      );
    },
  );
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (mounted) message(context, friendlyError(e));
    }
  }
}

Widget productImage(String source) {
  Widget fallback() => const ColoredBox(
    color: Color(0xfff6f3ef),
    child: Center(
      child: Icon(Icons.image_outlined, size: 48, color: Color(0xffd4b9a8)),
    ),
  );
  if (source.startsWith('data:image/')) {
    try {
      return Image.memory(
        base64Decode(source.split(',').last),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
      );
    } catch (_) {
      return fallback();
    }
  }
  if (Uri.tryParse(source)?.scheme == 'https') {
    return Image.network(
      source,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback(),
    );
  }
  return fallback();
}

class ProductDialog extends StatefulWidget {
  final Product? product;
  final DatabaseReference reference;
  const ProductDialog({super.key, this.product, required this.reference});
  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.product?.name ?? '');
  late final price = TextEditingController(
    text: widget.product?.price.toString() ?? '',
  );
  late final quantity = TextEditingController(
    text: widget.product?.soluong.toString() ?? '',
  );
  late String image = widget.product?.image ?? '';
  bool busy = false, picking = false;
  @override
  void dispose() {
    name.dispose();
    price.dispose();
    quantity.dispose();
    super.dispose();
  }

  Future<void> pick(ImageSource source) async {
    setState(() => picking = true);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 75,
      );
      if (file == null) return;
      final Uint8List bytes = await file.readAsBytes();
      if (bytes.length > 700000) {
        if (mounted) {
          message(context, 'Ảnh quá lớn. Vui lòng chọn ảnh dưới 700 KB.');
        }
        return;
      }
      final mime = bytes.length >= 3 && bytes[0] == 0xff && bytes[1] == 0xd8
          ? 'image/jpeg'
          : bytes.length >= 4 && bytes[0] == 0x89 && bytes[1] == 0x50
          ? 'image/png'
          : bytes.length >= 12 &&
                ascii.decode(bytes.sublist(8, 12), allowInvalid: true) == 'WEBP'
          ? 'image/webp'
          : null;
      if (mime == null) {
        if (mounted) message(context, 'Chỉ hỗ trợ ảnh JPEG, PNG hoặc WebP.');
        return;
      }
      if (mounted) {
        setState(() => image = 'data:$mime;base64,${base64Encode(bytes)}');
      }
    } catch (_) {
      if (mounted) {
        message(
          context,
          'Không thể mở ảnh. Kiểm tra quyền camera/thư viện ảnh.',
        );
      }
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate() || busy || picking) return;
    if (image.isEmpty) {
      message(context, 'Vui lòng chọn hình ảnh sản phẩm.');
      return;
    }
    setState(() => busy = true);
    try {
      final p = Product(
        id: widget.product?.id ?? '',
        name: name.text.trim(),
        price: double.parse(price.text.trim().replaceAll(',', '.')),
        soluong: int.parse(quantity.text.trim()),
        image: image,
      );
      await (widget.product == null
              ? widget.reference.push()
              : widget.reference.child(p.id))
          .set(p.toJson());
      if (mounted) {
        message(context, 'Đã lưu sản phẩm.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) message(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy && !picking,
    child: AlertDialog(
      title: Text(widget.product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: productImage(image),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: busy || picking
                          ? null
                          : () => pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(picking ? 'Đang đọc ảnh…' : 'Chọn ảnh'),
                    ),
                    if (!kIsWeb &&
                        (defaultTargetPlatform == TargetPlatform.android ||
                            defaultTargetPlatform == TargetPlatform.iOS))
                      TextButton.icon(
                        onPressed: busy || picking
                            ? null
                            : () => pick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Chụp ảnh'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: name,
                  maxLength: 120,
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nhập tên sản phẩm'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Giá sản phẩm (VNĐ)',
                  ),
                  validator: (v) {
                    final n = double.tryParse(
                      (v ?? '').trim().replaceAll(',', '.'),
                    );
                    return n == null ||
                            !n.isFinite ||
                            n < 0 ||
                            n > 1000000000000
                        ? 'Giá phải từ 0 đến 1.000 tỷ (không nhập dấu phân cách nghìn)'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: quantity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số lượng'),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    return n == null || n < 0 || n > 1000000000
                        ? 'Số lượng phải là số nguyên từ 0 đến 1 tỷ'
                        : null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy || picking ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: busy || picking ? null : save,
          child: Text(busy ? 'Đang lưu…' : 'Lưu sản phẩm'),
        ),
      ],
    ),
  );
}
