import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'cart_item.dart';
import '../strings.dart';

class CartItemDetailSheet extends StatefulWidget {
  final CartItem item;

  const CartItemDetailSheet({super.key, required this.item});

  @override
  State<CartItemDetailSheet> createState() => _CartItemDetailSheetState();
}

class _CartItemDetailSheetState extends State<CartItemDetailSheet> {
  late TextEditingController notesController;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController(text: widget.item.notes ?? '');
    quantity = widget.item.quantity;
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
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'http://localhost/project/${widget.item.imageUrl}',
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.item.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.description ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${Strings.priceLabel}${widget.item.price} ₪',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (quantity > 1) setState(() => quantity--);
                  },
                ),
                Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => quantity++),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: Strings.notesLabel,
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF408000),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                final cartItem = CartItem(
                  id: widget.item.id,
                  name: widget.item.name,
                  description: widget.item.description ?? '',
                  price: widget.item.price,
                  imageUrl: widget.item.imageUrl,
                  shopName: widget.item.shopName,
                  shopId: widget.item.shopId,
                  quantity: quantity,
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                  workingHours: widget.item.workingHours,
                );

                cartProvider.addItem(cartItem);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.item.name}${Strings.addedToCart}'),
                  ),
                );
              },
              label: const Text(
                Strings.addToCart,
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
