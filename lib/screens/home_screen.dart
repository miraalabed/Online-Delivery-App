import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_provider.dart';
import 'package:provider/provider.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'shop_details_screen.dart';
import 'MenuScreen.dart';
import 'favorites_screen.dart';
import 'OrdersScreen.dart';
import '../strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> shops = [];
  List<dynamic> filteredShops = [];
  bool showSearch = false;
  String selectedCategory = Strings.all;
  String selectedLocation = Strings.all;

  TextEditingController searchController = TextEditingController();
  int _selectedIndex = 0;
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchShops();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
  }

  Future<void> fetchShops() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost/project/get_all_shops.php"),
      );
      if (response.statusCode == 200) {
        setState(() {
          shops = json.decode(response.body);
          filteredShops = shops;
        });
      } else {
        throw Exception(Strings.errorLoadingShops);
      }
    } catch (e) {
      print("${Strings.errorFetchingShops}: $e");
    }
  }

  void filterShops() {
    setState(() {
      filteredShops = shops.where((shop) {
        final type = shop["type"] ?? "";
        final location = shop["location"] ?? "";
        final name = shop["name"] ?? "";

        bool matchesCategory =
            selectedCategory == Strings.all || type == selectedCategory;

        bool matchesLocation =
            selectedLocation == Strings.all ||
            (location.split('-')[0].trim() == selectedLocation);

        bool matchesSearch =
            searchController.text.isEmpty ||
            name.toLowerCase().contains(searchController.text.toLowerCase());

        return matchesCategory && matchesLocation && matchesSearch;
      }).toList();
    });
  }

  bool isShopOpen(String workingHours) {
    try {
      if (workingHours.isEmpty) return false;

      final now = DateTime.now();
      final parts = workingHours.split('-');
      if (parts.length != 2) return false;

      final format = DateFormat('h:mm a');
      final openTime = format.parse(parts[0].trim());
      final closeTime = format.parse(parts[1].trim());

      final todayOpen = DateTime(
        now.year,
        now.month,
        now.day,
        openTime.hour,
        openTime.minute,
      );
      var todayClose = DateTime(
        now.year,
        now.month,
        now.day,
        closeTime.hour,
        closeTime.minute,
      );

      if (todayClose.isBefore(todayOpen)) {
        todayClose = todayClose.add(const Duration(days: 1));
      }

      return now.isAfter(todayOpen) && now.isBefore(todayClose);
    } catch (e) {
      print('${Strings.errorParsingHours}: $e');
      return false;
    }
  }

  Future<void> openMap(double lat, double lng) async {
    final googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.errorOpeningMap)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                "assets/img.png",
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
              ),
              Positioned(
                left: 10,
                top: 10,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF408000).withOpacity(0.2),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF408000)),
                    iconSize: 25,
                    onPressed: () {
                      setState(() {
                        showSearch = !showSearch;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          if (showSearch)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
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
                      color: Color(0xFF408000),
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) => filterShops(),
              ),
            ),
          Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...[
                  Strings.all,
                  Strings.restaurantCategory,
                  Strings.sweetsCategory,
                  Strings.cafeCategory,
                ].map((category) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                        filterShops();
                      });
                    },
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: selectedCategory == category
                            ? const Color(0xFF408000)
                            : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                DropdownButton<String>(
                  value: selectedLocation,
                  hint: const Text(Strings.locationLabel),
                  items:
                      [
                        Strings.all,
                        Strings.nablus,
                        Strings.ramallah,
                        Strings.birzeit,
                        Strings.hebron,
                        Strings.jerusalem,
                      ].map((location) {
                        return DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedLocation = value;
                        filterShops();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredShops.isEmpty
                ? const Center(child: Text(Strings.noShopsFound))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: filteredShops.length,
                    itemBuilder: (context, index) {
                      final shop = filteredShops[index];
                      final workingHours =
                          shop["working_hours"] ?? shop["workingHours"] ?? "";
                      final isOpen = isShopOpen(workingHours);

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuScreen(
                                shopName: shop["name"] ?? "",
                                workingHours: workingHours,
                                userId: userId!,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              children: [
                                Image.network(
                                  (shop["image_url"] != null &&
                                          shop["image_url"]
                                              .toString()
                                              .isNotEmpty)
                                      ? 'http://localhost/project/${shop["image_url"]}'
                                      : Strings.placeholderImage,
                                  width: double.infinity,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shop["name"] ?? "",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.location_on,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () {
                                              final lat = shop["latitude"];
                                              final lng = shop["longitude"];
                                              if (lat != null && lng != null) {
                                                double? latitude =
                                                    double.tryParse(
                                                      lat.toString(),
                                                    );
                                                double? longitude =
                                                    double.tryParse(
                                                      lng.toString(),
                                                    );
                                                if (latitude != null &&
                                                    longitude != null) {
                                                  openMap(latitude, longitude);
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        Strings
                                                            .invalidCoordinates,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      Strings
                                                          .coordinatesUnavailable,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          Expanded(
                                            child: Text(
                                              shop["location"] ?? "",
                                              style: const TextStyle(
                                                color: Colors.blueGrey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isOpen
                                                  ? Colors.green
                                                  : Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              isOpen
                                                  ? Strings.openLabel
                                                  : Strings.closedLabel,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.info_outline,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ShopDetailsScreen(
                                                        name:
                                                            shop["name"] ?? "",
                                                        location:
                                                            shop["location"] ??
                                                            "",
                                                        phone:
                                                            shop["phone"] ?? "",
                                                        workingHours:
                                                            workingHours,
                                                        description:
                                                            shop["description"] ??
                                                            "",
                                                        imageUrl:
                                                            shop["image_url"] ??
                                                            "",
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.grey,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            } else if (index == 2) {
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrdersScreen(userId: userId!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(Strings.userIdNotFound)),
                );
              }
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 26),
              label: Strings.profileLabel,
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart, size: 26),
                  Positioned(
                    right: 0,
                    child: Consumer<CartProvider>(
                      builder: (_, cart, __) => Container(
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
                    ),
                  ),
                ],
              ),
              label: Strings.cartLabel,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long, size: 26),
              label: Strings.ordersLabel,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite, size: 26, color: Colors.red),
              label: Strings.favoriteLabel,
            ),
          ],
        ),
      ),
    );
  }
}
