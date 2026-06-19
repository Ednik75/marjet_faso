from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    """Custom user model with role-based access."""

    class Role(models.TextChoices):
        CLIENT = 'client', 'Client'
        MERCHANT = 'merchant', 'Commerçant'
        ADMIN = 'admin', 'Administrateur'

    role = models.CharField(
        max_length=10,
        choices=Role.choices,
        default=Role.CLIENT,
    )
    phone = models.CharField(max_length=20, blank=True)
    address = models.TextField(blank=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"

    @property
    def is_merchant(self):
        return self.role == self.Role.MERCHANT

    @property
    def is_client(self):
        return self.role == self.Role.CLIENT

    @property
    def is_admin_user(self):
        return self.role == self.Role.ADMIN
