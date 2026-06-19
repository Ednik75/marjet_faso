import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/stock_provider.dart';
import '../../models/stock.dart';

class MerchantStockScreen extends StatelessWidget {
  const MerchantStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion du stock')),
      body: Consumer<StockProvider>(
        builder: (_, sp, __) {
          if (sp.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (sp.stocks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warehouse_outlined,
                    size: 80,
                    color: AppTheme.textLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun stock à gérer',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => sp.fetchStocks(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sp.stocks.length,
              itemBuilder: (_, i) {
                final s = sp.stocks[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    s.boutiqueName,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: s.isLow
                                    ? AppTheme.error.withValues(alpha: 0.1)
                                    : AppTheme.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${s.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: s.isLow
                                      ? AppTheme.error
                                      : AppTheme.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (s.isLow) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber,
                                  size: 14,
                                  color: AppTheme.warning,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Stock faible',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _showMovementDialog(context, s, 'entry'),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Entrée'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.success,
                                  side: const BorderSide(
                                    color: AppTheme.success,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _showMovementDialog(context, s, 'exit'),
                                icon: const Icon(Icons.remove, size: 18),
                                label: const Text('Sortie'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.error,
                                  side: const BorderSide(color: AppTheme.error),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  void _showMovementDialog(BuildContext context, Stock stock, String type) {
    final qtyCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final isEntry = type == 'entry';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEntry ? 'Entrée de stock' : 'Sortie de stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Produit: ${stock.productName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text('Stock actuel: ${stock.quantity}'),
            const SizedBox(height: 16),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantité'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Raison (optionnel)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final qty = int.tryParse(qtyCtrl.text) ?? 0;
              if (qty <= 0) return;
              await context.read<StockProvider>().recordMovement(
                stock.id,
                StockMovement(
                  movementType: type,
                  quantity: qty,
                  reason: reasonCtrl.text,
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isEntry ? AppTheme.success : AppTheme.error,
            ),
            child: Text(isEntry ? 'Ajouter' : 'Retirer'),
          ),
        ],
      ),
    );
  }
}
