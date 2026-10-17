import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shopsphere/core/widgets/category_chips.dart';
import 'package:shopsphere/core/network/home_endpoints.dart';
import 'package:shopsphere/core/widgets/product_grid.dart';
import 'package:shopsphere/core/widgets/product_grid_shimmer.dart';
import 'package:shopsphere/features/home/cubit/home_cubit.dart';
import 'package:shopsphere/features/home/cubit/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(HomeEndpoints())..loadCategories(),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'S H O P S P H E R E',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.sunny),
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
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 116, 116, 116),
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: 'Search',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 246, 246, 245),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (state is Initialize || state is Loading)
                    const CategoryChipsShimmer()
                  else if (categories.isNotEmpty)
                    CategoryChips(
                      categories: categories,
                      selectedCategory: selectedCategory,
                      onSelected: (category) =>
                          cubit.loadProductsByCategory(category),
                      onAllSelected: () => cubit.loadAllProducts(),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No categories found.'),
                    ),

                  const SizedBox(height: 12),
                  Expanded(
                    child: _buildProductSection(state),
                  ),
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
      return ProductGridShimmer();
    }

    if (state is ProductsFailure) {
      return Center(child: Text('Error: ${state.error}'));
    }

    if (state is ProductsSuccess) {
      if (state.products.isEmpty) {
        return const Center(child: Text('No products in this category.'));
      }
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: state.products.length,
        itemBuilder: (_, i) => ProductCard(product: state.products[i]),
      );
    }
    return ProductGridShimmer();
  }
}