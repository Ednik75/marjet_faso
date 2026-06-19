from django.db import models
from django.conf import settings


class Boutique(models.Model):
    """A merchant's shop/store."""

    class Status(models.TextChoices):
        PENDING = 'pending', 'En attente'
        APPROVED = 'approved', 'Approuvée'
        REJECTED = 'rejected', 'Rejetée'

    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='boutiques'
    )
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    address = models.TextField()
    phone = models.CharField(max_length=20)
    email = models.EmailField(blank=True)
    image = models.ImageField(upload_to='boutiques/', blank=True, null=True)
    latitude = models.FloatField()
    longitude = models.FloatField()
    category = models.CharField(max_length=100, blank=True)
    status = models.CharField(
        max_length=10,
        choices=Status.choices,
        default=Status.PENDING,
    )
    is_active = models.BooleanField(default=True)
    opening_hours = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.name
