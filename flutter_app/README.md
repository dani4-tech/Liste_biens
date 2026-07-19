# Application Flutter — Catalogue de Ventes Privées

Application mobile avec authentification, catalogue de produits et persistance de session, associée à un backend Python (Flask).

## Structure du projet

```
projet/
├── server/
│   ├── data/
│   │   ├── users.json
│   │   └── ventes.json
│   ├── server.py
│   └── requirements.txt
└── flutter_app/
    └── lib/
        ├── main.dart
        ├── models/
        ├── services/
        └── screens/
```

## Prérequis

- Python 3.8+ installé
- Flutter SDK installé (`flutter --version` pour vérifier)
- Un téléphone Android (ou émulateur) et le PC connectés au **même réseau Wi-Fi**

## 1. Lancer le serveur

Dans un premier terminal :

```bash
cd server
pip install -r requirements.txt
python server.py
```

Le terminal doit afficher quelque chose comme :

```
Running on all addresses (0.0.0.0)
Running on http://127.0.0.1:5000
Running on http://192.168.1.152:5000
```

**Noter l'adresse IP affichée** (ici `192.168.1.152`) — c'est celle à utiliser à l'étape suivante. Elle peut être différente sur votre machine ; vous pouvez aussi la retrouver avec `ipconfig` (Windows) ou `ifconfig` (Mac/Linux), en cherchant l'adresse IPv4 de la carte Wi-Fi.

### Vérifier que le serveur répond

Dans un navigateur, ouvrir `http://localhost:5000/api/produits` : la liste des produits doit s'afficher en JSON.

## 2. Configurer l'adresse du serveur côté Flutter

Si l'adresse IP du serveur est différente de celle déjà configurée, ouvrir `flutter_app/lib/services/api_service.dart` et modifie la ligne :

```dart
static const String baseUrl = 'http://TON_IP:5000/api';
```

Faire de même dans `flutter_app/android/app/src/main/res/xml/network_security_config.xml` (remplacer l'adresse IP dans la balise `<domain>`).

## 3. Lancer l'application Flutter

Dans un second terminal :

```bash
cd flutter_app
flutter clean
flutter pub get
flutter run
```

Choisir son appareil (téléphone physique connecté en USB avec le débogage USB activé, ou émulateur) si plusieurs cibles sont proposées.

## 4. Comptes de test

| Email | Mot de passe |
|---|---|
| daniel.xavier@example.com | azerty123 |
| karim.benali@example.com | motdepasse2 |

## 5. Parcours de test conseillé

1. Se connecter avec un compte valide → arrivée sur la liste des produits.
2. Se connecter avec un mauvais mot de passe → message d'erreur affiché.
3. Filtrer les produits par catégorie.
4. Ouvrir le détail d'un produit.
5. Se déconnecter → retour à l'écran de connexion.
6. Fermer complètement l'application et la rouvrir → reconnexion automatique, sans repasser par l'écran de connexion.

## Problèmes courants

| Problème | Cause probable | Solution |
|---|---|---|
| L'app ne charge jamais les produits (roue de chargement infinie) | Le téléphone ne peut pas joindre le serveur | Vérifie que le PC et le téléphone sont sur le même Wi-Fi, et que `baseUrl` utilise bien l'IP locale (pas `localhost`) |
| Erreur réseau au démarrage de l'app | Trafic HTTP bloqué par Android | Vérifie `network_security_config.xml` et sa référence dans `AndroidManifest.xml` |
| Le téléphone ne trouve pas le serveur malgré une IP correcte | Pare-feu Windows bloque le port | Autorise le port 5000 en entrée dans le pare-feu Windows Defender |
| `ModuleNotFoundError` au lancement du serveur | Dépendances non installées sur l'interpréteur utilisé | Relance `pip install -r requirements.txt` dans le terminal (pas seulement dans l'IDE) |

## Stack technique

- **Backend** : Python, Flask, Flask-CORS
- **Frontend** : Flutter, package `http`, package `shared_preferences`
