import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../strings.dart';

class ViewOrdersScreen extends StatefulWidget {
  final int adminId;
  const ViewOrdersScreen({super.key, required this.adminId});

  @override
  State<ViewOrdersScreen> createState() => _ViewOrdersScreenState();
}

class _ViewOrdersScreenState extends State<ViewOrdersScreen> {
  List shops = [];
  int? selectedShopId;
  List todaysOrders = [];
  List previousOrders = [];
  bool isLoadingShops = true;
  bool isLoadingOrders = false;
  String _selectedTab = "today"; // التبويب الحالي

  @override
  void initState() {
    super.initState();
    fetchShops();
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
            fetchOrders(selectedShopId!);
          }
        });
      }
    } catch (e) {
      setState(() => isLoadingShops = false);
      debugPrint("Error fetching shops: $e");
    }
  }

  Future<void> fetchOrders(int shopId) async {
    setState(() => isLoadingOrders = true);
    try {
      final res = await http.get(
        Uri.parse(
          "http://localhost/project/get_shop_orders.php?shop_id=$shopId",
        ),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final now = DateTime.now();
        List allOrders = data;

        setState(() {
          todaysOrders = allOrders.where((o) {
            final orderDate = DateTime.parse(o['order_date']);
            return orderDate.year == now.year &&
                orderDate.month == now.month &&
                orderDate.day == now.day;
          }).toList();

          previousOrders = allOrders.where((o) {
            final orderDate = DateTime.parse(o['order_date']);
            return !(orderDate.year == now.year &&
                orderDate.month == now.month &&
                orderDate.day == now.day);
          }).toList();

          isLoadingOrders = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingOrders = false);
      debugPrint("Error fetching orders: $e");
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
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
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
                      "Name: ${order['username'] ?? 'Unknown'}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "Phone: ${order['phone_number'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "Delivery Location: ${order['delivery_location'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Order Total: \$${order['total_price']}",
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
                                  Text("Quantity: ${item['quantity']}"),
                                  Text("Price: \$${item['price']}"),
                                  if (item['notes'] != null &&
                                      item['notes'].isNotEmpty)
                                    Text("Notes: ${item['notes']}"),
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

  Widget buildOrderItem(Map order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => showOrderDetails(order),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.shopping_cart, color: Colors.green.shade700),
            ),
            title: Text(
              "Order - \$${order['total_price']}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              "Date: ${order['order_date']}",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTabItem(String text, String tabKey, int count) {
    bool isSelected = _selectedTab == tabKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabKey;
        });
      },
      child: Column(
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.green : Colors.grey.shade400,
            ),
            child: Text("$text ($count)"),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 4,
            width: isSelected ? 45 : 0,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          Strings.ordersLabel,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTabItem("Today", "today", todaysOrders.length),
              const SizedBox(width: 24),
              buildTabItem("Previous", "previous", previousOrders.length),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          isLoadingShops
              ? const LinearProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        hint: const Text("Select Shop"),
                        value: selectedShopId,
                        items: shops.map<DropdownMenuItem<int>>((shop) {
                          return DropdownMenuItem<int>(
                            value: int.parse(shop['id'].toString()),
                            child: Text(shop['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedShopId = value;
                            todaysOrders = [];
                            previousOrders = [];
                          });
                          if (value != null) fetchOrders(value);
                        },
                      ),
                    ),
                  ),
                ),
          isLoadingOrders
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: _selectedTab == "today"
                      ? todaysOrders.isEmpty
                            ? const Center(
                                child: Text(Strings.noOrdersAvailable),
                              )
                            : ListView.builder(
                                itemCount: todaysOrders.length,
                                itemBuilder: (context, index) =>
                                    buildOrderItem(todaysOrders[index]),
                              )
                      : previousOrders.isEmpty
                      ? const Center(child: Text(Strings.noOrdersAvailable))
                      : ListView.builder(
                          itemCount: previousOrders.length,
                          itemBuilder: (context, index) =>
                              buildOrderItem(previousOrders[index]),
                        ),
                ),
        ],
      ),
    );
  }
}
