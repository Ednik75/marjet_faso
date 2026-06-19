from rest_framework import viewsets, permissions
from rest_framework.response import Response
from django.db.models import Avg
from .models import Review
from .serializers import ReviewSerializer


class ReviewViewSet(viewsets.ModelViewSet):
    queryset = Review.objects.select_related('user').all()
    serializer_class = ReviewSerializer
    filterset_fields = ['boutique', 'product', 'rating']

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated()]

    def get_queryset(self):
        qs = super().get_queryset()
        boutique = self.request.query_params.get('boutique')
        product = self.request.query_params.get('product')
        if boutique:
            qs = qs.filter(boutique_id=boutique)
        if product:
            qs = qs.filter(product_id=product)
        return qs
