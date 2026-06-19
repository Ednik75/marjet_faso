"""
Seed script for the marketplace database.
Run: cd backend && source ../venv/bin/activate && python manage.py shell < seed_data.py
"""
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from accounts.models import User
from boutiques.models import Boutique
from products.models import Product
from stocks.models import Stock
from reviews.models import Review

# Create users
admin_user = User.objects.create_superuser(
    username='admin', email='admin@marketplace.local',
    password='admin123', role='admin',
    first_name='Admin', last_name='Système'
)
merchant1 = User.objects.create_user(
    username='boutique_mariam', email='mariam@marketplace.local',
    password='merchant123', role='merchant',
    first_name='Mariam', last_name='Sawadogo', phone='+226 70 00 00 01'
)

merchant2 = User.objects.create_user(
    username='boutique_ousmane', email='ousmane@marketplace.local',
    password='merchant123', role='merchant',
    first_name='Ousmane', last_name='Sankara', phone='+226 70 00 00 02'
)

client1 = User.objects.create_user(
    username='amina_client', email='amina@marketplace.local',
    password='client123', role='client',
    first_name='Amina', last_name='Traoré', phone='+226 76 00 00 01'
)

client2 = User.objects.create_user(
    username='boureima_client', email='boureima@marketplace.local',
    password='client123', role='client',
    first_name='Boureima', last_name='Ouédraogo', phone='+226 76 00 00 02'
)

print("✓ Users created")

# Create boutiques (Ouagadougou coordinates)
b1 = Boutique.objects.create(
    owner=merchant1, name='Alimentation Wend Konta',
    description='Alimentation générale, fruits et légumes frais locaux',
    address='Patte d\'Oie, Boulevard de l\'Insurrection, Ouagadougou',
    phone='+226 70 00 00 01', category='alimentation',
    latitude=12.3300, longitude=-1.5100,
    status='approved', opening_hours='7h-20h Lun-Sam'
)

b2 = Boutique.objects.create(
    owner=merchant1, name='Faso Dan Fani Couture',
    description='Vêtements traditionnels Faso Dan Fani et prêt-à-porter',
    address='Koulouba, Avenue Nelson Mandela, Ouagadougou',
    phone='+226 70 00 00 01', category='vetements',
    latitude=12.3750, longitude=-1.5180,
    status='approved', opening_hours='9h-19h Lun-Sam'
)

b3 = Boutique.objects.create(
    owner=merchant2, name='Tech Kaboré',
    description='Téléphones, accessoires et réparations',
    address='Projet ZACA, Centre-ville, Ouagadougou',
    phone='+226 70 00 00 02', category='electronique',
    latitude=12.3700, longitude=-1.5200,
    status='approved', opening_hours='8h-21h tous les jours'
)

b4 = Boutique.objects.create(
    owner=merchant2, name='Karité Burkina Beauté',
    description='Produits cosmétiques à base de beurre de karité pur du Burkina',
    address='Dassasgho, Boulevard Charles de Gaulle, Ouagadougou',
    phone='+226 70 00 00 02', category='beaute',
    latitude=12.3650, longitude=-1.5000,
    status='pending', opening_hours='8h-18h Lun-Ven'
)

print("✓ Boutiques created")

# Create products and stocks
products_data = [
    # Alimentation Wend Konta
    (b1, 'Riz Brisé 25kg', 'Riz brisé de qualité supérieure', 12500, 'alimentation', 50, 10),
    (b1, 'Huile de Sésame local 5L', 'Huile de sésame naturelle du Burkina', 4500, 'alimentation', 30, 5),
    (b1, 'Farine de Mil local 5kg', 'Farine de mil bio pour le Tô traditionnel', 2500, 'alimentation', 100, 20),
    (b1, 'Poulet Bicyclette local', 'Poulet bicyclette local frais élevé en plein air', 3000, 'alimentation', 40, 10),
    (b1, 'Tomates Fraîches 1kg', 'Tomates locales du Kadiogo', 800, 'alimentation', 25, 5),
    # Faso Dan Fani Couture
    (b2, 'Pagne Faso Dan Fani', 'Pagne traditionnel burkinabè tissé à la main, 3 pièces', 15000, 'vetements', 20, 5),
    (b2, 'Boubou Faso Dan Fani', 'Grand boubou brodé traditionnel en Faso Dan Fani', 25000, 'vetements', 10, 3),
    (b2, 'Robe Faso Dan Fani', 'Robe moderne stylisée en Faso Dan Fani', 18000, 'vetements', 15, 3),
    (b2, 'Sandales en Cuir', 'Sandales artisanales fabriquées à Ouagadougou', 8000, 'vetements', 12, 3),
    # Tech Kaboré
    (b3, 'iPhone 13 reconditionné', 'iPhone 13 128Go, état excellent', 250000, 'electronique', 5, 2),
    (b3, 'Samsung A54', 'Samsung Galaxy A54 neuf avec garantie', 180000, 'electronique', 8, 2),
    (b3, 'Écouteurs Bluetooth', 'Écouteurs sans fil avec micro', 5000, 'electronique', 50, 10),
    (b3, 'Chargeur USB-C', 'Chargeur rapide 25W', 3000, 'electronique', 30, 5),
    (b3, 'Coque iPhone', 'Coque de protection silicone', 2000, 'electronique', 40, 10),
    # Karité Burkina Beauté
    (b4, 'Beurre de Karité Bio 500g', 'Beurre de karité pur non raffiné de l\'association des femmes', 3500, 'beaute', 25, 5),
    (b4, 'Savon de Karité artisanal', 'Savon doux traditionnel à base de beurre de karité', 1500, 'beaute', 40, 10),
    (b4, 'Huile de Sésame Bio 250ml', 'Huile de sésame pressée à froid pour soins corporels', 4000, 'beaute', 20, 5),
]

for boutique, name, desc, price, cat, qty, threshold in products_data:
    p = Product.objects.create(
        boutique=boutique, name=name, description=desc,
        price=price, category=cat
    )
    Stock.objects.create(product=p, quantity=qty, threshold=threshold)

print("✓ Products and stocks created")

# Create some reviews
Review.objects.create(user=client1, boutique=b1, rating=5, comment="Excellent service, produits frais!")
Review.objects.create(user=client1, boutique=b3, rating=4, comment="Bon choix de téléphones, prix correct.")
Review.objects.create(user=client2, boutique=b1, rating=4, comment="Toujours de bons produits.")
Review.objects.create(user=client2, boutique=b2, rating=5, comment="Les pagnes sont magnifiques!")

print("✓ Reviews created")
print("\n✅ Seed data complete!")
print("  Admin: admin / admin123")
print("  Merchant: boutique_mariam / merchant123")
print("  Merchant: boutique_ousmane / merchant123")
print("  Client: amina_client / client123")
print("  Client: boureima_client / client123")
