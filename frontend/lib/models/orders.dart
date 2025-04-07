// class Orders {
//   final String status;
//   final String message;
//   final OrderDetails orderDetails;

//   Orders({
//     required this.status,
//     required this.message,
//     required this.orderDetails,
//   });

//   factory Orders.fromJson(Map<String, dynamic> json) {
//     return Orders(
//       status: json['status'],
//       message: json['message'],
//       orderDetails: OrderDetails.fromJson(json['orderDetails']),
//     );
//   }
// }

class OrderDetails {
  final String userId;
  final List<Product> products;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final ShippingAddress shippingAddress;
  final int subtotal;
  final int tax;
  final int total;

  OrderDetails({
    required this.userId,
    required this.products,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.shippingAddress,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      userId: json['userId'],
      products:
          (json['products'] as List)
              .map((product) => Product.fromJson(product))
              .toList(),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      orderStatus: json['orderStatus'],
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress']),
      subtotal: json['subtotal'],
      tax: json['tax'],
      total: json['total'],
    );
  }
}

class Product {
  final String product;
  final int quantity;
  final int price;

  Product({required this.product, required this.quantity, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      product: json['product'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }
}

class ShippingAddress {
  final String name;
  final String address;
  final String city;
  final String state;
  final String zip;
  final String country;

  ShippingAddress({
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      name: json['name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      country: json['country'],
    );
  }
}
