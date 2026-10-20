
class AddCartRequest {
  final int userId;
  final List<AddCartProduct> products;

  const AddCartRequest({
    required this.userId,
    required this.products,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}

class AddCartProduct {
  final int id;
  final int quantity;

  const AddCartProduct({
    required this.id,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
    };
  }
}
