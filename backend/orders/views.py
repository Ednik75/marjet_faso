from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Order
from .serializers import OrderSerializer, OrderStatusUpdateSerializer


class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.prefetch_related('items', 'items__product').all()
    serializer_class = OrderSerializer

    def get_queryset(self):
        user = self.request.user
        if user.is_merchant:
            return Order.objects.filter(
                boutique__owner=user
            ).prefetch_related('items', 'items__product')
        return Order.objects.filter(
            client=user
        ).prefetch_related('items', 'items__product')

    def get_permissions(self):
        if self.action == 'create':
            return [permissions.IsAuthenticated()]
        return [permissions.IsAuthenticated()]

    @action(detail=True, methods=['patch'])
    def update_status(self, request, pk=None):
        """Merchant updates order status."""
        order = self.get_object()
        if not request.user.is_merchant or order.boutique.owner != request.user:
            return Response(
                {"error": "Non autorisé."},
                status=status.HTTP_403_FORBIDDEN
            )
        serializer = OrderStatusUpdateSerializer(order, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(OrderSerializer(order).data)

    @action(detail=False, methods=['get'])
    def history(self, request):
        """Get order history for current user."""
        qs = self.get_queryset().filter(
            status__in=[Order.Status.DELIVERED, Order.Status.CANCELLED]
        )
        serializer = OrderSerializer(qs, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def stats(self, request):
        """Get order statistics for merchant."""
        if not request.user.is_merchant:
            return Response(
                {"error": "Réservé aux commerçants."},
                status=status.HTTP_403_FORBIDDEN
            )
        qs = Order.objects.filter(boutique__owner=request.user)
        total_orders = qs.count()
        total_revenue = sum(
            o.total_amount for o in qs.filter(status=Order.Status.DELIVERED)
        )
        pending = qs.filter(status=Order.Status.PENDING).count()
        return Response({
            'total_orders': total_orders,
            'total_revenue': float(total_revenue),
            'pending_orders': pending,
        })
