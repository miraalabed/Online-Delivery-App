import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cart_provider.dart';
import 'cart_item.dart';
import 'CheckoutScreen.dart';
import '../strings.dart';

class CartItemDetailSheet extends StatefulWidget {
  final CartItem item;

  const CartItemDetailSheet({super.key, required this.item});

  @override
  State<CartItemDetailSheet> createState() => _CartItemDetailSheetState();
}

class _CartItemDetailSheetState extends State<CartItemDetailSheet> {
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'http://localhost/project/${widget.item.imageUrl}',
              height: 180,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 15),
            Text(
              widget.item.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.item.description ?? Strings.noDescription,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '${Strings.priceLabel}${widget.item.price.toStringAsFixed(2)} ₪',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: Strings.notesLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF408000),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                cartProvider.updateNotes(widget.item.id, notesController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(Strings.itemUpdated)),
                );
              },
              child: const Text(
                Strings.updateButton,
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  bool isShopOpen(String workingHours) {
    try {
      final format = DateFormat('h:mm a');
      final now = DateTime.now();

      final parts = workingHours.split('-');
      if (parts.length != 2) return false;

      final openTimeString = parts[0].trim();
      final closeTimeString = parts[1].trim();

      final open = format.parse(openTimeString);
      final close = format.parse(closeTimeString);

      final todayOpen = DateTime(
        now.year,
        now.month,
        now.day,
        open.hour,
        open.minute,
      );
      final todayClose = DateTime(
        now.year,
        now.month,
        now.day,
        close.hour,
        close.minute,
      );

      final adjustedClose = todayClose.isBefore(todayOpen)
          ? todayClose.add(const Duration(days: 1))
          : todayClose;

      return now.isAfter(todayOpen) && now.isBefore(adjustedClose);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final shopNames = cartProvider.shopNames;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            final totalItems = cartProvider.itemCount;
            return Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: Strings.cartTitle + ' ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: '($totalItems)',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: shopNames.isEmpty
          ? const Center(child: Text(Strings.cartEmpty))
          : ListView.builder(
              itemCount: shopNames.length,
              itemBuilder: (context, shopIndex) {
                final shopName = shopNames[shopIndex];
                final shopItems = cartProvider.itemsByShop(shopName);
                final totalPrice = cartProvider.totalPriceByShop(shopName);

                final String workingHours = shopItems.isNotEmpty
                    ? shopItems.first.workingHours ?? ''
                    : '';
                final isOpen = isShopOpen(workingHours);

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
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
                        if (!isOpen)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text(
                              Strings.closedNow,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        const Divider(),
                        ...shopItems.map(
                          (item) => ListTile(
                            leading: Image.network(
                              'http://localhost/project/${item.imageUrl}',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                            title: Text(item.name),
                            subtitle: Text(
                              '${Strings.priceLabel}${item.price.toStringAsFixed(2)} ₪',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    if (item.quantity > 1) {
                                      cartProvider.updateQuantity(
                                        item.id,
                                        item.quantity - 1,
                                      );
                                    }
                                  },
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    cartProvider.updateQuantity(
                                      item.id,
                                      item.quantity + 1,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text(
                                          Strings.confirmDeleteTitle,
                                        ),
                                        content: const Text(
                                          Strings.confirmDeleteContent,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                            child: const Text(
                                              Strings.cancel,
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              cartProvider.removeItem(item.id);
                                              Navigator.of(ctx).pop();
                                            },
                                            child: const Text(
                                              Strings.deleteButton,
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) =>
                                    CartItemDetailSheet(item: item),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${Strings.totalLabel}${totalPrice.toStringAsFixed(2)} ₪',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF408000),
                              ),
                              onPressed: isOpen
                                  ? () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final userId =
                                          prefs.getInt('user_id') ?? 0;
                                      final shopId = shopItems.isNotEmpty
                                          ? shopItems.first.shopId
                                          : 0;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CheckoutScreen(
                                            userId: userId,
                                            shopId: shopId,
                                            shopName: shopName,
                                            totalPrice: totalPrice,
                                            cartItems: shopItems,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: const Text(
                                Strings.checkOutButton,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
