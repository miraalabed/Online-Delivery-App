import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_provider.dart';
import 'cart_item.dart';
import 'CartItemDetailSheet.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'OrdersScreen.dart';
import 'favorites_screen.dart';
import 'favorite_provider.dart';
import '../strings.dart';

class MenuScreen extends StatefulWidget {
  final String shopName;
  final String workingHours;
  final int userId;

  const MenuScreen({
    super.key,
    required this.shopName,
    required this.workingHours,
    required this.userId,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> menuItems = [];
  List<dynamic> filteredItems = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  void showAddToCartSheet(BuildContext context, dynamic item) {
    final cartItem = CartItem(
      id: item['id'].toString(),
      name: item['name'],
      description: item['description'] ?? Strings.noDescription,
      price: double.parse(item['price'].toString()),
      imageUrl: item['image_url'],
      shopName: widget.shopName,
      shopId: int.parse(item['shop_id'].toString()),
      quantity: 1,
      workingHours: widget.workingHours,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => CartItemDetailSheet(item: cartItem),
    );
  }

  Future<void> fetchMenu() async {
    final url = Uri.parse('http://localhost/project/get_menu.php');
    final response = await http.post(url, body: {'shop_name': widget.shopName});

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        menuItems = jsonData;
        filteredItems = jsonData;
        isLoading = false;
      });
    }
  }

  void filterMenu(String query) {
    setState(() {
      filteredItems = menuItems.where((item) {
        final nameMatch = item['name'].toLowerCase().contains(
          query.toLowerCase(),
        );
        final descMatch = (item['description'] ?? '').toLowerCase().contains(
          query.toLowerCase(),
        );
        return nameMatch || descMatch;
      }).toList();
    });
  }

  void _handleMenuSelection(String value) {
    if (value == Strings.HomeLabel) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (value == Strings.profileLabel) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else if (value == Strings.ordersLabel) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrdersScreen(userId: widget.userId),
        ),
      );
    } else if (value == Strings.favoriteLabel) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FavoriteScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.shopName} '),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                Consumer<CartProvider>(
                  builder: (_, cart, __) {
                    return Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cart.itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          PopupMenuButton<String>(
            color: Colors.white,
            elevation: 0,
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: Strings.HomeLabel,
                child: Row(
                  children: const [
                    Icon(Icons.home, color: Colors.black54),
                    SizedBox(width: 8),
                    Text(
                      Strings.HomeLabel,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: Strings.ordersLabel,
                child: Row(
                  children: const [
                    Icon(Icons.receipt_long, color: Colors.black54),
                    SizedBox(width: 8),
                    Text(
                      Strings.ordersLabel,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: Strings.profileLabel,
                child: Row(
                  children: const [
                    Icon(Icons.person, color: Colors.black54),
                    SizedBox(width: 8),
                    Text(
                      Strings.profileLabel,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: Strings.favoriteLabel,
                child: Row(
                  children: const [
                    Icon(Icons.favorite, color: Colors.black54),
                    SizedBox(width: 8),
                    Text(
                      Strings.favoriteLabel,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: backgroundColor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: Strings.searchShopsHint,
                        filled: true,
                        fillColor: const Color.fromARGB(255, 252, 252, 252),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF408000),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 151, 201, 101),
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        searchQuery = value;
                        filterMenu(value);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];

                        return Card(
                          color: backgroundColor,
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          child: Row(
                            children: [
                              Image.network(
                                item['image_url'] != null &&
                                        item['image_url'].isNotEmpty
                                    ? 'http://localhost/project/${item['image_url']}'
                                    : Strings.placeholderImage,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['description'] ??
                                            Strings.noDescription,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item['price']} ₪',
                                        style: const TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_shopping_cart),
                                    onPressed: () =>
                                        showAddToCartSheet(context, item),
                                  ),
                                  Consumer<FavoriteProvider>(
                                    builder: (context, favProvider, _) {
                                      final isFavorite = favProvider.isFavorite(
                                        item['id'].toString(),
                                      );
                                      return IconButton(
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          favProvider.toggleFavorite({
                                            'id': item['id'],
                                            'name': item['name'],
                                            'description':
                                                item['description'] ?? '',
                                            'price': item['price'],
                                            'image_url': item['image_url'],
                                            'shop_name': widget.shopName,
                                            'shop_id': item['shop_id'],
                                            'working_hours':
                                                widget.workingHours,
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
