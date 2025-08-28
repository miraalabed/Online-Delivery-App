import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'AddProductScreen.dart';
import 'EditProductScreen.dart';
import 'admin_home_screen.dart';
import 'ViewOrdersScreen.dart';
import 'profile_screen.dart';
import '../strings.dart';

class ShopProductsScreen extends StatefulWidget {
  final int shopId;
  final String shopName;
  final String serverIP;
  final int adminId;

  const ShopProductsScreen({
    super.key,
    required this.shopId,
    required this.shopName,
    required this.serverIP,
    required this.adminId,
  });

  @override
  State<ShopProductsScreen> createState() => _ShopProductsScreenState();
}

class _ShopProductsScreenState extends State<ShopProductsScreen> {
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse(
          "http://${widget.serverIP}/project/get_shop_products.php?shop_id=${widget.shopId}",
        ),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          products = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint("Error: status code ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final res = await http.post(
        Uri.parse("http://${widget.serverIP}/project/delete_product.php"),
        body: {'product_id': productId.toString()},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          setState(() {
            products.removeWhere((p) => p['id'] == productId);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Failed to delete product"),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error deleting product: $e");
    }
  }

  void _confirmDeleteProduct(int productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Strings.confirmDeleteTitle),
        content: const Text(Strings.confirmDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(foregroundColor: Colors.black),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteProduct(productId);
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(Strings.ok, style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map product) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              product['image_url'] != null && product['image_url'].isNotEmpty
                  ? "http://${widget.serverIP}/project/${product['image_url']}"
                  : "https://via.placeholder.com/150",
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? Strings.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['description'] ?? Strings.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${product['price'] ?? '0.00'}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black54),
                          onPressed: () async {
                            final result = await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => EditProductScreen(
                                product: product,
                                serverIP: widget.serverIP,
                                shopId: widget.shopId,
                              ),
                            );
                            if (result == true) {
                              fetchProducts();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _confirmDeleteProduct(
                            int.parse(product['id'].toString()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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
        title: Text(widget.shopName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              switch (value) {
                case Strings.HomeLabel:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AdminHomeScreen(adminId: widget.adminId),
                    ),
                  );
                  break;
                case Strings.ordersLabel:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ViewOrdersScreen(adminId: widget.adminId),
                    ),
                  );
                  break;
                case Strings.profileLabel:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: Strings.HomeLabel,
                child: Row(
                  children: const [
                    Icon(Icons.home, color: Colors.black54),
                    SizedBox(width: 8),
                    Text(Strings.HomeLabel),
                  ],
                ),
              ),
              PopupMenuItem(
                value: Strings.ordersLabel,
                child: Row(
                  children: const [
                    Icon(Icons.list_alt, color: Colors.black54),
                    SizedBox(width: 8),
                    Text(Strings.ordersLabel),
                  ],
                ),
              ),
              PopupMenuItem(
                value: Strings.profileLabel,
                child: Row(
                  children: const [
                    Icon(Icons.person, color: Colors.black54),
                    SizedBox(width: 8),
                    Text(Strings.profileLabel),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? const Center(child: Text(Strings.noProduct))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.9,
                ),
                itemCount: products.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddProductScreen(
                              shopId: widget.shopId,
                              serverIP: widget.serverIP,
                            ),
                          ),
                        );
                        if (result == true) fetchProducts();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFF408000),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade100.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.green,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Icon(
                                  Icons.add,
                                  size: 36,
                                  color: Color(0xFF408000),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              Strings.addnewProduct,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF408000),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return _buildProductCard(products[index - 1]);
                  }
                },
              ),
            ),
    );
  }
}
