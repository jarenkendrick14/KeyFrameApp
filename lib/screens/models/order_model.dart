class Order {
  final int orderId;
  final String orderNumber;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String orderStatus;
  final String createdAt;

  Order({
    required this.orderId,
    required this.orderNumber,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    this.orderStatus = 'CONFIRMED',
    this.createdAt = '',
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'] is int ? json['order_id'] : int.parse(json['order_id'].toString()),
      orderNumber: json['order_number'] ?? '',
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
      taxAmount: double.tryParse(json['tax_amount'].toString()) ?? 0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0,
      orderStatus: json['order_status'] ?? 'CONFIRMED',
      createdAt: json['created_at'] ?? '',
    );
  }
}
