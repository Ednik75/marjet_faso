# Deploiement gratuit

Architecture recommandee :

- Frontend Flutter web : Vercel
- Backend Django : Render Free Web Service
- Base de donnees : Neon Postgres Free

## 1. Creer la base Neon

1. Va sur https://neon.com et cree un projet Postgres gratuit.
2. Copie la chaine de connexion Postgres, par exemple :

```text
postgresql://USER:PASSWORD@HOST.neon.tech/DBNAME?sslmode=require
```

Cette valeur sera utilisee comme `DATABASE_URL` dans Render.

## 2. Deployer le backend sur Render

1. Va sur https://render.com.
2. Cree un nouveau Blueprint ou Web Service depuis ton depot GitHub.
3. Si tu utilises le Blueprint, Render lira `render.yaml`.
4. Ajoute les variables d'environnement suivantes :

```text
DATABASE_URL=postgresql://USER:PASSWORD@HOST.neon.tech/DBNAME?sslmode=require
DEBUG=False
ALLOWED_HOSTS=ton-backend.onrender.com
CORS_ALLOWED_ORIGINS=https://ton-frontend.vercel.app
CSRF_TRUSTED_ORIGINS=https://ton-frontend.vercel.app
```

Render genere automatiquement `SECRET_KEY` si tu utilises `render.yaml`.

Si tu crees un Web Service manuellement :

```text
Root Directory: backend
Build Command: ./build.sh
Start Command: gunicorn config.wsgi:application
```

Apres le premier deploy, copie l'URL Render du backend. Elle ressemble a :

```text
https://market-project-api.onrender.com
```

L'API sera disponible avec `/api`, par exemple :

```text
https://market-project-api.onrender.com/api/products/
```

## 3. Deployer le frontend sur Vercel

1. Va sur https://vercel.com et importe le meme depot GitHub.
2. Configure le projet Vercel avec :

```text
Root Directory: frontend
Framework Preset: Other
```

3. Ajoute cette variable d'environnement dans Vercel :

```text
API_BASE_URL=https://ton-backend.onrender.com/api
```

Le fichier `frontend/vercel.json` installe Flutter, build le web, puis sert `build/web`.

## 4. Finaliser CORS

Quand Vercel te donne l'URL finale du frontend, retourne dans Render et mets a jour :

```text
CORS_ALLOWED_ORIGINS=https://ton-frontend.vercel.app
CSRF_TRUSTED_ORIGINS=https://ton-frontend.vercel.app
```

Puis redeploie le backend.

## Notes

- Render Free endort le backend apres une periode d'inactivite. Le premier appel peut donc etre lent.
- N'utilise pas SQLite en production : le stockage Render gratuit est ephemere.
- Les fichiers uploades localement ne persistent pas sur Render Free. Pour les images en production, ajoute plus tard un stockage externe comme Cloudinary ou S3.
