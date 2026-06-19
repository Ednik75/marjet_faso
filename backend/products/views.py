from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Product
from .serializers import ProductSerializer, ProductListSerializer


class IsProductOwnerOrReadOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user.is_authenticated and request.user.is_merchant

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.boutique.owner == request.user


class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.select_related('boutique').all()
    permission_classes = [IsProductOwnerOrReadOnly]
    filterset_fields = ['category', 'boutique', 'is_available']
    search_fields = ['name', 'description', 'category']
    ordering_fields = ['price', 'created_at', 'name']

    def get_serializer_class(self):
        if self.action == 'list':
            return ProductListSerializer
        return ProductSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        # Annotate stock quantity
        from django.db.models import Sum, F
        qs = qs.annotate(
            stock_quantity=Sum('stock__quantity')
        )
        # Filter by availability
        available = self.request.query_params.get('available')
        if available == 'true':
            qs = qs.filter(is_available=True, stock_quantity__gt=0)
        return qs

    @action(detail=False, methods=['get'], permission_classes=[permissions.AllowAny])
    def search(self, request):
        """Search products by name, category, or boutique."""
        q = request.query_params.get('q', '')
        category = request.query_params.get('category', '')
        boutique_id = request.query_params.get('boutique', '')

        qs = Product.objects.filter(is_available=True)
        if q:
            qs = qs.filter(name__icontains=q)
        if category:
            qs = qs.filter(category=category)
        if boutique_id:
            qs = qs.filter(boutique_id=boutique_id)

        serializer = ProductListSerializer(qs, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def my_products(self, request):
        """List products belonging to the current merchant's boutiques."""
        qs = Product.objects.filter(boutique__owner=request.user)
        serializer = ProductSerializer(qs, many=True)
        return Response(serializer.data)
