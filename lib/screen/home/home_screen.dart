import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:restaurant_review/provider/home/restaurant_list_provider.dart';
import 'package:restaurant_review/screen/component/restaurant_card_widget.dart';
import 'package:restaurant_review/static/navigation_route.dart';
import 'package:restaurant_review/static/restaurant_list_result_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<RestaurantListProvider>().fetchRestaurantList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                "Discover Restaurants",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.background,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 8),
            sliver: Consumer<RestaurantListProvider>(
              builder: (context, provider, _) {
                return switch (provider.resultState) {
                  RestaurantListLoadingState() => SliverFillRemaining(
                      child: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.width * 0.5,
                          child: Lottie.asset(
                              'assets/animations/loading-anim.json'),
                        ),
                      ),
                    ),
                  RestaurantListLoadedState(data: var restaurants) =>
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 300,
                          childAspectRatio: 0.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final restaurant = restaurants[index];
                            return RestaurantCard(
                              key: ValueKey(restaurant.id),
                              restaurant: restaurant,
                              onTap: () => Navigator.pushNamed(
                                context,
                                NavigationRoute.detailRoute.name,
                                arguments: restaurant.id,
                              ),
                            );
                          },
                          childCount: restaurants.length,
                        ),
                      ),
                    ),
                  RestaurantListErrorState(error: var message) =>
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              message,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => provider.fetchRestaurantList(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  _ => const SliverToBoxAdapter(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
