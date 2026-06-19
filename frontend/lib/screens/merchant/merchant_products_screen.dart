import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/boutique_provider.dart';

class MerchantProductsScreen extends StatelessWidget {
  const MerchantProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes produits')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: Consumer<ProductProvider>(
        builder: (_, pp, __) {
          if (pp.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (pp.myProducts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: AppTheme.textLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun produit',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ajoutez votre premier produit',
                    style: TextStyle(color: AppTheme.textLight),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => pp.fetchMyProducts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pp.myProducts.length,
              itemBuilder: (_, i) {
                final p = pp.myProducts[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getCatIcon(p.category),
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.priceFormatted,
                          style: const TextStyle(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          p.boutiqueName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Modifier'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Supprimer',
                            style: TextStyle(color: AppTheme.error),
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          pp.deleteProduct(p.id);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
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

  void _showAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String category = 'autre';
    final boutiques = context.read<BoutiqueProvider>().myBoutiques;
    int? boutiqueId = boutiques.isNotEmpty ? boutiques.first.id : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouveau produit',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (boutiques.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: boutiqueId,
                    decoration: const InputDecoration(labelText: 'Boutique'),
                    items: boutiques
                        .map(
                          (b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => boutiqueId = v,
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom du produit',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Prix (FCFA)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: const [
                    DropdownMenuItem(
                      value: 'alimentation',
                      child: Text('Alimentation'),
                    ),
                    DropdownMenuItem(
                      value: 'vetements',
                      child: Text('Vêtements'),
                    ),
                    DropdownMenuItem(
                      value: 'electronique',
                      child: Text('Électronique'),
                    ),
                    DropdownMenuItem(value: 'beaute', child: Text('Beauté')),
                    DropdownMenuItem(value: 'maison', child: Text('Maison')),
                    DropdownMenuItem(value: 'sport', child: Text('Sport')),
                    DropdownMenuItem(value: 'autre', child: Text('Autre')),
                  ],
                  onChanged: (v) =>
                      setModalState(() => category = v ?? 'autre'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty ||
                          priceCtrl.text.isEmpty ||
                          boutiqueId == null)
                        return;
                      await context.read<ProductProvider>().createProduct({
                        'boutique': boutiqueId,
                        'name': nameCtrl.text,
                        'description': descCtrl.text,
                        'price': priceCtrl.text,
                        'category': category,
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Ajouter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
