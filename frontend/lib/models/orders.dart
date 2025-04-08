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
  final String orderId;
  final String userId;
  final List<ProductDetails> products;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final ShippingAddress shippingAddress;
  final int subtotal;
  final int tax;
  final int total;
  final String orderedDate;
  //final String deliveryDate;

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
    required this.orderedDate,
    required this.orderId,
    //required this.deliveryDate,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      userId: json['userId'],
      //need to create it in the backend.
      orderId: "ORDID987654",
      products:
          (json['products'] as List)
              .map((product) => ProductDetails.fromJson(product))
              .toList(),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      orderStatus: json['orderStatus'],
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress']),
      subtotal: json['subtotal'],
      tax: json['tax'],
      total: json['total'],
      orderedDate:
          DateTime.parse(
            json['createdAt'],
          ).toLocal().toIso8601String().split('T').first,
      // deliveryDate:  DateTime.parse(
      //       json['createdAt'],
      //     ).toLocal().toIso8601String().split('T').first,
    );
  }
}

class ProductDetails {
  final Product product;
  final int quantity;
  final int price;

  ProductDetails({
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      product: Product.fromJson(json['product']),
      //will recive other details of the products.
      quantity: json['quantity'],
      price: json['price'],
    );
  }
}

class Product {
  final String productName;
  final String image;

  Product({required this.productName, required this.image});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(productName: json['productName'], image: json['image']);
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
