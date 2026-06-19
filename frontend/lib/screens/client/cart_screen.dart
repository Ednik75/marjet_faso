import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/order_provider.dart';
import '../../providers/payment_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _paymentMethod = 'cash';

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir une adresse de livraison'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    final orderProvider = context.read<OrderProvider>();
    final paymentProvider = context.read<PaymentProvider>();

    final order = await orderProvider.placeOrder(
      _addressCtrl.text.trim(),
      _notesCtrl.text.trim(),
    );

    if (order != null && mounted) {
      await paymentProvider.createPayment(order.id, _paymentMethod);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande passée avec succès!'),
            backgroundColor: AppTheme.success,
          ),
        );
        _addressCtrl.clear();
        _notesCtrl.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panier')),
      body: Consumer<OrderProvider>(
        builder: (_, op, __) {
          if (op.cartItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppTheme.textLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Votre panier est vide',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ajoutez des produits pour commencer',
                    style: TextStyle(color: AppTheme.textLight),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cart items
                ...op.cartItems.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.unitPrice.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Quantity controls
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: () => op.updateQuantity(
                                    item.productId,
                                    item.quantity - 1,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: () => op.updateQuantity(
                                    item.productId,
                                    item.quantity + 1,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.error,
                            ),
                            onPressed: () => op.removeFromCart(item.productId),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Divider(height: 32),

                // Delivery info
                const Text(
                  'Livraison',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Adresse de livraison',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Paiement',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _PaymentOption(
                  value: 'cash',
                  label: 'Paiement à la livraison',
                  icon: Icons.money,
                  selected: _paymentMethod,
                  onTap: () => setState(() => _paymentMethod = 'cash'),
                ),
                _PaymentOption(
                  value: 'orange_money',
                  label: 'Orange Money',
                  icon: Icons.phone_android,
                  selected: _paymentMethod,
                  onTap: () => setState(() => _paymentMethod = 'orange_money'),
                ),
                _PaymentOption(
                  value: 'wave',
                  label: 'Wave',
                  icon: Icons.waves,
                  selected: _paymentMethod,
                  onTap: () => setState(() => _paymentMethod = 'wave'),
                ),
                _PaymentOption(
                  value: 'moov_money',
                  label: 'Moov Money',
                  icon: Icons.smartphone,
                  selected: _paymentMethod,
                  onTap: () => setState(() => _paymentMethod = 'moov_money'),
                ),

                const SizedBox(height: 24),

                // Total & place order
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${op.cartTotal.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _placeOrder,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Passer la commande'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final String selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textLight,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}
