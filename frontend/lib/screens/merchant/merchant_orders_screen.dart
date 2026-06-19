import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/order_provider.dart';
import '../../providers/payment_provider.dart';
import '../../models/order.dart';

class MerchantOrdersScreen extends StatelessWidget {
  const MerchantOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commandes')),
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
                return _OrderCard(order: order);
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
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
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Client: ${order.clientName.isEmpty ? "#${order.clientId}" : order.clientName}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            if (order.deliveryAddress.isNotEmpty)
              Text(
                'Livraison: ${order.deliveryAddress}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
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
                Text(
                  'Total: ${order.totalFormatted}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentColor,
                  ),
                ),
                _buildActionButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final op = context.read<OrderProvider>();
    final pp = context.read<PaymentProvider>();
    switch (order.status) {
      case 'pending':
        return Row(
          children: [
            TextButton(
              onPressed: () => op.updateOrderStatus(order.id, 'cancelled'),
              child: const Text(
                'Refuser',
                style: TextStyle(color: AppTheme.error),
              ),
            ),
            ElevatedButton(
              onPressed: () => op.updateOrderStatus(order.id, 'confirmed'),
              child: const Text('Confirmer'),
            ),
          ],
        );
      case 'confirmed':
        return ElevatedButton(
          onPressed: () => op.updateOrderStatus(order.id, 'preparing'),
          child: const Text('Préparer'),
        );
      case 'preparing':
        return ElevatedButton(
          onPressed: () => op.updateOrderStatus(order.id, 'ready'),
          child: const Text('Prête'),
        );
      case 'ready':
        return ElevatedButton(
          onPressed: () async {
            await op.updateOrderStatus(order.id, 'delivered');
            // Auto-validate cash payment
            await pp.fetchPayments();
            final payment = pp.payments
                .where((p) => p.orderId == order.id)
                .firstOrNull;
            if (payment != null) {
              await pp.validatePayment(payment.id);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
          child: const Text('Livrée'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = AppTheme.warning;
        label = 'En attente';
      case 'confirmed':
        color = AppTheme.info;
        label = 'Confirmée';
      case 'preparing':
        color = AppTheme.info;
        label = 'Préparation';
      case 'ready':
        color = AppTheme.primaryLight;
        label = 'Prête';
      case 'delivered':
        color = AppTheme.success;
        label = 'Livrée';
      case 'cancelled':
        color = AppTheme.error;
        label = 'Annulée';
      default:
        color = AppTheme.textLight;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
