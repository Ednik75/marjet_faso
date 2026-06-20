from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register('users', views.AdminUserViewSet, basename='admin-users')
router.register('boutiques', views.AdminBoutiqueViewSet, basename='admin-boutiques')
router.register('products', views.AdminProductViewSet, basename='admin-products')
router.register('orders', views.AdminOrderViewSet, basename='admin-orders')
router.register('payments', views.AdminPaymentViewSet, basename='admin-payments')

urlpatterns = [
    path('stats/', views.AdminStatsView.as_view(), name='admin-stats'),
    path('', include(router.urls)),
]
