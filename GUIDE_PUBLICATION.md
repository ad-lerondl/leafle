# Publication de Leafle

## Site Netlify

Le fichier `netlify.toml` configure automatiquement le site `https://alapps-leafle.netlify.app` :

- `flutter build web --release` construit l'application Web à la racine `/` ;
- `web-pages/privacy` est publié à `/privacy/` ;
- `web-pages/download` est publié à `/download/` ;
- les routes Flutter inconnues retombent sur `index.html`.

Dans Netlify, créer un site depuis le dépôt Git et laisser les réglages de build définis par `netlify.toml`. Le répertoire publié est `build/web`. Le script installe Flutter stable dans l'environnement de build si nécessaire.

## Android : APK direct

Un APK distribué en dehors du Play Store doit être signé avec une clé privée de release. Ne jamais committer cette clé ni `android/key.properties`.

1. Générer une clé une seule fois :

```powershell
keytool -genkeypair -v -keystore leafle-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias leafle
```

2. Créer `android/key.properties` localement :

```properties
storePassword=VOTRE_MOT_DE_PASSE
keyPassword=VOTRE_MOT_DE_PASSE
keyAlias=leafle
storeFile=C:/chemin/vers/leafle-upload.jks
```

3. Construire l'APK signé :

```powershell
flutter build apk --release
```

Le fichier est généré dans `build/app/outputs/flutter-apk/app-release.apk`. Pour le rendre téléchargeable, créer `web-pages/download/downloads/` puis y copier le fichier sous le nom `leafle.apk`, avant de redéployer Netlify. Le script le publiera à `/downloads/leafle.apk`. Cette étape doit être faite uniquement après vérification de l'APK.

## Google Play

Pour le Play Store, utiliser plutôt un App Bundle :

```powershell
flutter build appbundle --release
```

Le fichier `build/app/outputs/bundle/release/app-release.aab` est envoyé dans Google Play Console. Google Play recommande de conserver la clé de signature hors du dépôt et de protéger sa sauvegarde.

## Versioning

Avant chaque publication, augmenter `version:` dans `pubspec.yaml`, par exemple `1.0.1+2`. Le nombre après `+` doit toujours augmenter pour une nouvelle version Android.

## Vérifications locales

```powershell
flutter analyze
flutter test
flutter build web --release --base-href=/
```

Les notifications locales fonctionnent sur Android/iOS. Elles ne sont pas un mécanisme de notification Web Netlify.