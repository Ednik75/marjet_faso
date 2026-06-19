from rest_framework import serializers
from .models import Stock, StockMovement


class StockMovementSerializer(serializers.ModelSerializer):
    class Meta:
        model = StockMovement
        fields = ['id', 'stock', 'movement_type', 'quantity', 'reason', 'created_at']
        read_only_fields = ['id', 'stock', 'created_at']


class StockSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)
    boutique_name = serializers.CharField(source='product.boutique.name', read_only=True)
    is_low = serializers.BooleanField(read_only=True)
    recent_movements = StockMovementSerializer(source='movements', many=True, read_only=True)

    class Meta:
        model = Stock
        fields = ['id', 'product', 'product_name', 'boutique_name',
                  'quantity', 'threshold', 'is_low', 'updated_at',
                  'recent_movements']
        read_only_fields = ['id', 'updated_at']
