from rest_framework import serializers
from .models import Boutique


class BoutiqueSerializer(serializers.ModelSerializer):
    owner_name = serializers.CharField(source='owner.get_full_name', read_only=True)
    distance = serializers.FloatField(read_only=True, required=False)

    class Meta:
        model = Boutique
        fields = ['id', 'owner', 'owner_name', 'name', 'description', 'address',
                  'phone', 'email', 'image', 'latitude', 'longitude', 'category',
                  'status', 'is_active', 'opening_hours', 'created_at', 'updated_at',
                  'distance']
        read_only_fields = ['id', 'owner', 'status', 'created_at', 'updated_at']

    def create(self, validated_data):
        validated_data['owner'] = self.context['request'].user
        return super().create(validated_data)


class BoutiqueListSerializer(serializers.ModelSerializer):
    """Lighter serializer for list views."""
    owner_name = serializers.CharField(source='owner.get_full_name', read_only=True)

    class Meta:
        model = Boutique
        fields = ['id', 'name', 'address', 'image', 'latitude', 'longitude',
                  'category', 'status', 'is_active', 'owner_name']
