import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/order_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: Consumer<OrderProvider>(
        builder: (_, op, __) {
          if (op.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (op.orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: AppTheme.textLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune commande',
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
            onRefresh: () => op.fetchOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: op.orders.length,
              itemBuilder: (_, i) {
                final order = op.orders[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Commande #${order.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            _StatusChip(status: order.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order.boutiqueName,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        ...order.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.productName} x${item.quantity}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  '${item.subtotal.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              order.totalFormatted,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        if (order.createdAt != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            order.createdAt!
                                .substring(0, 16)
                                .replaceAll('T', ' '),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
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
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'pending':
        color = AppTheme.warning;
      case 'confirmed':
      case 'preparing':
        color = AppTheme.info;
      case 'ready':
        color = AppTheme.primaryLight;
      case 'delivered':
        color = AppTheme.success;
      case 'cancelled':
        color = AppTheme.error;
      default:
        color = AppTheme.textLight;
    }

    final labels = {
      'pending': 'En attente',
      'confirmed': 'Confirmée',
      'preparing': 'Préparation',
      'ready': 'Prête',
      'delivered': 'Livrée',
      'cancelled': 'Annulée',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        labels[status] ?? status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
