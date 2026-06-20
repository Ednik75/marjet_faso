from django.db import models
from rest_framework import viewsets, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import action

from accounts.models import User
from boutiques.models import Boutique
from products.models import Product
from orders.models import Order
from payments.models import Payment

from accounts.serializers import UserSerializer
from boutiques.serializers import BoutiqueSerializer
from products.serializers import ProductSerializer
from orders.serializers import OrderSerializer, OrderStatusUpdateSerializer
from payments.serializers import PaymentSerializer, PaymentStatusUpdateSerializer
from .permissions import IsAdminUser


class AdminStatsView(APIView):
    """
    Retrieve global stats for the admin dashboard.
    """
    permission_classes = [IsAdminUser]

    def get(self, request, format=None):
        total_users = User.objects.count()
        clients = User.objects.filter(role=User.Role.CLIENT).count()
        merchants = User.objects.filter(role=User.Role.MERCHANT).count()
        admins = User.objects.filter(role=User.Role.ADMIN).count()

        total_boutiques = Boutique.objects.count()
        pending_boutiques = Boutique.objects.filter(status=Boutique.Status.PENDING).count()
        approved_boutiques = Boutique.objects.filter(status=Boutique.Status.APPROVED).count()
        rejected_boutiques = Boutique.objects.filter(status=Boutique.Status.REJECTED).count()

        total_products = Product.objects.count()
        total_orders = Order.objects.count()

        revenue_agg = Payment.objects.filter(
            status=Payment.Status.COMPLETED
        ).aggregate(total=models.Sum('amount'))
        total_revenue = revenue_agg['total'] or 0

        # Recent orders and boutiques for overview
        recent_orders = Order.objects.select_related('client', 'boutique').order_by('-created_at')[:5]
        recent_boutiques = Boutique.objects.select_related('owner').order_by('-created_at')[:5]

        return Response({
            'stats': {
                'total_users': total_users,
                'clients': clients,
                'merchants': merchants,
                'admins': admins,
                'total_boutiques': total_boutiques,
                'pending_boutiques': pending_boutiques,
                'approved_boutiques': approved_boutiques,
                'rejected_boutiques': rejected_boutiques,
                'total_products': total_products,
                'total_orders': total_orders,
                'total_revenue': float(total_revenue),
            },
            'recent_orders': OrderSerializer(recent_orders, many=True, context={'request': request}).data,
            'recent_boutiques': BoutiqueSerializer(recent_boutiques, many=True, context={'request': request}).data,
        })


class AdminUserViewSet(viewsets.ModelViewSet):
    """
    Manage all users in the system.
    """
    queryset = User.objects.all().order_by('-created_at')
    serializer_class = UserSerializer
    permission_classes = [IsAdminUser]
    filterset_fields = ['role', 'is_active']
    search_fields = ['username', 'email', 'first_name', 'last_name', 'phone']


class AdminBoutiqueViewSet(viewsets.ModelViewSet):
    """
    Manage all boutiques in the system (approve, reject, delete).
    """
    queryset = Boutique.objects.all().order_by('-created_at')
    serializer_class = BoutiqueSerializer
    permission_classes = [IsAdminUser]
    filterset_fields = ['status', 'is_active', 'category']
    search_fields = ['name', 'description', 'address', 'phone', 'email']

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        boutique = self.get_object()
        boutique.status = Boutique.Status.APPROVED
        boutique.save()
        serializer = self.get_serializer(boutique)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        boutique = self.get_object()
        boutique.status = Boutique.Status.REJECTED
        boutique.save()
        serializer = self.get_serializer(boutique)
        return Response(serializer.data)


class AdminProductViewSet(viewsets.ModelViewSet):
    """
    Manage products in the system.
    """
    queryset = Product.objects.all().order_by('-created_at')
    serializer_class = ProductSerializer
    permission_classes = [IsAdminUser]
    filterset_fields = ['category', 'is_available', 'boutique']
    search_fields = ['name', 'description']


class AdminOrderViewSet(viewsets.ModelViewSet):
    """
    Manage orders in the system.
    """
    queryset = Order.objects.all().order_by('-created_at')
    serializer_class = OrderSerializer
    permission_classes = [IsAdminUser]
    filterset_fields = ['status', 'boutique', 'client']
    search_fields = ['id', 'client__username', 'boutique__name', 'delivery_address']

    def get_serializer_class(self):
        if self.action in ['update', 'partial_update']:
            return OrderStatusUpdateSerializer
        return OrderSerializer


class AdminPaymentViewSet(viewsets.ModelViewSet):
    """
    Manage payments in the system.
    """
    queryset = Payment.objects.all().order_by('-created_at')
    serializer_class = PaymentSerializer
    permission_classes = [IsAdminUser]
    filterset_fields = ['status', 'method']
    search_fields = ['id', 'transaction_id', 'order__id', 'order__client__username']

    def get_serializer_class(self):
        if self.action in ['update', 'partial_update']:
            return PaymentStatusUpdateSerializer
        return PaymentSerializer
