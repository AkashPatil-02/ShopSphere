import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/widgets/carousel.dart';
import 'package:shopsphere/core/widgets/reviews.dart';
import 'package:shopsphere/features/cart/cubit/storage_cubit.dart';
import 'package:shopsphere/features/cart/cubit/storage_state.dart';
import 'package:shopsphere/features/cart/model/cart_model.dart';
import 'package:shopsphere/features/products/cubit/product_cubit.dart';
import 'package:shopsphere/features/products/cubit/product_state.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int pID;

  const ProductDetailsScreen({super.key, required this.pID});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().getProductDetails(widget.pID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text('Product not found'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductCubit>().getProductDetails(
                        widget.pID,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProductLoaded) {
            final product = state.product;

            final inStock = product.stock > 0;
            final discount = product.discountPercentage;
            final originalPrice = discount > 0
                ? product.price / (1 - discount / 100)
                : product.price;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Carousel(product: product, controller: _controller),
                const SizedBox(height: 20),

                if (product.brand != null && product.brand!.isNotEmpty)
                  Text(
                    product.brand!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                const SizedBox(height: 6),

                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Product rating',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (discount > 0) ...[
                      Text(
                        '\$${originalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 75, 133, 87),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${discount.toStringAsFixed(0)}% OFF',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 142, 255, 37),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Icon(
                      inStock
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      color: inStock ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      inStock
                          ? '${product.stock} available in stock'
                          : 'Out of stock',
                      style: TextStyle(
                        color: inStock ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey.shade700,
                  ),
                ),

                const Divider(height: 32),

                const Text(
                  'Quantity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton.outlined(
                      onPressed: quantity > 1
                          ? () => setState(() => quantity--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton.outlined(
                      onPressed: inStock && quantity < product.stock
                          ? () => setState(() => quantity++)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: !inStock
                        ? null
                        : () async {
                            final cartProduct = CartProduct(
                              id: product.id,
                              title: product.title,
                              price: product.price.toDouble(),
                              discountPercentage: product.discountPercentage
                                  .toDouble(),
                              thumbnail: product.thumbnail,
                              stock: product.stock,
                              quantity: quantity,
                            );

                            await context.read<CartCubit>().addToCart(
                              cartProduct,
                            );

                            if (!context.mounted) return;

                            final state = context.read<CartCubit>().state;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  state is CartFailure
                                      ? state.message
                                      : '${product.title} added to cart',
                                ),
                              ),
                            );
                          },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: Text(inStock ? 'Add to Cart' : 'Out of Stock'),
                  ),
                ),

                const Divider(height: 40),

                const Text(
                  'Customer Reviews',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (product.reviews.isEmpty)
                  const Text('No reviews yet.')
                else
                  ...product.reviews.map(
                    (review) => Reviews(
                      name: review.reviewerName,
                      rating: review.rating,
                      date: review.date.toLocal().toString().split(' ').first,
                      comment: review.comment,
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
