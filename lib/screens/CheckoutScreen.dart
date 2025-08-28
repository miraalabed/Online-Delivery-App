import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'cart_item.dart';
import '../strings.dart';

class CheckoutScreen extends StatefulWidget {
  final int userId;
  final int shopId;
  final String shopName;
  final double totalPrice;
  final List<CartItem> cartItems;

  const CheckoutScreen({
    super.key,
    required this.userId,
    required this.shopId,
    required this.shopName,
    required this.totalPrice,
    required this.cartItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  String? paymentMethod;
  final locationController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    locationController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<bool> saveOrderToServer() async {
    final url = Uri.parse('http://localhost/project/save_order.php');

    final itemsData = widget.cartItems
        .map(
          (item) => {
            'menu_item_id': item.id,
            'quantity': item.quantity,
            'price': item.price,
            'notes': item.notes ?? '',
          },
        )
        .toList();

    final body = json.encode({
      'user_id': widget.userId,
      'shop_id': widget.shopId,
      'payment_method': paymentMethod ?? '',
      'location': locationController.text,
      'phone': phoneController.text,
      'total_price': widget.totalPrice,
      'items': itemsData,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  }

  void _submitOrder() async {
    if (_formKey.currentState!.validate() && paymentMethod != null) {
      bool success = await saveOrderToServer();

      if (success) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(Strings.orderConfirmed),
            content: Text(
              'Your order for ${widget.shopName} was confirmed.\n'
              'Payment method: ${_getPaymentMethodText()}\n'
              'Location: ${locationController.text}\n'
              'Phone: ${phoneController.text}',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(Strings.failedToSaveOrder)),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.fillAllFields)));
    }
  }

  String _getPaymentMethodText() {
    switch (paymentMethod) {
      case 'visa':
        return Strings.visa;
      case 'reflect':
        return Strings.reflect;
      case 'paypal':
        return Strings.paypal;
      case 'cash':
        return Strings.cashOnDelivery;
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF408000);

    return Scaffold(
      appBar: AppBar(
        title: Text('${Strings.checkoutTitle}${widget.shopName}'),
        backgroundColor: Colors.white12,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                '${Strings.totalPriceLabel}${widget.totalPrice.toStringAsFixed(2)} ₪',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                Strings.selectPaymentMethod,
                style: TextStyle(fontSize: 18),
              ),
              RadioListTile<String>(
                title: const Text(Strings.visa),
                value: 'visa',
                groupValue: paymentMethod,
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text(Strings.reflect),
                value: 'reflect',
                groupValue: paymentMethod,
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text(Strings.paypal),
                value: 'paypal',
                groupValue: paymentMethod,
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text(Strings.cashOnDelivery),
                value: 'cash',
                groupValue: paymentMethod,
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: Strings.deliveryLocation,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return Strings.pleaseEnterDeliveryLocation;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: Strings.phoneNumber,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return Strings.pleaseEnterPhoneNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _submitOrder,
                child: const Text(
                  Strings.confirmOrder,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
