import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../strings.dart';

class OrdersScreen extends StatefulWidget {
  final int userId;
  const OrdersScreen({super.key, required this.userId});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> todayOrders = [];
  List<dynamic> previousOrders = [];
  bool loading = true;
  String selectedTab = "today";

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      loading = true;
    });

    try {
      // Today's orders
      final todayRes = await http.get(
        Uri.parse(
          "http://localhost/project/get_user_orders.php?user_id=${widget.userId}&period=today",
        ),
      );

      // All previous orders
      final prevRes = await http.get(
        Uri.parse(
          "http://localhost/project/get_user_orders.php?user_id=${widget.userId}&period=previous",
        ),
      );

      setState(() {
        todayOrders = json.decode(todayRes.body);
        previousOrders = json.decode(prevRes.body);
        loading = false;
      });
    } catch (e) {
      print("${Strings.errorOccurred}: $e");
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> showOrderItems(int orderId) async {
    try {
      final res = await http.get(
        Uri.parse(
          "http://localhost/project/get_order_items.php?order_id=$orderId",
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  Strings.orderItemsTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFF408000).withOpacity(0.2),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item['image_url'] != null &&
                                    item['image_url'].isNotEmpty
                                ? 'http://localhost/project/${item['image_url']}'
                                : Strings.placeholderImage,
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
                            Text("${Strings.quantityLabel}${item['quantity']}"),
                            Text("${Strings.priceLabel}${item['price']}"),
                            if (item['notes'] != null &&
                                item['notes'].isNotEmpty)
                              Text("${Strings.notesLabel}${item['notes']}"),
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
      );
    } catch (e) {
      print("${Strings.errorOccurred}: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedOrders = selectedTab == "today"
        ? todayOrders
        : previousOrders;
    const primaryGreen = Color(0xFF408000);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          Strings.ordersLabel,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              tabItem(Strings.todaysOrders, "today", primaryGreen),
              const SizedBox(width: 24),
              tabItem(Strings.previousOrders, "previous", primaryGreen),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : displayedOrders.isEmpty
                ? Center(
                    child: Text(
                      Strings.noOrdersAvailable,
                      style: const TextStyle(
                        color: Colors.black38,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: displayedOrders.length,
                    itemBuilder: (context, index) {
                      final order = displayedOrders[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          shadowColor: primaryGreen.withOpacity(0.2),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(
                                order['shop_image_url'] != null &&
                                        order['shop_image_url'].isNotEmpty
                                    ? 'http://localhost/project/${order['shop_image_url']}'
                                    : Strings.placeholderImage,
                              ),
                            ),
                            title: Text(
                              order['shop_name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              "${order['order_date']} - \$${order['total_price']}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            onTap: () => showOrderItems(order['order_id']),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            tileColor: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget tabItem(String text, String tabValue, Color primaryGreen) {
    bool isSelected = selectedTab == tabValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = tabValue;
        });
      },
      child: Column(
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? primaryGreen : Colors.grey.shade400,
            ),
            child: Text(text),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 4,
            width: isSelected ? 45 : 0,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
