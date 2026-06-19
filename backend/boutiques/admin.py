from django.contrib import admin
from .models import Boutique


@admin.register(Boutique)
class BoutiqueAdmin(admin.ModelAdmin):
    list_display = ['name', 'owner', 'category', 'status', 'is_active', 'created_at']
    list_filter = ['status', 'category', 'is_active']
    search_fields = ['name', 'address']
    actions = ['approve_boutiques', 'reject_boutiques']

    @admin.action(description="Approuver les boutiques sélectionnées")
    def approve_boutiques(self, request, queryset):
        queryset.update(status=Boutique.Status.APPROVED)

    @admin.action(description="Rejeter les boutiques sélectionnées")
    def reject_boutiques(self, request, queryset):
        queryset.update(status=Boutique.Status.REJECTED)
