// import 'package:flutter/material.dart';

// import '../../widgets/admin_layout.dart';
// import '../widgets/stat_card.dart';

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: ThemeData.light().copyWith(
//         scaffoldBackgroundColor: const Color(0xffF6F8FC),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xff2962FF),
//           brightness: Brightness.light,
//         ),
//       ),
//       child: AdminLayout(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,
//             children: [
//               // HEADER
//               Row(
//                 children: [
//                   const Expanded(
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Selamat datang, Admin 👋",
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight:
//                                 FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                         SizedBox(height: 6),
//                         Text(
//                           "Berikut ringkasan singkat data pada sistem.",
//                           style: TextStyle(
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(
//                     width: 300,
//                     child: TextField(
//                       decoration: InputDecoration(
//                         hintText: "Cari sesuatu...",
//                         prefixIcon:
//                             const Icon(Icons.search),
//                         filled: true,
//                         fillColor: Colors.white,

//                         border: OutlineInputBorder(
//                           borderRadius:
//                               BorderRadius.circular(
//                                   14),
//                           borderSide:
//                               BorderSide.none,
//                         ),

//                         enabledBorder:
//                             OutlineInputBorder(
//                           borderRadius:
//                               BorderRadius.circular(
//                                   14),
//                           borderSide:
//                               BorderSide.none,
//                         ),

//                         focusedBorder:
//                             OutlineInputBorder(
//                           borderRadius:
//                               BorderRadius.circular(
//                                   14),
//                           borderSide:
//                               BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 30),

//               // CARD STATISTIK
//               GridView.count(
//                 shrinkWrap: true,
//                 physics:
//                     const NeverScrollableScrollPhysics(),
//                 crossAxisCount: 4,
//                 mainAxisSpacing: 20,
//                 crossAxisSpacing: 20,
//                 childAspectRatio: 2.5,
//                 children: const [
//                   StatCard(
//                     icon: Icons.people,
//                     title: "Total Pengguna",
//                     value: "1.250",
//                     color: Colors.blue,
//                   ),
//                   StatCard(
//                     icon: Icons.shopping_bag,
//                     title: "Total Pesanan",
//                     value: "320",
//                     color: Colors.green,
//                   ),
//                   StatCard(
//                     icon:
//                         Icons.account_balance_wallet,
//                     title: "Total Pendapatan",
//                     value: "Rp 24.850.000",
//                     color: Colors.deepPurple,
//                   ),
//                   StatCard(
//                     icon: Icons.inventory_2,
//                     title: "Total Produk",
//                     value: "540",
//                     color: Colors.orange,
//                   ),
//                 ],
//               ),

//               const Spacer(),

//               // TENGAH DASHBOARD
//               Center(
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.dashboard_customize,
//                       size: 120,
//                       color: Colors.blue.shade100,
//                     ),

//                     const SizedBox(height: 20),

//                     const Text(
//                       "Dashboard",
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight:
//                             FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     const Text(
//                       "Kelola data aplikasi dengan mudah melalui menu di samping.",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const Spacer(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }