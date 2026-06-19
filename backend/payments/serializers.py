from rest_framework import serializers
from .models import Payment


class PaymentSerializer(serializers.ModelSerializer):
    method_display = serializers.CharField(source='get_method_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Payment
        fields = ['id', 'order', 'method', 'method_display', 'amount',
                  'status', 'status_display', 'transaction_id',
                  'created_at', 'updated_at']
        read_only_fields = ['id', 'amount', 'status', 'transaction_id',
                            'created_at', 'updated_at']

    def create(self, validated_data):
        order = validated_data['order']
        validated_data['amount'] = order.total_amount
        # Cash on delivery is auto-pending; mobile money would trigger API
        if validated_data['method'] == Payment.Method.CASH:
            validated_data['status'] = Payment.Status.PENDING
        return super().create(validated_data)


class PaymentStatusUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = ['status']
