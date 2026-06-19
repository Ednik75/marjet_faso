import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/product.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;

  final _categories = [
    {'value': null, 'label': 'Tous', 'icon': Icons.apps},
    {
      'value': 'alimentation',
      'label': 'Alimentation',
      'icon': Icons.restaurant,
    },
    {'value': 'vetements', 'label': 'Vêtements', 'icon': Icons.checkroom},
    {
      'value': 'electronique',
      'label': 'Électronique',
      'icon': Icons.phone_android,
    },
    {'value': 'beaute', 'label': 'Beauté', 'icon': Icons.spa},
    {'value': 'maison', 'label': 'Maison', 'icon': Icons.home},
    {'value': 'sport', 'label': 'Sport', 'icon': Icons.sports_soccer},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    context.read<ProductProvider>().searchProducts(
      _searchCtrl.text.trim(),
      category: _selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche')),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor,
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _search(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white70),
                  onPressed: _search,
                ),
              ),
            ),
          ),

          // Categories
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: selected,
                    label: Text(cat['label'] as String),
                    avatar: Icon(cat['icon'] as IconData, size: 16),
                    onSelected: (_) {
                      setState(
                        () => _selectedCategory = cat['value'] as String?,
                      );
                      _search();
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                );
              },
            ),
          ),

          // Results
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (_, pp, __) {
                if (pp.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = pp.searchResults;
                if (products.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: AppTheme.textLight,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Recherchez un produit',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return _ProductResultCard(product: p);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductResultCard extends StatelessWidget {
  final Product product;
  const _ProductResultCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCatIcon(product.category),
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.boutiqueName,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: product.isAvailable
                            ? AppTheme.success.withValues(alpha: 0.1)
                            : AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.isAvailable ? 'Disponible' : 'Indisponible',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: product.isAvailable
                              ? AppTheme.success
                              : AppTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    product.priceFormatted,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCatIcon(String cat) {
    switch (cat) {
      case 'alimentation':
        return Icons.restaurant;
      case 'vetements':
        return Icons.checkroom;
      case 'electronique':
        return Icons.phone_android;
      case 'beaute':
        return Icons.spa;
      case 'maison':
        return Icons.home;
      case 'sport':
        return Icons.sports_soccer;
      default:
        return Icons.category;
    }
  }
}
