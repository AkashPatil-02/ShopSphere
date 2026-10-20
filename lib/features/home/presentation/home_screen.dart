import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';

import 'package:shopsphere/features/home/data/home_repository.dart';
import 'package:shopsphere/features/cart/data/cart_local_repository.dart';
import 'package:shopsphere/core/widgets/category_chips.dart';
import 'package:shopsphere/core/widgets/product_card.dart';
import 'package:shopsphere/core/widgets/product_grid_shimmer.dart';
import 'package:shopsphere/core/widgets/sort.dart';

import 'package:shopsphere/features/cart/cubit/storage_cubit.dart';
import 'package:shopsphere/features/cart/cubit/storage_state.dart';
import 'package:shopsphere/features/cart/data/cart_model.dart';
import 'package:shopsphere/features/cart/presentation/cart_screen.dart';

import 'package:shopsphere/features/home/cubit/home_cubit.dart';
import 'package:shopsphere/features/home/cubit/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomeCubit(HomeRepository())..loadCategories(),
        ),
        BlocProvider(
          create: (_) =>
              CartCubit(CartLocalRepository(Hive.box<CartProduct>('cart')))
                ..loadCart(),
        ),
      ],
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<HomeCubit>().loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'S h o p S p h e r e',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              int itemCount = 0;
              if (cartState is CartLoaded) {
                itemCount = cartState.itemCount;
              }

              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<CartCubit>(),
                        child: const CartScreen(),
                      ),
                    ),
                  );
                },
                icon: Badge.count(
                  count: itemCount,
                  child: const Icon(Icons.shopping_cart_rounded),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is Failure) {
            return Center(child: Text('Error: ${state.error}'));
          }

          final cubit = context.read<HomeCubit>();
          final categories = cubit.categories;

          String? selectedCategory;
          if (state is ProductsSuccess) selectedCategory = state.category;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(
                        const Duration(milliseconds: 400),
                        () {
                          if (!mounted) return;
                          context.read<HomeCubit>().searchProducts(value);
                        },
                      );
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 116, 116, 116),
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                context.read<HomeCubit>().searchProducts('');
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                      hintText: 'Search Catalogue',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 246, 246, 245),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (state is Initialize || state is Loading)
                    const CategoryChipsShimmer()
                  else if (categories.isNotEmpty)
                    Row(
                      children: [
                        SortOptions(
                          onChanged: (value) {
                            context.read<HomeCubit>().sortProducts(value);
                          },
                        ),
                        Expanded(
                          child: CategoryChips(
                            categories: categories,
                            selectedCategory: selectedCategory,
                            onSelected: (category) =>
                                cubit.loadProductsByCategory(category),
                            onAllSelected: () => cubit.loadAllProducts(),
                          ),
                        ),
                      ],
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No categories found.'),
                    ),

                  const SizedBox(height: 12),
                  Expanded(child: _buildProductSection(state)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductSection(HomeState state) {
    if (state is Initialize || state is Loading || state is ProductsLoading) {
      return const ProductGridShimmer();
    }

    if (state is ProductsFailure) {
      return Center(child: Text('Error: ${state.error}'));
    }

    if (state is ProductsSuccess) {
      if (state.products.isEmpty) {
        return const Center(child: Text('No products found :('));
      }

      return RefreshIndicator(
        onRefresh: () => context.read<HomeCubit>().refreshProducts(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // <-- Grid size/columns
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.70, // <-- Adjusted aspect ratio
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return ProductCard(product: state.products[index]);
                }, childCount: state.products.length),
              ),
            ),
            if (state.isLoadingMore || !state.hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: state.isLoadingMore
                        ? const CircularProgressIndicator()
                        : const Text(
                            "You've reached the end",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    return const ProductGridShimmer();
  }
}

Widget footer(bool hasMore) {
  if (hasMore) {
    return const Center(child: CircularProgressIndicator());
  }
  return const Center(child: Text("You Have Reached the End"));
}