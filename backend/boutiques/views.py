import math
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Boutique
from .serializers import BoutiqueSerializer, BoutiqueListSerializer


class IsMerchantOrReadOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user.is_authenticated and request.user.is_merchant

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.owner == request.user


class BoutiqueViewSet(viewsets.ModelViewSet):
    queryset = Boutique.objects.filter(is_active=True)
    permission_classes = [IsMerchantOrReadOnly]
    filterset_fields = ['category', 'status']
    search_fields = ['name', 'description', 'address', 'category']

    def get_serializer_class(self):
        if self.action == 'list':
            return BoutiqueListSerializer
        return BoutiqueSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        if self.action == 'my_shops':
            return Boutique.objects.filter(owner=self.request.user)
        # Only show approved shops to non-owners
        if not self.request.user.is_authenticated or not self.request.user.is_merchant:
            qs = qs.filter(status=Boutique.Status.APPROVED)
        return qs

    @action(detail=False, methods=['get'])
    def my_shops(self, request):
        """List shops owned by the current merchant."""
        qs = self.get_queryset()
        serializer = BoutiqueSerializer(qs, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], permission_classes=[permissions.AllowAny])
    def nearby(self, request):
        """Find shops near a given lat/lng within a radius (km)."""
        try:
            lat = float(request.query_params.get('lat', 0))
            lng = float(request.query_params.get('lng', 0))
            radius = float(request.query_params.get('radius', 10))
        except (TypeError, ValueError):
            return Response(
                {"error": "Paramètres lat, lng et radius requis."},
                status=status.HTTP_400_BAD_REQUEST
            )

        shops = []
        for shop in Boutique.objects.filter(
            status=Boutique.Status.APPROVED, is_active=True
        ):
            d = self._haversine(lat, lng, shop.latitude, shop.longitude)
            if d <= radius:
                shop.distance = round(d, 2)
                shops.append(shop)

        shops.sort(key=lambda s: s.distance)
        serializer = BoutiqueSerializer(shops, many=True)
        return Response(serializer.data)

    @staticmethod
    def _haversine(lat1, lon1, lat2, lon2):
        """Calculate distance between two points in km."""
        R = 6371
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        a = (math.sin(dlat / 2) ** 2 +
             math.cos(math.radians(lat1)) *
             math.cos(math.radians(lat2)) *
             math.sin(dlon / 2) ** 2)
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        return R * c
