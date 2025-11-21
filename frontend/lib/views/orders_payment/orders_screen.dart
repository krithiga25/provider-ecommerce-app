import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/providers/orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, orderProvider, child) {
        return Scaffold(
          backgroundColor: Color(0xFFF7F7F7),
          appBar: AppBar(
            backgroundColor: Color(0xFFF7F7F7),
            title: Center(
              child: Text(
                "My orders",
                style: GoogleFonts.openSans(
                  fontSize: 22,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          body:
              orderProvider.orders.isEmpty
                  ? Center(
                    child: Text(
                      "There are no orders to show!",
                      style: GoogleFonts.openSans(
                        fontSize: 22,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  : ListView.builder(
                    itemCount: orderProvider.orders.length,
                    itemBuilder: (context, orderIndex) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Order ID:",
                                        style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '#${orderProvider.orders[orderIndex].orderId}',
                                        style: GoogleFonts.openSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(
                                      DateTime.parse(
                                        orderProvider
                                            .orders[orderIndex]
                                            .orderedDate,
                                      ),
                                    ),
                                    style: GoogleFonts.openSans(
                                      fontSize: 16,
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Card(
                                            elevation: 0,
                                            color: Colors.grey.shade200,
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: Text(
                                                ' ${orderProvider.orders[orderIndex].orderStatus.toUpperCase()} ',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      orderProvider
                                                                  .orders[orderIndex]
                                                                  .orderStatus ==
                                                              'transit'
                                                          ? Colors.orangeAccent
                                                          : orderProvider
                                                                  .orders[orderIndex]
                                                                  .orderStatus ==
                                                              'delivered'
                                                          ? Colors.green
                                                          : orderProvider
                                                                  .orders[orderIndex]
                                                                  .orderStatus ==
                                                              'cancelled'
                                                          ? Colors.red
                                                          : Colors.blueAccent,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            orderProvider
                                                        .orders[orderIndex]
                                                        .orderStatus ==
                                                    "processing"
                                                ? ""
                                                : orderProvider
                                                        .orders[orderIndex]
                                                        .orderStatus ==
                                                    "transit"
                                                ? "Estimated Arrival: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(orderProvider.orders[orderIndex].deliveryDate))}"
                                                : "Delivered On: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(orderProvider.orders[orderIndex].deliveryDate))}",
                                            style: GoogleFonts.openSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -10,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Total: \u{20B9} ${orderProvider.orders[orderIndex].total}",
                                            style: GoogleFonts.openSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            '(${orderProvider.orders[orderIndex].products.length} items)',
                                            style: GoogleFonts.openSans(
                                              fontSize: 16,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 50,
                                      bottom: 40,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                          orderProvider
                                              .orders[orderIndex]
                                              .products
                                              .length,
                                      itemBuilder: (context, itemIndex) {
                                        return ListTile(
                                          contentPadding: EdgeInsets.only(
                                            top: 20,
                                            left: 16,
                                          ),
                                          leading: SizedBox(
                                            height: 70,
                                            width: 70,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  orderProvider
                                                      .orders[orderIndex]
                                                      .products[itemIndex]
                                                      .product
                                                      .image,
                                            ),
                                          ),
                                          title: Text(
                                            orderProvider
                                                .orders[orderIndex]
                                                .products[itemIndex]
                                                .product
                                                .productName,
                                            style: GoogleFonts.openSans(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Quantity: ${orderProvider.orders[orderIndex].products[itemIndex].quantity}",
                                                style: GoogleFonts.openSans(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                ' \u{20B9} ${orderProvider.orders[orderIndex].products[itemIndex].price.toString()}',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }
}
