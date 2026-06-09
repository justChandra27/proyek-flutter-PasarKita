import 'package:flutter/material.dart';

import '../widgets/product_form_card.dart';
import '../widgets/product_preview_card.dart';
import '../widgets/seller_sidebar.dart';

class WebSellerDashboard extends StatelessWidget {
  const WebSellerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xffF6F8FC),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FC),

        body: Row(
          children: [
            const SellerSidebar(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // HEADER
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tambah Produk",
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),

                              SizedBox(height: 8),

                              Text(
                                "Lengkapi informasi produk yang ingin Anda jual",
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // NOTIFIKASI
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications_none,
                                size: 28,
                                color: Colors.black87,
                              ),
                            ),

                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration:
                                    const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 20),

                        // PROFILE SELLER
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: const Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    Color(0xff2962FF),
                                child: Text(
                                  "A",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              SizedBox(width: 10),

                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Andi Setiawan",
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),

                                  Text(
                                    "Penjual",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(width: 10),

                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // CONTENT
                    Expanded(
                      child: SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: const [
                            Expanded(
                              flex: 2,
                              child: ProductFormCard(),
                            ),

                            SizedBox(width: 24),

                            Expanded(
                              child: ProductPreviewCard(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}