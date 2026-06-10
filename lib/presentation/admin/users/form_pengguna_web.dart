// lib/presentation/admin/users/form_pengguna_web.dart

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';
import '../../../data/models/user_model.dart';

class FormPenggunaWeb extends StatefulWidget {
  const FormPenggunaWeb({super.key});

  @override
  State<FormPenggunaWeb> createState() => _FormPenggunaWebState();
}

class _FormPenggunaWebState extends State<FormPenggunaWeb> {
  final Databases databases = AppwriteService.databases;

  List<UserModel> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> showEditDialog(UserModel user) async {
    final nameController = TextEditingController(text: user.name);

    final roleController = TextEditingController(text: user.role);

    final statusController = TextEditingController(text: user.status);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Pengguna'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: 'Role'),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: statusController,
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await databases.updateDocument(
                  databaseId: AppwriteConfig.databaseId,
                  collectionId: AppwriteConfig.usersCollectionId,
                  documentId: user.documentId,
                  data: {
                    'name': nameController.text,
                    'role': roleController.text,
                    'status': statusController.text,
                  },
                );

                if (!mounted) return;

                Navigator.pop(context);

                await loadUsers();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteUser(UserModel user) async {
    try {
      await databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: user.documentId,
      );

      await loadUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna berhasil dihapus')),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> confirmDelete(UserModel user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Pengguna'),
          content: Text('Yakin ingin menghapus ${user.name} ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await deleteUser(user);
    }
  }

  Future<void> loadUsers() async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
      );

      users = result.documents
          .map((doc) => UserModel.fromMap(doc.data, doc.$id))
          .toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error load users: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeUsers = users.where((u) {
      return u.status.toLowerCase() == 'active' ||
          u.status.toLowerCase() == 'aktif';
    }).length;

    final suspendedUsers = users.where((u) {
      return u.status.toLowerCase() == 'suspended' ||
          u.status.toLowerCase() == 'ditangguhkan';
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Kelola Pengguna",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari data...",
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
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Total Pengguna",
                    users.length.toString(),
                    Icons.people_alt_outlined,
                    const Color(0xff2563EB),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    "Pengguna Aktif",
                    activeUsers.toString(),
                    Icons.person_add_alt,
                    const Color(0xff22C55E),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    "Pending",
                    users
                        .where((u) => u.status.toLowerCase() == 'pending')
                        .length
                        .toString(),
                    Icons.hourglass_empty,
                    const Color(0xffEAB308),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    "Ditangguhkan",
                    suspendedUsers.toString(),
                    Icons.person_off_outlined,
                    const Color(0xffEF4444),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Daftar Pengguna",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        "Kelola dan tinjau hak akses pengguna platform Anda.",
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.filter_list),
                                  label: const Text("Filter"),
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 1),

                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  child: SizedBox(
                                    width: constraints.maxWidth,
                                    child: DataTable(
                                      columnSpacing: 120,
                                      horizontalMargin: 24,
                                      headingRowHeight: 60,
                                      dataRowMinHeight: 72,
                                      dataRowMaxHeight: 72,

                                      headingRowColor: WidgetStateProperty.all(
                                        const Color(0xffF9FAFB),
                                      ),

                                      columns: const [
                                        DataColumn(
                                          label: Text(
                                            "NAMA",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            "EMAIL",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            "ROLE",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            "STATUS",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            "AKSI",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],

                                      rows: users.map((user) {
                                        return _userRow(user);
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
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

  Widget _statCard(String title, String value, IconData icon, Color color) {
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
<<<<<<< HEAD
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color, size: 24),
=======
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color),
>>>>>>> eabe87012266b1c56deb36bb6f629a0c2fc752c7
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 4),

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

  DataRow _userRow(UserModel user) {
    final statusColor = _statusColor(user.status);

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    Colors.blue.withValues(alpha: .2),
                child: Text(
                  user.name.isNotEmpty
                      ? user.name
                            .substring(0, user.name.length >= 2 ? 2 : 1)
                            .toUpperCase()
                      : "?",
                  style: const TextStyle(color: Colors.blue),
                ),
              ),

              const SizedBox(width: 10),

              Text(user.name),
            ],
          ),
        ),

        DataCell(Text(user.email)),

        DataCell(Text(user.role)),

        DataCell(Text(user.status, style: TextStyle(color: statusColor))),

        DataCell(
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  tooltip: 'Edit',
                  onPressed: () {
                    showEditDialog(user);
                  },
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                ),
              ),

              const SizedBox(width: 8),

              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  tooltip: 'Hapus',
                  onPressed: () {
                    confirmDelete(user);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'aktif':
        return Colors.green;

      case 'pending':
        return Colors.orange;

      case 'suspended':
      case 'ditangguhkan':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}
