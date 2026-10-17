import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shopsphere/core/network/home_endpoints.dart';
import 'package:shopsphere/core/widgets/category_chips.dart';
import 'package:shopsphere/features/home/cubit/home_cubit.dart';
import 'package:shopsphere/features/home/cubit/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(
        HomeEndpoints(),
      )..loadCategories(),
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
  final TextEditingController _searchController =
      TextEditingController();

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
          if (state is Initialize || state is Loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is Failure) {
            return Center(
              child: Text('Error: ${state.error}'),
            );
          }

          if (state is Success) {
            if (state.entries.isEmpty) {
              return const Center(
                child: Text('No categories...'),
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            const Color.fromARGB(255, 116, 116, 116),
                        prefixIcon:
                            const Icon(Icons.search_rounded),
                        hintText: 'Search',
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 246, 246, 245),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CategoryChips(categories: state.entries),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: Text('Something went wrong.'),
          );
        },
      ),
    );
  }
}
