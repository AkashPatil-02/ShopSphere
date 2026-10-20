import 'package:hive_ce/hive.dart';

part 'cart_model.g.dart';

@HiveType(typeId: 1)
class CartProduct {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final double discountPercentage;

  @HiveField(4)
  final String thumbnail;

  @HiveField(5)
  final int quantity;

  @HiveField(6)
  final int stock;

  const CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.discountPercentage,
    required this.thumbnail,
    required this.stock,
    this.quantity = 1,
  });

  double get discountedPrice => price * (1 - discountPercentage / 100);

  double get totalPrice => discountedPrice * quantity;

  CartProduct copyWith({int? quantity}) {
    return CartProduct(
      id: id,
      stock: stock,
      title: title,
      price: price,
      discountPercentage: discountPercentage,
      thumbnail: thumbnail,
      quantity: quantity ?? this.quantity,
    );
  }
}
