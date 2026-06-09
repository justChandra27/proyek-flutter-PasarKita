import 'package:flutter/material.dart';

class MobileAdminDashboard extends StatefulWidget {
  const MobileAdminDashboard({super.key});

  @override
  State<MobileAdminDashboard> createState() =>
      _MobileAdminDashboardState();
}

class _MobileAdminDashboardState
    extends State<MobileAdminDashboard> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: const Color(0xffF7F8FC),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    const Icon(
                      Icons.menu,
                      color: Colors.black,
                    ),

                    const SizedBox(width: 16),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PasarKita",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Panel Admin",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Stack(
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          size: 28,
                          color: Colors.black,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration:
                                const BoxDecoration(
                              color: Colors.red,
                              shape:
                                  BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    const CircleAvatar(
                      backgroundColor:
                          Color(0xff2962FF),
                      child: Text(
                        "A",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // BANNER
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(24),
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xff2962FF),
                        Color(0xff5C8DFF),
                      ],
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo, Admin 👋",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Kelola pengguna, produk,\npesanan, transaksi dan laporan sistem.",
                        style: TextStyle(
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Ringkasan Sistem",
                  style: TextStyle(
                    color: Color(0xff111827),
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.25,
                  children: const [
                    SummaryCard(
                      title:
                          "Total Pengguna",
                      value: "1.250",
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    SummaryCard(
                      title:
                          "Total Pesanan",
                      value: "320",
                      icon:
                          Icons.shopping_bag,
                      color: Colors.green,
                    ),
                    SummaryCard(
                      title: "Pendapatan",
                      value:
                          "Rp 24,8 JT",
                      icon:
                          Icons.account_balance_wallet,
                      color:
                          Colors.deepPurple,
                    ),
                    SummaryCard(
                      title:
                          "Total Produk",
                      value: "540",
                      icon:
                          Icons.inventory_2,
                      color: Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  "Menu Cepat",
                  style: TextStyle(
                    color: Color(0xff111827),
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: .85,
                  children: const [
                    MenuCard(
                      icon: Icons.people,
                      title: "Pengguna",
                      color: Colors.blue,
                    ),
                    MenuCard(
                      icon:
                          Icons.inventory_2,
                      title: "Produk",
                      color: Colors.green,
                    ),
                    MenuCard(
                      icon:
                          Icons.shopping_bag,
                      title: "Pesanan",
                      color: Colors.orange,
                    ),
                    MenuCard(
                      icon:
                          Icons.credit_card,
                      title:
                          "Transaksi",
                      color:
                          Colors.deepPurple,
                    ),
                    MenuCard(
                      icon:
                          Icons.category,
                      title:
                          "Kategori",
                      color: Colors.amber,
                    ),
                    MenuCard(
                      icon:
                          Icons.percent,
                      title: "Promo",
                      color: Colors.pink,
                    ),
                    MenuCard(
                      icon:
                          Icons.bar_chart,
                      title:
                          "Laporan",
                      color: Colors.blue,
                    ),
                    MenuCard(
                      icon:
                          Icons.settings,
                      title:
                          "Setting",
                      color: Colors.grey,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  "Aktivitas Terbaru",
                  style: TextStyle(
                    color: Color(0xff111827),
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const ActivityTile(
                  icon: Icons.people,
                  title:
                      "User baru mendaftar",
                  subtitle:
                      "Budi Setiawan",
                  time: "2 menit",
                ),

                const ActivityTile(
                  icon:
                      Icons.inventory_2,
                  title:
                      "Produk ditambahkan",
                  subtitle:
                      "Hoodie Premium",
                  time: "15 menit",
                ),

                const ActivityTile(
                  icon:
                      Icons.shopping_bag,
                  title:
                      "Pesanan masuk",
                  subtitle:
                      "#INV-2024-0891",
                  time: "25 menit",
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        bottomNavigationBar:
            BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor:
              const Color(0xff2962FF),
          unselectedItemColor:
              Colors.grey,
          type:
              BottomNavigationBarType.fixed,
          onTap: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon:
                  Icon(Icons.inventory_2),
              label: "Produk",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: "User",
            ),
            BottomNavigationBarItem(
              icon:
                  Icon(Icons.bar_chart),
              label: "Laporan",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(icon,
              color: color, size: 30),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff6B7280),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xff111827),
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                color.withOpacity(.12),
            child:
                Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color:
                  Color(0xff111827),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const ActivityTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              const Color(0xffEEF4FF),
          child:
              Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color:
                Color(0xff111827),
            fontWeight:
                FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color:
                Color(0xff6B7280),
          ),
        ),
        trailing: Text(
          time,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}