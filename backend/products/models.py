from django.db import models


class Product(models.Model):
    """A product sold by a boutique."""

    class Category(models.TextChoices):
        ALIMENTATION = 'alimentation', 'Alimentation'
        VETEMENTS = 'vetements', 'Vêtements'
        ELECTRONIQUE = 'electronique', 'Électronique'
        BEAUTE = 'beaute', 'Beauté'
        MAISON = 'maison', 'Maison'
        SPORT = 'sport', 'Sport'
        AUTRE = 'autre', 'Autre'

    boutique = models.ForeignKey(
        'boutiques.Boutique',
        on_delete=models.CASCADE,
        related_name='products'
    )
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    image = models.ImageField(upload_to='products/', blank=True, null=True)
    category = models.CharField(
        max_length=20,
        choices=Category.choices,
        default=Category.AUTRE,
    )
    is_available = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name} - {self.boutique.name}"
