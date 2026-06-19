import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/boutique.dart';
import '../../models/product.dart';

class BoutiqueDetailScreen extends StatefulWidget {
  final Boutique boutique;
  const BoutiqueDetailScreen({super.key, required this.boutique});

  @override
  State<BoutiqueDetailScreen> createState() => _BoutiqueDetailScreenState();
}

class _BoutiqueDetailScreenState extends State<BoutiqueDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts(
        boutiqueId: widget.boutique.id.toString(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.boutique;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(b.name),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Center(
                  child: Icon(Icons.store, size: 80, color: Colors.white30),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _InfoRow(Icons.location_on, b.address),
                          const SizedBox(height: 10),
                          _InfoRow(Icons.phone, b.phone),
                          if (b.openingHours.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _InfoRow(Icons.access_time, b.openingHours),
                          ],
                          if (b.category.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _InfoRow(Icons.category, b.category),
                          ],
                          if (b.distance != null) ...[
                            const SizedBox(height: 10),
                            _InfoRow(Icons.near_me, '${b.distance} km'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Produits',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Consumer<ProductProvider>(
            builder: (_, pp, __) {
              if (pp.isLoading) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (pp.products.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Aucun produit pour le moment',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((_, i) {
                  final p = pp.products[i];
                  return _ProductTile(product: p);
                }, childCount: pp.products.length),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2, color: AppTheme.primaryColor),
          ),
          title: Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            product.priceFormatted,
            style: const TextStyle(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            onPressed: () {
              context.read<OrderProvider>().addToCart(
                product.id,
                product.name,
                product.price,
                product.boutiqueId,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} ajouté au panier'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
