from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Payment
from .serializers import PaymentSerializer, PaymentStatusUpdateSerializer


class PaymentViewSet(viewsets.ModelViewSet):
    queryset = Payment.objects.select_related('order').all()
    serializer_class = PaymentSerializer

    def get_queryset(self):
        user = self.request.user
        if user.is_merchant:
            return Payment.objects.filter(
                order__boutique__owner=user
            ).select_related('order')
        return Payment.objects.filter(
            order__client=user
        ).select_related('order')

    @action(detail=True, methods=['patch'])
    def validate_payment(self, request, pk=None):
        """Merchant validates a payment (e.g., cash received)."""
        payment = self.get_object()
        if not request.user.is_merchant:
            return Response(
                {"error": "Réservé aux commerçants."},
                status=status.HTTP_403_FORBIDDEN
            )
        serializer = PaymentStatusUpdateSerializer(
            payment, data=request.data, partial=True
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(PaymentSerializer(payment).data)

    @action(detail=False, methods=['get'])
    def history(self, request):
        """Get payment transaction history."""
        qs = self.get_queryset()
        serializer = PaymentSerializer(qs, many=True)
        return Response(serializer.data)
