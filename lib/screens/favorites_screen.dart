import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_item.dart';
import 'CartItemDetailSheet.dart';
import 'favorite_provider.dart';
import '../strings.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void dispose() {
    Provider.of<FavoriteProvider>(context, listen: false).applyRemovedOnBack();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, _) {
        final favorites = favProvider.favorites;

        if (favorites.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(Strings.favoritesTitle),
              backgroundColor: Colors.white30,
            ),
            body: const Center(child: Text(Strings.noFavorites)),
          );
        }

        final Map<String, List<Map<String, dynamic>>> groupedByShop = {};
        for (var item in favorites) {
          final shop = item['shop_name'] ?? Strings.unknownShop;
          groupedByShop.putIfAbsent(shop, () => []).add(item);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(Strings.favoritesTitle),
            backgroundColor: Colors.white30,
          ),
          body: ListView(
            children: groupedByShop.entries.map((entry) {
              final shopName = entry.key;
              final items = entry.value;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      ...items.map((item) {
                        final isRemoved = favProvider.removedIds.contains(
                          item['id'].toString(),
                        );

                        return ListTile(
                          leading: Image.network(
                            'http://localhost/project/${item['image_url']}',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item['name']),
                          subtitle: Text(
                            "${Strings.priceLabel}: ${item['price']} ₪",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.black54,
                                ),
                                onPressed: () {
                                  final cartItem = CartItem(
                                    id: item['id'].toString(),
                                    name: item['name'],
                                    description: item['description'] ?? '',
                                    price: double.parse(
                                      item['price'].toString(),
                                    ),
                                    imageUrl: item['image_url'],
                                    shopName: shopName,
                                    shopId: int.parse(
                                      item['shop_id'].toString(),
                                    ),
                                    quantity: 1,
                                    notes: null,
                                    workingHours: item['working_hours'] ?? '',
                                  );

                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) =>
                                        CartItemDetailSheet(item: cartItem),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  isRemoved
                                      ? Icons.favorite_border
                                      : Icons.favorite,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  favProvider.toggleRemoved(
                                    item['id'].toString(),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
