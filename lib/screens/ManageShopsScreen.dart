import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ShopProductsScreen .dart';
import 'AddShopScreen.dart';
import 'edit_shop_sheet.dart';
import '../strings.dart';

class ManageShopsScreen extends StatefulWidget {
  final int adminId;
  const ManageShopsScreen({super.key, required this.adminId});

  @override
  State<ManageShopsScreen> createState() => _ManageShopsScreenState();
}

class _ManageShopsScreenState extends State<ManageShopsScreen> {
  List shops = [];
  bool isLoading = true;

  final String serverIP = "localhost";

  @override
  void initState() {
    super.initState();
    fetchShops();
  }

  Future<void> fetchShops() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse(
          "http://$serverIP/project/get_admin_shops.php?admin_id=${widget.adminId}",
        ),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          shops = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint("Error: status code ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching shops: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteShop(int shopId) async {
    try {
      final res = await http.post(
        Uri.parse("http://$serverIP/project/delete_shop.php"),
        body: {'shop_id': shopId.toString()},
      );
      if (res.statusCode == 200) {
        final response = json.decode(res.body);
        if (response['success'] == true) {
          setState(() {
            shops.removeWhere(
              (shop) => shop['id'].toString() == shopId.toString(),
            );
          });
        }
      }
    } catch (e) {
      debugPrint("Error deleting shop: $e");
    }
  }

  Future<void> _confirmDelete(int shopId, String shopName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(Strings.deleteConfirmationTitle),
        content: Text(
          Strings.deleteConfirmationContent.replaceAll("{shopName}", shopName),
        ),
        actions: [
          TextButton(
            child: Text(
              Strings.cancel,
              style: const TextStyle(color: Colors.black),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text(Strings.ok, style: const TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true) {
      await deleteShop(shopId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Strings.shopDeletedMessage.replaceAll("{shopName}", shopName),
          ),
        ),
      );
    }
  }

  Widget _buildShopCard(Map shop) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopProductsScreen(
              shopId: int.parse(shop['id'].toString()),
              shopName: shop['name'] ?? "Shop",
              serverIP: serverIP,
              adminId: widget.adminId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFF408000).withOpacity(0.1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Image.network(
                shop['image_url'] != null &&
                        shop['image_url'].toString().isNotEmpty
                    ? "http://$serverIP/project/${shop['image_url']}"
                    : Strings.placeholderImage,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            shop['name'] ?? "Shop Name",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
          ),
          subtitle: Text(
            shop['location'] ?? "Location",
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () async {
                  final changed = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: EditShopSheet(
                        shop: shop,
                        serverIP: serverIP,
                        adminId: widget.adminId,
                      ),
                    ),
                  );
                  if (changed == true) fetchShops();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _confirmDelete(
                  int.parse(shop['id'].toString()),
                  shop['name'] ?? "Shop",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddShopCard() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AddShopScreenWeb(adminId: widget.adminId, serverIP: serverIP),
          ),
        );
        if (result == true) fetchShops();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.green.shade400, width: 2),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF408000).withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 30, color: Color(0xFF408000)),
            const SizedBox(height: 8),
            Text(
              Strings.addNewShop,
              style: const TextStyle(
                color: Color(0xFF408000),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          Strings.manageShopsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16, top: 16),
              itemCount: shops.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildAddShopCard();
                return _buildShopCard(shops[index - 1]);
              },
            ),
    );
  }
}
