import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'profile_screen.dart';
import 'ManageShopsScreen.dart';
import 'ViewOrdersScreen.dart';
import 'NotificationsScreen.dart';
import '../strings.dart';

class AdminHomeScreen extends StatefulWidget {
  final int adminId;
  const AdminHomeScreen({super.key, required this.adminId});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int? selectedShopId;
  List shops = [];
  List orders = [];
  List products = [];
  bool isLoadingShops = true;
  bool isLoadingData = false;
  int totalNewOrdersCount = 0;
  String adminName = "Admin";

  @override
  void initState() {
    super.initState();
    fetchAdminName();
    fetchShops();
    fetchTotalNewOrdersCount();
  }

  Future<void> fetchAdminName() async {
    try {
      final res = await http.get(
        Uri.parse(
          "http://localhost/project/get_admin_name.php?admin_id=${widget.adminId}",
        ),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          adminName = data['name'] ?? "Admin";
        });
      }
    } catch (e) {
      debugPrint("Error fetching admin name: $e");
      setState(() {
        adminName = "Admin";
      });
    }
  }

  Future<void> fetchShops() async {
    setState(() => isLoadingShops = true);
    try {
      final res = await http.get(
        Uri.parse(
          "http://localhost/project/get_admin_shops.php?admin_id=${widget.adminId}",
        ),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          shops = data;
          isLoadingShops = false;
          if (shops.isNotEmpty) {
            selectedShopId = int.parse(shops[0]['id'].toString());
            fetchOrdersAndProducts(selectedShopId!);
          }
        });
      }
    } catch (e) {
      setState(() => isLoadingShops = false);
      debugPrint("Error fetching shops: $e");
    }
  }

  Future<void> fetchOrdersAndProducts(int shopId) async {
    setState(() => isLoadingData = true);
    try {
      final res = await http.get(
        Uri.parse(
          "http://localhost/project/get_latest_data.php?shop_id=$shopId",
        ),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          orders = data['orders'];
          products = data['products'];
          isLoadingData = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingData = false);
      debugPrint("Error fetching data: $e");
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const primaryColor = Color(0xFF408000);

    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.2),
          child: Icon(icon, color: primaryColor),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Future<void> fetchTotalNewOrdersCount() async {
    try {
      final res = await http.get(
        Uri.parse(
          "http://localhost/project/get_new_orders_count.php?admin_id=${widget.adminId}",
        ),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          totalNewOrdersCount = data['count'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching total new orders count: $e");
    }
  }

  Future<void> showOrderDetails(Map order) async {
    try {
      final res = await http.get(
        Uri.parse(
          "http://localhost/project/get_order_items.php?order_id=${order['id']}",
        ),
      );
      final items = json.decode(res.body);
      markOrderAsSeen(int.parse(order['id'].toString()));

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: const Text(
                        Strings.orderDetails,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      Strings.customerInfo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${Strings.customer}${order['username'] ?? 'Unknown'}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "${Strings.phone}${order['phone_number'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "${Strings.deliveryLocation}${order['delivery_location'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${Strings.orderTotal}${order['total_price']}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        Strings.orderItemsTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item['image_url'] != null &&
                                          item['image_url'].isNotEmpty
                                      ? 'http://localhost/project/${item['image_url']}'
                                      : 'https://via.placeholder.com/50',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                item['item_name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    "${Strings.quantity}${item['quantity']}",
                                  ),
                                  Text("${Strings.price}${item['price']}"),
                                  if (item['notes'] != null &&
                                      item['notes'].isNotEmpty)
                                    Text("${Strings.notes}${item['notes']}"),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error fetching order items: $e");
    }
  }

  Future<void> markOrderAsSeen(int orderId) async {
    try {
      await http.post(
        Uri.parse("http://localhost/project/mark_order_seen.php"),
        body: {'order_id': orderId.toString()},
      );
      setState(() {
        final order = orders.firstWhere((o) => o['id'] == orderId);
        order['flag'] = 1;
      });
      fetchTotalNewOrdersCount();
    } catch (e) {
      debugPrint("Error marking order as seen: $e");
    }
  }

  Future<void> markAllOrdersAsSeen() async {
    try {
      await http.post(
        Uri.parse("http://localhost/project/mark_all_orders_seen.php"),
        body: {'shop_id': selectedShopId.toString()},
      );
      setState(() {
        for (var o in orders) o['flag'] = 1;
        totalNewOrdersCount = 0;
      });
    } catch (e) {
      debugPrint("Error marking all orders as seen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.adminPanel),
        centerTitle: true,
        backgroundColor: Colors.white30,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsScreen(),
                    ),
                  );
                },
              ),
              if (totalNewOrdersCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$totalNewOrdersCount',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF408000).withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF408000),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final hour = DateTime.now().hour;
                      String greeting;
                      if (hour < 12) {
                        greeting = Strings.goodMorning;
                      } else if (hour < 18) {
                        greeting = Strings.goodAfternoon;
                      } else {
                        greeting = Strings.goodEvening;
                      }
                      return Text(
                        greeting,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      icon: Icons.person,
                      label: Strings.viewProfile,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.store,
                      label: Strings.manageShops,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ManageShopsScreen(adminId: widget.adminId),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.receipt_long,
                      label: Strings.viewOrders,
                      onTap: () {
                        if (selectedShopId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewOrdersScreen(adminId: widget.adminId),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(Strings.pleaseSelectShopFirst),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoadingShops
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade100.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DropdownButton<int>(
                      value: selectedShopId,
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      hint: Text(
                        shops.isEmpty
                            ? Strings.noShopsAvailable
                            : Strings.selectShop,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      items: shops.map<DropdownMenuItem<int>>((shop) {
                        return DropdownMenuItem<int>(
                          value: int.parse(shop['id'].toString()),
                          child: Text(shop['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedShopId = value;
                          orders = [];
                          products = [];
                        });
                        if (value != null) fetchOrdersAndProducts(value);
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoadingData
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        const Text(
                          Strings.lastOrders,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...orders.asMap().entries.map((entry) {
                          int index = entry.key;
                          var o = entry.value;
                          return TweenAnimationBuilder(
                            tween: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ),
                            duration: Duration(milliseconds: 300 + index * 50),
                            curve: Curves.easeOut,
                            builder: (context, Offset offset, child) {
                              return Transform.translate(
                                offset: Offset(0, offset.dy * 50),
                                child: AnimatedOpacity(
                                  opacity: 1,
                                  duration: const Duration(milliseconds: 500),
                                  child: GestureDetector(
                                    onTap: () => showOrderDetails(o),
                                    child: Card(
                                      color: o['flag'] == 0
                                          ? Colors.red.shade50
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 3,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Order - \$${o['total_price']}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text("Date: ${o['order_date']}"),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                        const Divider(height: 30),
                        const Text(
                          Strings.lastProducts,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...products.asMap().entries.map((entry) {
                          int index = entry.key;
                          var p = entry.value;
                          return TweenAnimationBuilder(
                            tween: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ),
                            duration: Duration(milliseconds: 300 + index * 50),
                            curve: Curves.easeOut,
                            builder: (context, Offset offset, child) {
                              return Transform.translate(
                                offset: Offset(0, offset.dy * 50),
                                child: AnimatedOpacity(
                                  opacity: 1,
                                  duration: const Duration(milliseconds: 500),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 3,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: ListTile(
                                      leading: p['image_url'] != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.network(
                                                "http://localhost/project/${p['image_url']}",
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : null,
                                      title: Text(
                                        p['name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "${Strings.price}${p['price']}",
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
