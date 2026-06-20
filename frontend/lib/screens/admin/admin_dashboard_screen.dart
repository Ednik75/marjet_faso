import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user.dart';
import '../../models/boutique.dart';
import '../../models/product.dart';
import '../../models/order.dart';
import '../../models/payment.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final adminProv = context.read<AdminProvider>();
    adminProv.fetchStats();
    adminProv.fetchUsers();
    adminProv.fetchBoutiques();
    adminProv.fetchProducts();
    adminProv.fetchOrders();
    adminProv.fetchPayments();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final adminProv = context.watch<AdminProvider>();

    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Vue d\'ensemble', 'icon': Icons.dashboard, 'iconOutlined': Icons.dashboard_outlined},
      {'title': 'Boutiques', 'icon': Icons.storefront, 'iconOutlined': Icons.storefront_outlined},
      {'title': 'Utilisateurs', 'icon': Icons.people, 'iconOutlined': Icons.people_outline},
      {'title': 'Produits', 'icon': Icons.inventory_2, 'iconOutlined': Icons.inventory_2_outlined},
      {'title': 'Commandes', 'icon': Icons.receipt_long, 'iconOutlined': Icons.receipt_long_outlined},
      {'title': 'Paiements', 'icon': Icons.account_balance_wallet, 'iconOutlined': Icons.account_balance_wallet_outlined},
    ];

    final tabs = [
      const _OverviewTab(),
      const _BoutiquesTab(),
      const _UsersTab(),
      const _ProductsTab(),
      const _OrdersTab(),
      const _PaymentsTab(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: isWide
                ? null
                : IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
            title: Row(
              children: [
                const Icon(Icons.admin_panel_settings, size: 28),
                const SizedBox(width: 8),
                Text(
                  isWide ? 'Marketplace Locale - Admin Portal' : 'Marketplace Admin',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualiser les données',
                onPressed: _loadData,
              ),
              const SizedBox(width: 8),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    auth.user?.firstName ?? "Admin",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Déconnexion',
                onPressed: () {
                  auth.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
          drawer: isWide
              ? null
              : Drawer(
                  child: Column(
                    children: [
                      UserAccountsDrawerHeader(
                        accountName: Text(auth.user?.fullName ?? 'Administrateur'),
                        accountEmail: Text(auth.user?.email ?? 'admin@marketplace.local'),
                        currentAccountPicture: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: AppTheme.primaryColor, size: 40),
                        ),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: menuItems.length,
                          itemBuilder: (context, idx) {
                            final item = menuItems[idx];
                            final isSelected = _selectedIndex == idx;
                            return ListTile(
                              leading: Icon(
                                isSelected ? item['icon'] : item['iconOutlined'],
                                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                              ),
                              title: Text(
                                item['title'],
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                                ),
                              ),
                              selected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedIndex = idx;
                                });
                                Navigator.pop(context); // Close drawer
                              },
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.logout, color: AppTheme.error),
                        title: const Text('Déconnexion', style: TextStyle(color: AppTheme.error)),
                        onTap: () {
                          auth.logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
          body: isWide
              ? Row(
                  children: [
                    // Sidebar
                    Container(
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(right: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: menuItems.length,
                              itemBuilder: (context, idx) {
                                final item = menuItems[idx];
                                final isSelected = _selectedIndex == idx;
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.08) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      isSelected ? item['icon'] : item['iconOutlined'],
                                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                                    ),
                                    title: Text(
                                      item['title'],
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = idx;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.logout, color: AppTheme.error),
                            title: const Text('Déconnexion', style: TextStyle(color: AppTheme.error)),
                            onTap: () {
                              auth.logout();
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    // Main content
                    Expanded(
                      child: adminProv.isLoading && adminProv.stats.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : tabs[_selectedIndex],
                    ),
                  ],
                )
              : (adminProv.isLoading && adminProv.stats.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : tabs[_selectedIndex]),
        );
      },
    );
  }
}

// ----------------------------------------------------
// 0. OVERVIEW TAB
// ----------------------------------------------------
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final stats = adminProv.stats;

    if (stats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalUsers = stats['total_users'] ?? 0;
    final clients = stats['clients'] ?? 0;
    final merchants = stats['merchants'] ?? 0;
    final totalBoutiques = stats['total_boutiques'] ?? 0;
    final pendingBoutiques = stats['pending_boutiques'] ?? 0;
    final approvedBoutiques = stats['approved_boutiques'] ?? 0;
    final totalProducts = stats['total_products'] ?? 0;
    final totalOrders = stats['total_orders'] ?? 0;
    final totalRevenue = stats['total_revenue'] ?? 0.0;

    return RefreshIndicator(
      onRefresh: () async {
        await adminProv.fetchStats();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vue d\'ensemble de la plateforme',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 20),

            // Responsive grid of stats
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final int crossAxisCount = width > 1000 ? 4 : (width > 600 ? 2 : 1);
                final double childAspectRatio = width > 1000 ? 1.4 : 1.6;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _OverviewStatCard(
                      title: 'Utilisateurs',
                      value: '$totalUsers',
                      subtitle: '$merchants Commerçants | $clients Clients',
                      icon: Icons.people,
                      color: Colors.blue.shade700,
                    ),
                    _OverviewStatCard(
                      title: 'Boutiques',
                      value: '$totalBoutiques',
                      subtitle: '$pendingBoutiques en attente | $approvedBoutiques actives',
                      icon: Icons.storefront,
                      color: Colors.amber.shade800,
                    ),
                    _OverviewStatCard(
                      title: 'Produits',
                      value: '$totalProducts',
                      subtitle: 'Articles en vente',
                      icon: Icons.inventory_2,
                      color: Colors.purple.shade700,
                    ),
                    _OverviewStatCard(
                      title: 'Volume d\'Affaires',
                      value: '${totalRevenue.toStringAsFixed(0)} F',
                      subtitle: '$totalOrders Commandes au total',
                      icon: Icons.monetization_on,
                      color: Colors.green.shade700,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent validations column
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Boutiques en attente d\'approbation',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (pendingBoutiques > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.warning.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$pendingBoutiques action(s)',
                                style: const TextStyle(
                                  color: AppTheme.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _PendingBoutiquesList(),
                    ],
                  ),
                ),

                // Spacer on wide screen
                const SizedBox(width: 24),

                // Recent orders column
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Commandes récentes',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _RecentOrdersWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _OverviewStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.05), color.withValues(alpha: 0.12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                ),
                Icon(icon, color: color, size: 28),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingBoutiquesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final List<Boutique> pendingList = adminProv.boutiques.where((b) => b.status == 'pending').toList();

    if (pendingList.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade300, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Toutes les boutiques ont été examinées !',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: pendingList.map((Boutique boutique) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  radius: 26,
                  child: const Icon(Icons.store, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        boutique.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text('Propriétaire: ${boutique.ownerName}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      Text('Adresse: ${boutique.address}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approuver', style: TextStyle(fontSize: 12)),
                      onPressed: () async {
                        final ok = await adminProv.approveBoutique(boutique.id);
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Boutique "${boutique.name}" approuvée.')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Rejeter', style: TextStyle(fontSize: 12)),
                      onPressed: () async {
                        final ok = await adminProv.rejectBoutique(boutique.id);
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Boutique "${boutique.name}" rejetée.')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RecentOrdersWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final List<Order> recent = adminProv.recentOrders;

    if (recent.isEmpty) {
      return Card(
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'Aucune commande',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recent.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (context, idx) {
          final Order order = recent[idx];
          Color statusColor;
          switch (order.status) {
            case 'delivered':
              statusColor = Colors.green;
              break;
            case 'pending':
              statusColor = Colors.orange;
              break;
            case 'cancelled':
              statusColor = Colors.red;
              break;
            default:
              statusColor = Colors.blue;
          }

          return ListTile(
            title: Text(
              'Commande #${order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('De ${order.clientName}\nBoutique: ${order.boutiqueName}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order.totalFormatted,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.statusDisplay,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------
// 1. BOUTIQUES TAB
// ----------------------------------------------------
class _BoutiquesTab extends StatefulWidget {
  const _BoutiquesTab();

  @override
  State<_BoutiquesTab> createState() => _BoutiquesTabState();
}

class _BoutiquesTabState extends State<_BoutiquesTab> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final query = _searchController.text.toLowerCase();

    List<Boutique> list = adminProv.boutiques;
    if (_selectedStatus != 'all') {
      list = list.where((b) => b.status == _selectedStatus).toList();
    }
    if (query.isNotEmpty) {
      list = list.where((b) => b.name.toLowerCase().contains(query) || b.ownerName.toLowerCase().contains(query) || b.category.toLowerCase().contains(query)).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestion des Boutiques',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                '${list.length} boutique(s) trouvée(s)',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Rechercher une boutique par nom, propriétaire ou catégorie...',
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedStatus,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tous les statuts')),
                  DropdownMenuItem(value: 'pending', child: Text('En attente')),
                  DropdownMenuItem(value: 'approved', child: Text('Approuvées')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejetées')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedStatus = val;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Aucune boutique ne correspond aux filtres.'))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, idx) {
                      final boutique = list[idx];
                      Color statusColor = Colors.orange;
                      String statusText = 'En attente';
                      if (boutique.status == 'approved') {
                        statusColor = Colors.green;
                        statusText = 'Approuvée';
                      } else if (boutique.status == 'rejected') {
                        statusColor = Colors.red;
                        statusText = 'Rejetée';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: const Icon(Icons.store, color: AppTheme.primaryColor),
                          ),
                          title: Row(
                            children: [
                              Text(boutique.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text('Propriétaire: ${boutique.ownerName}'),
                              Text('Téléphone: ${boutique.phone} | Catégorie: ${boutique.category}'),
                              Text('Adresse: ${boutique.address}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (boutique.status != 'approved')
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  tooltip: 'Approuver',
                                  onPressed: () => adminProv.approveBoutique(boutique.id),
                                ),
                              if (boutique.status != 'rejected')
                                IconButton(
                                  icon: const Icon(Icons.block, color: Colors.orange),
                                  tooltip: 'Rejeter',
                                  onPressed: () => adminProv.rejectBoutique(boutique.id),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Supprimer',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmer la suppression'),
                                      content: Text('Voulez-vous vraiment supprimer définitivement la boutique "${boutique.name}" ? Tous ses produits associés seront supprimés.'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Annuler'),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        TextButton(
                                          child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await adminProv.deleteBoutique(boutique.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// 2. USERS TAB
// ----------------------------------------------------
class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final _searchController = TextEditingController();
  String _selectedRole = 'all';

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final query = _searchController.text.toLowerCase();

    List<User> list = adminProv.users;
    if (_selectedRole != 'all') {
      list = list.where((u) => u.role == _selectedRole).toList();
    }
    if (query.isNotEmpty) {
      list = list.where((u) => u.username.toLowerCase().contains(query) || u.email.toLowerCase().contains(query) || u.fullName.toLowerCase().contains(query)).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestion des Utilisateurs',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                '${list.length} utilisateur(s) trouvé(s)',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Rechercher un utilisateur par nom, pseudo ou email...',
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tous les rôles')),
                  DropdownMenuItem(value: 'client', child: Text('Clients')),
                  DropdownMenuItem(value: 'merchant', child: Text('Commerçants')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrateurs')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedRole = val;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Aucun utilisateur trouvé.'))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, idx) {
                      final user = list[idx];
                      Color roleColor = Colors.blue;
                      String roleDisplay = 'Client';
                      if (user.role == 'merchant') {
                        roleColor = Colors.orange;
                        roleDisplay = 'Commerçant';
                      } else if (user.role == 'admin') {
                        roleColor = Colors.green;
                        roleDisplay = 'Administrateur';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Row(
                            children: [
                              Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text('(@${user.username})', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: roleColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  roleDisplay,
                                  style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text('Email: ${user.email.isEmpty ? "Non renseigné" : user.email}'),
                              Text('Téléphone: ${user.phone.isEmpty ? "Non renseigné" : user.phone}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButton<String>(
                                underline: const SizedBox.shrink(),
                                icon: const Icon(Icons.edit_note, color: Colors.blue),
                                hint: const Text('Changer de rôle'),
                                items: const [
                                  DropdownMenuItem(value: 'client', child: Text('Client')),
                                  DropdownMenuItem(value: 'merchant', child: Text('Commerçant')),
                                  DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
                                ],
                                onChanged: (val) async {
                                  if (val != null) {
                                    final ok = await adminProv.updateUserRole(user.id, val);
                                    if (ok && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Rôle de ${user.username} changé en $val.')),
                                      );
                                    }
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Supprimer',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmer la suppression'),
                                      content: Text('Voulez-vous vraiment supprimer l\'utilisateur "${user.username}" ? Cette action est irréversible et supprimera toutes ses données.'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Annuler'),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        TextButton(
                                          child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await adminProv.deleteUser(user.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// 3. PRODUCTS TAB
// ----------------------------------------------------
class _ProductsTab extends StatefulWidget {
  const _ProductsTab();

  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final query = _searchController.text.toLowerCase();

    List<Product> list = adminProv.products;
    if (_selectedCategory != 'all') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (query.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(query) || p.description.toLowerCase().contains(query) || p.boutiqueName.toLowerCase().contains(query)).toList();
    }

    final categories = adminProv.products.map((p) => p.category).toSet().toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestion des Produits',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                '${list.length} produit(s) trouvé(s)',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Rechercher un produit...',
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedCategory,
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('Toutes les catégories')),
                  ...categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Aucun produit trouvé.'))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, idx) {
                      final product = list[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple.shade50,
                            child: const Icon(Icons.shopping_bag, color: Colors.purple),
                          ),
                          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Boutique: ${product.boutiqueName} | Catégorie: ${product.category}'),
                              Text('Prix: ${product.priceFormatted} | Stock: ${product.stockQuantity ?? "N/A"}'),
                              if (product.description.isNotEmpty)
                                Text('Description: ${product.description}', maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: product.isAvailable ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.isAvailable ? 'Disponible' : 'Indisponible',
                                  style: TextStyle(
                                    color: product.isAvailable ? Colors.green : Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Supprimer',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmer la suppression'),
                                      content: Text('Voulez-vous vraiment supprimer le produit "${product.name}" ?'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Annuler'),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        TextButton(
                                          child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await adminProv.deleteProduct(product.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// 4. ORDERS TAB
// ----------------------------------------------------
class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();

    List<Order> list = adminProv.orders;
    if (_selectedStatus != 'all') {
      list = list.where((o) => o.status == _selectedStatus).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestion des Commandes',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                '${list.length} commande(s)',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Filtrer par statut: ', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedStatus,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tous les statuts')),
                  DropdownMenuItem(value: 'pending', child: Text('En attente')),
                  DropdownMenuItem(value: 'confirmed', child: Text('Confirmée')),
                  DropdownMenuItem(value: 'preparing', child: Text('En préparation')),
                  DropdownMenuItem(value: 'ready', child: Text('Prête')),
                  DropdownMenuItem(value: 'delivered', child: Text('Livrée')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Annulée')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedStatus = val;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Aucune commande trouvée.'))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, idx) {
                      final Order order = list[idx];
                      Color statusColor;
                      switch (order.status) {
                        case 'delivered':
                          statusColor = Colors.green;
                          break;
                        case 'pending':
                          statusColor = Colors.orange;
                          break;
                        case 'cancelled':
                          statusColor = Colors.red;
                          break;
                        default:
                          statusColor = Colors.blue;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            child: Text('#${order.id}'),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Client: ${order.clientName}'),
                              Text(order.totalFormatted, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Text('Boutique: ${order.boutiqueName} | Statut: '),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  order.statusDisplay,
                                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const Text('Détails des articles :', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  ...order.items.map((item) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${item.productName} (x${item.quantity})'),
                                            Text('${item.subtotal.toStringAsFixed(0)} F'),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 12),
                                  Text('Adresse de livraison : ${order.deliveryAddress.isEmpty ? "Non renseignée" : order.deliveryAddress}'),
                                  if (order.notes.isNotEmpty) Text('Notes : ${order.notes}'),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Modifier le statut :', style: TextStyle(fontWeight: FontWeight.bold)),
                                      DropdownButton<String>(
                                        value: order.status,
                                        items: const [
                                          DropdownMenuItem(value: 'pending', child: Text('En attente')),
                                          DropdownMenuItem(value: 'confirmed', child: Text('Confirmée')),
                                          DropdownMenuItem(value: 'preparing', child: Text('En préparation')),
                                          DropdownMenuItem(value: 'ready', child: Text('Prête')),
                                          DropdownMenuItem(value: 'delivered', child: Text('Livrée')),
                                          DropdownMenuItem(value: 'cancelled', child: Text('Annulée')),
                                        ],
                                        onChanged: (val) async {
                                          if (val != null) {
                                            final ok = await adminProv.updateOrderStatus(order.id, val);
                                            if (ok && context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Statut de la commande #${order.id} mis à jour.')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// 5. PAYMENTS TAB
// ----------------------------------------------------
class _PaymentsTab extends StatefulWidget {
  const _PaymentsTab();

  @override
  State<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<_PaymentsTab> {
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();

    List<Payment> list = adminProv.payments;
    if (_selectedStatus != 'all') {
      list = list.where((p) => p.status == _selectedStatus).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Suivi des Paiements',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                '${list.length} paiement(s)',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Filtrer par statut: ', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedStatus,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tous les statuts')),
                  DropdownMenuItem(value: 'pending', child: Text('En attente')),
                  DropdownMenuItem(value: 'completed', child: Text('Complétés')),
                  DropdownMenuItem(value: 'failed', child: Text('Échoués')),
                  DropdownMenuItem(value: 'refunded', child: Text('Remboursés')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedStatus = val;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Aucun paiement trouvé.'))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, idx) {
                      final payment = list[idx];
                      Color statusColor;
                      switch (payment.status) {
                        case 'completed':
                          statusColor = Colors.green;
                          break;
                        case 'pending':
                          statusColor = Colors.orange;
                          break;
                        case 'failed':
                          statusColor = Colors.red;
                          break;
                        default:
                          statusColor = Colors.grey;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade50,
                            child: const Icon(Icons.account_balance_wallet, color: Colors.green),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Paiement pour Commande #${payment.orderId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(payment.amountFormatted, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text('Méthode : ${payment.methodDisplay}'),
                              if (payment.transactionId != null && payment.transactionId!.isNotEmpty)
                                Text('ID de Transaction : ${payment.transactionId}'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text('Statut : '),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      payment.statusDisplay,
                                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: DropdownButton<String>(
                            underline: const SizedBox.shrink(),
                            icon: const Icon(Icons.edit_note, color: Colors.blue),
                            hint: const Text('Changer statut'),
                            items: const [
                              DropdownMenuItem(value: 'pending', child: Text('En attente')),
                              DropdownMenuItem(value: 'completed', child: Text('Complété')),
                              DropdownMenuItem(value: 'failed', child: Text('Échoué')),
                              DropdownMenuItem(value: 'refunded', child: Text('Remboursé')),
                            ],
                            onChanged: (val) async {
                              if (val != null) {
                                final ok = await adminProv.updatePaymentStatus(payment.id, val);
                                if (ok && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Statut du paiement #${payment.id} mis à jour en $val.')),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
