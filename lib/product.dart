class Product {
  final String id;
  final String name;
  final double price;
  final int soluong;
  final String image;
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.soluong,
    required this.image,
  });
  factory Product.fromJson(String id, Map<String, dynamic> json) {
    if (json.keys.toSet().difference({
          'name',
          'price',
          'soluong',
          'image',
        }).isNotEmpty ||
        json.length != 4 ||
        json['name'] is! String ||
        (json['name'] as String).trim().isEmpty ||
        json['price'] is! num ||
        !(json['price'] as num).isFinite ||
        (json['price'] as num) < 0 ||
        json['soluong'] is! int ||
        (json['soluong'] as int) < 0 ||
        json['image'] is! String) {
      throw const FormatException(
        'Sản phẩm phải có đúng name, price, soluong, image hợp lệ.',
      );
    }
    return Product(
      id: id,
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      soluong: json['soluong'],
      image: json['image'],
    );
  }
  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'soluong': soluong,
    'image': image,
  };
}
