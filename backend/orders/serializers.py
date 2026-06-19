from rest_framework import serializers
from .models import Order, OrderItem
from products.serializers import ProductListSerializer


class OrderItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)
    subtotal = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = OrderItem
        fields = ['id', 'product', 'product_name', 'quantity', 'unit_price', 'subtotal']
        read_only_fields = ['id', 'unit_price']


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True)
    client_name = serializers.CharField(source='client.get_full_name', read_only=True)
    boutique_name = serializers.CharField(source='boutique.name', read_only=True)

    class Meta:
        model = Order
        fields = ['id', 'client', 'client_name', 'boutique', 'boutique_name',
                  'status', 'total_amount', 'delivery_address', 'notes',
                  'items', 'created_at', 'updated_at']
        read_only_fields = ['id', 'client', 'total_amount', 'created_at', 'updated_at']

    def create(self, validated_data):
        items_data = validated_data.pop('items')
        validated_data['client'] = self.context['request'].user
        order = Order.objects.create(**validated_data)

        for item_data in items_data:
            product = item_data['product']
            OrderItem.objects.create(
                order=order,
                product=product,
                quantity=item_data['quantity'],
                unit_price=product.price,
            )

        order.calculate_total()

        # Reduce stock
        for item_data in items_data:
            product = item_data['product']
            if hasattr(product, 'stock'):
                stock = product.stock
                stock.quantity = max(0, stock.quantity - item_data['quantity'])
                stock.save()

        return order


class OrderStatusUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = ['status']
