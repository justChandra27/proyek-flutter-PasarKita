import 'package:flutter/material.dart';

class AdminLayout extends StatelessWidget {
  final String currentRoute;
  final Widget child;

  const AdminLayout({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          const _AdminSidebar(),
          Expanded(
            child: Column(
              children: [
                _AdminTopBar(currentRoute: currentRoute),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sidebar ─────────────────────────────────────────────────────────────────

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar();

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '';

    return Container(
      width: 220,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PasarKita',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _NavItem(
                    icon: Icons.grid_view_rounded,
                    label: 'Dashboard',
                    route: 'dashboard',
                  ),
                  _NavItem(
                    icon: Icons.people_outline,
                    label: 'Pengguna',
                    route: 'pengguna',
                  ),
                  _NavItem(
                    icon: Icons.verified_user_outlined,
                    label: 'Verifikasi',
                    route: 'verifikasi',
                  ),
                  _NavItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Produk',
                    route: 'produk',
                  ),
                  _NavItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Pesanan',
                    route: 'pesanan',
                  ),
                  _NavItem(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Transaksi',
                    route: 'transaksi',
                  ),
                  _NavItem(
                    icon: Icons.category_outlined,
                    label: 'Kategori',
                    route: 'kategori',
                  ),
                  _NavItem(
                    icon: Icons.local_offer_outlined,
                    label: 'Promo',
                    route: 'promo',
                  ),
                  _NavItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Laporan',
                    route: 'laporan',
                  ),
                ],
              ),
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            child: _NavItem(
              icon: Icons.logout_rounded,
              label: 'Keluar',
              route: 'logout',
              isDestructive: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isDestructive;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.isDestructive = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // For demo: check if active via nearest AdminLayout ancestor
    final isActive = _isActiveRoute(context, widget.route);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFEFF6FF)
              : _hovered
                  ? const Color(0xFFF8FAFC)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 20,
              color: isActive
                  ? const Color(0xFF2563EB)
                  : widget.isDestructive
                      ? const Color(0xFFEF4444)
                      : Colors.grey[500],
            ),
            const SizedBox(width: 10),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF2563EB)
                    : widget.isDestructive
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isActiveRoute(BuildContext context, String route) {
    // Walk up to find AdminLayout and compare currentRoute
    // Simple approach: use InheritedWidget or just pass it through
    return false; // override in AdminLayout using a provider or similar
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _AdminTopBar extends StatelessWidget {
  final String currentRoute;

  const _AdminTopBar({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, size: 18, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    _searchHint(currentRoute),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Admin info
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Admin Utama',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    'Super Admin',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _searchHint(String route) {
    switch (route) {
      case 'verifikasi':
        return 'Cari data verifikasi...';
      case 'transaksi':
        return 'Cari transaksi...';
      default:
        return 'Cari...';
    }
  }
}