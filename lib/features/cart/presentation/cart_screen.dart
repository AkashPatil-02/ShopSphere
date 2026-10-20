
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/network/cart_endpoints.dart';
import 'package:shopsphere/features/cart/cubit/storage_cubit.dart';
import 'package:shopsphere/features/cart/cubit/storage_state.dart';
import 'package:shopsphere/features/cart/presentation/success_screen.dart';
import 'package:shopsphere/features/profile/cubit/profile_cubit.dart';
import 'package:shopsphere/features/profile/cubit/profile_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartEndpoints _cartApi = CartEndpoints();
  bool _isCheckingOut = false;

  @override
  void dispose() {
    _cartApi.dispose();
    super.dispose();
  }

  Future<void> _proceedToCheckout({
    required int itemCount,
    required double total,
  }) async {
    if (_isCheckingOut) return;

    final profileState = context.read<ProfileCubit>().state;

    if (profileState is! ProfileSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in before proceeding.'),
        ),
      );
      return;
    }

    final userId = profileState.profile.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to identify the logged-in user.'),
        ),
      );
      return;
    }

    setState(() => _isCheckingOut = true);

    try {
      final response = await context
          .read<CartCubit>()
          .syncCartToDummyJson(
            userId: userId,
            cartep: _cartApi,
          );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CheckoutSuccessScreen(
            cartId: response['id']?.toString() ?? 'N/A',
            itemCount: itemCount,
            total: total,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCheckingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: false,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartInitial || state is CartLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is CartFailure) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is! CartLoaded) {
            return const SizedBox.shrink();
          }

          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some products to get started.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          final cartCubit = context.read<CartCubit>();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.items.length} different products',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: _isCheckingOut
                          ? null
                          : () => _confirmClearCart(context),
                      child: const Text('Clear cart'),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.items[index];

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 100,
                                height: 110,
                                color: Colors.grey.withValues(alpha: 0.08),
                                child: Image.network(
                                  item.thumbnail,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity:
                                            VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints:
                                            const BoxConstraints(),
                                        tooltip: 'Remove product',
                                        onPressed: _isCheckingOut
                                            ? null
                                            : () => cartCubit
                                                .removeFromCart(item.id),
                                        icon: Icon(
                                          Icons.close,
                                          size: 20,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    '\$${item.discountedPrice.toStringAsFixed(2)} each',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      _QuantityButton(
                                        icon: Icons.remove,
                                        onPressed:
                                            !_isCheckingOut &&
                                                    item.quantity > 1
                                                ? () =>
                                                    cartCubit.updateQuantity(
                                                      item.id,
                                                      item.quantity - 1,
                                                    )
                                                : null,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      _QuantityButton(
                                        icon: Icons.add,
                                        onPressed:
                                            !_isCheckingOut &&
                                                    item.quantity < item.stock
                                                ? () =>
                                                    cartCubit.updateQuantity(
                                                      item.id,
                                                      item.quantity + 1,
                                                    )
                                                : null,
                                      ),
                                      const Spacer(),
                                      Flexible(
                                        child: Text(
                                          '\$${item.totalPrice.toStringAsFixed(2)}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              _CartSummary(
                itemCount: state.itemCount,
                total: state.total,
                isLoading: _isCheckingOut,
                onCheckout: () => _proceedToCheckout(
                  itemCount: state.itemCount,
                  total: state.total,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmClearCart(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text(
          'This will remove all products from your cart.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<CartCubit>().clearCart();
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton.outlined(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final int itemCount;
  final double total;
  final bool isLoading;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.itemCount,
    required this.total,
    required this.isLoading,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items ($itemCount)',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text('$itemCount'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: isLoading ? null : onCheckout,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Proceed to Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
