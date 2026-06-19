from django.contrib import admin
from .models import Stock, StockMovement


@admin.register(Stock)
class StockAdmin(admin.ModelAdmin):
    list_display = ['product', 'quantity', 'threshold', 'is_low', 'updated_at']
    list_filter = ['updated_at']


@admin.register(StockMovement)
class StockMovementAdmin(admin.ModelAdmin):
    list_display = ['stock', 'movement_type', 'quantity', 'reason', 'created_at']
    list_filter = ['movement_type']
