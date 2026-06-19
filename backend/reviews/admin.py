from django.contrib import admin
from .models import Review


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ['user', 'boutique', 'product', 'rating', 'created_at']
    list_filter = ['rating']
