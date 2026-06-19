from django.db import models


class Stock(models.Model):
    """Stock level for a product."""
    product = models.OneToOneField(
        'products.Product',
        on_delete=models.CASCADE,
        related_name='stock'
    )
    quantity = models.PositiveIntegerField(default=0)
    threshold = models.PositiveIntegerField(default=5, help_text="Seuil d'alerte stock faible")
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.product.name}: {self.quantity}"

    @property
    def is_low(self):
        return self.quantity <= self.threshold


class StockMovement(models.Model):
    """Track stock entries and exits."""

    class MovementType(models.TextChoices):
        ENTRY = 'entry', 'Entrée'
        EXIT = 'exit', 'Sortie'

    stock = models.ForeignKey(Stock, on_delete=models.CASCADE, related_name='movements')
    movement_type = models.CharField(max_length=5, choices=MovementType.choices)
    quantity = models.PositiveIntegerField()
    reason = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.get_movement_type_display()} {self.quantity} - {self.stock.product.name}"
