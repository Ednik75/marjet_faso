from rest_framework import serializers
from .models import Product


class ProductSerializer(serializers.ModelSerializer):
    boutique_name = serializers.CharField(source='boutique.name', read_only=True)
    stock_quantity = serializers.IntegerField(read_only=True, required=False)

    class Meta:
        model = Product
        fields = ['id', 'boutique', 'boutique_name', 'name', 'description',
                  'price', 'image', 'category', 'is_available',
                  'stock_quantity', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']


class ProductListSerializer(serializers.ModelSerializer):
    boutique_name = serializers.CharField(source='boutique.name', read_only=True)

    class Meta:
        model = Product
        fields = ['id', 'boutique', 'boutique_name', 'name', 'price',
                  'image', 'category', 'is_available']
