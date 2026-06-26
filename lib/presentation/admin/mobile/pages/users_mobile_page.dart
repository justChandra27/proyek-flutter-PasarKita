import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_service.dart';

import 'user_detail_mobile_page.dart';

class _UserItem {
  final String id;
  final Map<String, dynamic> data;
  final String createdAt;

  _UserItem({
    required this.id,
    required this.data,
    required this.createdAt,
  });

  String get name => data['name'] as String? ?? '';
  String get username => data['username'] as String? ?? '';
  String get email => data['email'] as String? ?? '';
  String get role => data['role'] as String? ?? 'customer';
  String get status => data['status'] as String? ?? 'active';
  String get storeName => data['storeName'] as String? ?? '';
}

class UsersMobilePage extends StatefulWidget {
  const UsersMobilePage({super.key});

  @override
  State<UsersMobilePage> createState() => _UsersMobilePageState();
}

class _UsersMobilePageState extends State<UsersMobilePage> {
  final Databases _db = AppwriteService.databases;
  final TextEditingController _searchController = TextEditingController();

  List<_UserItem> _allUsers = [];
  List<_UserItem> _filteredUsers = [];
  bool _loading = true;
  String? _error;
  String _selectedRole = 'Semua';
  String _selectedStatus = 'Semua';

  static const _roleOptions = [
    'Semua',
    'Customer',
    'Seller',
    'Admin',
  ];

  static const _statusOptions = [
    'Semua',
    'Aktif',
    'Nonaktif',
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [
          Query.orderDesc('\$createdAt'),
          Query.limit(200),
        ],
      );

      final users = result.documents.map((doc) {
        return _UserItem(
          id: doc.$id,
          data: Map<String, dynamic>.from(doc.data),
          createdAt: doc.$createdAt,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _allUsers = users;
        _loading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredUsers = _allUsers.where((u) {
        if (_selectedRole != 'Semua') {
          if (u.role.toLowerCase() != _selectedRole.toLowerCase()) {
            return false;
          }
        }
        if (_selectedStatus == 'Aktif' && u.status != 'active') return false;
        if (_selectedStatus == 'Nonaktif' && u.status == 'active') return false;
        if (query.isNotEmpty) {
          final name = u.name.toLowerCase();
          final username = u.username.toLowerCase();
          final email = u.email.toLowerCase();
          final store = u.storeName.toLowerCase();
          if (!name.contains(query) &&
              !username.contains(query) &&
              !email.contains(query) &&
              !store.contains(query)) {
            return false;
          }
        }
        return true;
      }).toList();
    });
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'seller':
        return Colors.green;
      case 'customer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _roleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'seller':
        return 'Seller';
      case 'customer':
        return 'Customer';
      default:
        return role;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
      case 'pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Nonaktif';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data:\n$_error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 12),
        _buildStatCards(),
        const SizedBox(height: 12),
        _buildRoleFilterChips(),
        const SizedBox(height: 8),
        _buildStatusFilterChips(),
        const SizedBox(height: 12),
        Expanded(
          child: _filteredUsers.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(_filteredUsers[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    final total = _allUsers.length;
    final active = _allUsers.where((u) => u.status == 'active').length;
    final pending = _allUsers.where((u) => u.status == 'pending').length;
    final inactive = _allUsers.where((u) => u.status == 'inactive').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Total Pengguna',
                  total.toString(),
                  Icons.people_alt_outlined,
                  const Color(0xff2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Pengguna Aktif',
                  active.toString(),
                  Icons.person_add_alt,
                  const Color(0xff22C55E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Pending',
                  pending.toString(),
                  Icons.hourglass_empty,
                  const Color(0xffEAB308),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Ditangguhkan',
                  inactive.toString(),
                  Icons.person_off_outlined,
                  const Color(0xffEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari nama, username, email, toko...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xffE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xffE5E7EB)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _roleOptions.map((filter) {
          final selected = _selectedRole == filter;
          final chipColor = switch (filter) {
            'Customer' => Colors.blue,
            'Seller' => Colors.green,
            'Admin' => Colors.purple,
            _ => const Color(0xff2563EB),
          };
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedRole = filter);
                _applyFilters();
              },
              selectedColor: chipColor,
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xff374151),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: selected ? chipColor : const Color(0xffE5E7EB),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _statusOptions.map((filter) {
          final selected = _selectedStatus == filter;
          final chipColor = switch (filter) {
            'Aktif' => Colors.green,
            'Nonaktif' => Colors.red,
            _ => const Color(0xff2563EB),
          };
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedStatus = filter);
                _applyFilters();
              },
              selectedColor: chipColor,
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xff374151),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: selected ? chipColor : const Color(0xffE5E7EB),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserCard(_UserItem user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserDetailMobilePage(
                userId: user.id,
                userData: user.data,
              ),
            ),
          ).then((_) => _loadUsers());
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: _roleColor(user.role).withValues(alpha: 0.2),
              child: Text(
                _getInitials(user.name),
                style: TextStyle(
                  color: _roleColor(user.role),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xff111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _roleColor(user.role).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _roleLabel(user.role),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _roleColor(user.role),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(user.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusLabel(user.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(user.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xff9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Belum ada pengguna',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada pengguna yang ditemukan.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
