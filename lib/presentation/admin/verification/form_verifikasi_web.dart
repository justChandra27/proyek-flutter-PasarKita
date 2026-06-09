//lib/presentation/admin/verification/form_verifikasi_web.dart

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';

class FormVerifikasiWeb extends StatefulWidget {
  const FormVerifikasiWeb({super.key});

  @override
  State<FormVerifikasiWeb> createState() => _FormVerifikasiWebState();
}

class _FormVerifikasiWebState extends State<FormVerifikasiWeb> {
  final databases = AppwriteService.databases;

  String selectedFilter = 'all';

  Stream<List<Map<String, dynamic>>> getPendingUsers() async* {
    while (true) {
      final result = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.equal('status', 'pending')],
      );

      yield result.documents.map((e) => {...e.data, '\$id': e.$id}).toList();

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> _approveUser(String uid, String name) async {
    try {
      await databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: uid,
        data: {'status': 'approved'},
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name berhasil disetujui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyetujui akun')));
    }
  }

  Future<void> _rejectUser(String uid, String name) async {
    try {
      await databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: uid,
        data: {'status': 'rejected'},
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name berhasil ditolak'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menolak akun')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Cari data verifikasi...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
                ),

                const SizedBox(width: 10),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin Utama",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Super Admin",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Verifikasi Akun",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Kelola persetujuan pendaftaran pengguna baru di platform PasarKita.",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // STATISTIC
            // STATISTIC
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: getPendingUsers(),
              builder: (context, snapshot) {
                final docs = snapshot.data ?? [];

                final sellerCount = docs
                    .where((e) => e['role'] == 'seller')
                    .length;

                final customerCount = docs
                    .where((e) => e['role'] == 'customer')
                    .length;

                return Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          setState(() {
                            selectedFilter = 'all';
                          });
                        },
                        child: _statCard(
                          icon: Icons.assignment_ind_outlined,
                          title: "Pending",
                          value: docs.length.toString(),
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          setState(() {
                            selectedFilter = 'seller';
                          });
                        },
                        child: _statCard(
                          icon: Icons.storefront_outlined,
                          title: "Seller",
                          value: sellerCount.toString(),
                          color: Colors.orange,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          setState(() {
                            selectedFilter = 'customer';
                          });
                        },
                        child: _statCard(
                          icon: Icons.person_outline,
                          title: "Customer",
                          value: customerCount.toString(),
                          color: Colors.green,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Container(
                        height: 110,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xff2563EB),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.bolt, color: Colors.white),
                            ),

                            SizedBox(width: 14),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Status",
                                  style: TextStyle(color: Colors.white70),
                                ),

                                Text(
                                  "Realtime",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // TABLE CARD
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Daftar Antrean Verifikasi",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      Expanded(
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: getPendingUsers(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text("Terjadi kesalahan"),
                              );
                            }

                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final users = snapshot.data!;

                            final filteredUsers = users.where((user) {
                              if (selectedFilter == 'all') {
                                return true;
                              }

                              return user['role'] == selectedFilter;
                            }).toList();

                            if (users.isEmpty) {
                              return const Center(
                                child: Text(
                                  "Tidak ada akun yang menunggu verifikasi",
                                ),
                              );
                            }

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth:
                                      MediaQuery.of(context).size.width - 380,
                                ),
                                child: DataTable(
                                  columnSpacing: 60,
                                  horizontalMargin: 30,
                                  headingRowHeight: 60,
                                  dataRowMinHeight: 72,
                                  dataRowMaxHeight: 72,
                                  columns: const [
                                    DataColumn(label: Text("Nama")),
                                    DataColumn(label: Text("Username")),
                                    DataColumn(label: Text("Role")),
                                    DataColumn(label: Text("Tanggal")),
                                    DataColumn(label: Text("Action")),
                                  ],
                                  rows: filteredUsers.map((doc) {
                                    return _userRow(
                                      uid: doc['\$id'],
                                      name: doc['name'] ?? '',
                                      username: doc['username'] ?? '',
                                      role: doc['role'] ?? '',
                                      createdAt: doc['\$createdAt'],
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        child: const Row(
                          children: [Text("Data verifikasi pengguna")],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _userRow({
    required String uid,
    required String name,
    required String username,
    required String role,
    String? createdAt,
  }) {
    final date = createdAt != null
        ? DateTime.parse(createdAt).toString().substring(0, 16)
        : '-';

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.withValues(alpha: .15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),

              const SizedBox(width: 10),

              Text(name),
            ],
          ),
        ),

        DataCell(Text(username)),

        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(role.toUpperCase()),
          ),
        ),

        DataCell(Text(date)),
        DataCell(
          SizedBox(
            width: 220,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2563EB),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('Konfirmasi'),
                            content: Text('Setujui akun $name ?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text('Setujui'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        await _approveUser(uid, name);
                      }
                    },
                    child: const Text(
                      "Setujui",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('Konfirmasi'),
                            content: Text('Tolak akun $name ?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text(
                                  'Tolak',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        await _rejectUser(uid, name);
                      }
                    },
                    child: const Text(
                      "Tolak",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
