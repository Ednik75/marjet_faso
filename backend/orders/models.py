from django.db import models
from django.conf import settings


class Order(models.Model):
    """Customer order."""

    class Status(models.TextChoices):
        PENDING = 'pending', 'En attente'
        CONFIRMED = 'confirmed', 'Confirmée'
        PREPARING = 'preparing', 'En préparation'
        READY = 'ready', 'Prête'
        DELIVERED = 'delivered', 'Livrée'
        CANCELLED = 'cancelled', 'Annulée'

    client = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='orders'
    )
    boutique = models.ForeignKey(
        'boutiques.Boutique',
        on_delete=models.CASCADE,
        related_name='orders'
    )
    status = models.CharField(
        max_length=10,
        choices=Status.choices,
        default=Status.PENDING,
    )
    total_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    delivery_address = models.TextField(blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Commande #{self.id} - {self.client.username}"

    def calculate_total(self):
        self.total_amount = sum(
            item.subtotal for item in self.items.all()
        )
        self.save(update_fields=['total_amount'])


class OrderItem(models.Model):
    """Individual item in an order."""
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey(
        'products.Product',
        on_delete=models.CASCADE,
        related_name='order_items'
    )
    quantity = models.PositiveIntegerField(default=1)
    unit_price = models.DecimalField(max_digits=10, decimal_places=2)

    @property
    def subtotal(self):
        return self.quantity * self.unit_price

    def __str__(self):
        return f"{self.product.name} x{self.quantity}"
