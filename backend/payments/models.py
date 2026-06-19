from django.db import models
from django.conf import settings


class Payment(models.Model):
    """Payment for an order."""

    class Method(models.TextChoices):
        CASH = 'cash', 'Paiement à la livraison'
        ORANGE_MONEY = 'orange_money', 'Orange Money'
        MOOV_MONEY = 'moov_money', 'Moov Money'
        WAVE = 'wave', 'Wave'
        CARD = 'card', 'Carte bancaire'

    class Status(models.TextChoices):
        PENDING = 'pending', 'En attente'
        COMPLETED = 'completed', 'Complété'
        FAILED = 'failed', 'Échoué'
        REFUNDED = 'refunded', 'Remboursé'

    order = models.OneToOneField(
        'orders.Order',
        on_delete=models.CASCADE,
        related_name='payment'
    )
    method = models.CharField(
        max_length=15,
        choices=Method.choices,
        default=Method.CASH,
    )
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(
        max_length=10,
        choices=Status.choices,
        default=Status.PENDING,
    )
    transaction_id = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Paiement #{self.id} - {self.get_method_display()} - {self.get_status_display()}"
