from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Stock, StockMovement
from .serializers import StockSerializer, StockMovementSerializer


class IsStockOwner(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.is_merchant

    def has_object_permission(self, request, view, obj):
        return obj.product.boutique.owner == request.user


class StockViewSet(viewsets.ModelViewSet):
    queryset = Stock.objects.select_related('product', 'product__boutique').all()
    serializer_class = StockSerializer
    permission_classes = [IsStockOwner]

    def get_queryset(self):
        return Stock.objects.filter(
            product__boutique__owner=self.request.user
        ).select_related('product', 'product__boutique').prefetch_related('movements')

    @action(detail=True, methods=['post'])
    def movement(self, request, pk=None):
        """Record a stock entry or exit."""
        stock = self.get_object()
        serializer = StockMovementSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        movement_type = serializer.validated_data['movement_type']
        qty = serializer.validated_data['quantity']

        if movement_type == StockMovement.MovementType.EXIT:
            if stock.quantity < qty:
                return Response(
                    {"error": "Stock insuffisant."},
                    status=status.HTTP_400_BAD_REQUEST
                )
            stock.quantity -= qty
        else:
            stock.quantity += qty

        stock.save()
        StockMovement.objects.create(
            stock=stock,
            movement_type=movement_type,
            quantity=qty,
            reason=serializer.validated_data.get('reason', '')
        )

        return Response(StockSerializer(stock).data)

    @action(detail=False, methods=['get'])
    def alerts(self, request):
        """Get products with low stock."""
        qs = self.get_queryset()
        low_stock = [s for s in qs if s.is_low]
        serializer = StockSerializer(low_stock, many=True)
        return Response(serializer.data)
