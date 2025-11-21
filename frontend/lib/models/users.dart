class Address {
  ShippingAddress shippingAddress;

  Address({required this.shippingAddress});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'shippingAddress': shippingAddress.toJson()};
  }
}

class ShippingAddress {
  String name;
  String address;
  String city;
  String state;
  String zip;
  String country;

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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
    };
  }
}
