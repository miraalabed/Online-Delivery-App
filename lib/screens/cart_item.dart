class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String shopName;
  int quantity;
  String? notes;
  String? description;
  bool liked;
  final String workingHours;
  final int shopId;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.shopName,
    this.quantity = 1,
    this.notes,
    this.description,
    this.liked = false,
    required this.workingHours,
    required this.shopId,
  });
}
