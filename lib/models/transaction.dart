import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
    );
  }
}

class TransactionModel {
  final String id;
  final String invoiceNumber;
  final DateTime date;
  final String timeString; // Matching React's timeString
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final double paymentAmount;
  final double changeAmount;
  final String paymentMethod;
  final String cashierName;
  final String status; // 'Lunas' or 'Refund'

  TransactionModel({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.timeString,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentAmount,
    required this.changeAmount,
    required this.paymentMethod,
    required this.cashierName,
    this.status = 'Lunas',
  });

  TransactionModel copyWith({
    String? status,
  }) {
    return TransactionModel(
      id: id,
      invoiceNumber: invoiceNumber,
      date: date,
      timeString: timeString,
      items: items,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      paymentAmount: paymentAmount,
      changeAmount: changeAmount,
      paymentMethod: paymentMethod,
      cashierName: cashierName,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'date': date.toIso8601String(),
      'timeString': timeString,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'paymentAmount': paymentAmount,
      'changeAmount': changeAmount,
      'paymentMethod': paymentMethod,
      'cashierName': cashierName,
      'status': status,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      date: DateTime.parse(json['date']),
      timeString: json['timeString'] ?? '',
      items: (json['items'] as List?)
              ?.map((e) => CartItem.fromJson(e))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (json['changeAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'Tunai',
      cashierName: json['cashierName'] ?? 'Kasir 1',
      status: json['status'] ?? 'Lunas',
    );
  }
}
