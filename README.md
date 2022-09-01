# EzStudies [![Github All Releases](https://img.shields.io/github/downloads/Klbgr/EzStudies-Flutter/latest/total.svg)](https://github.com/Klbgr/EzStudies-Flutter/releases/latest)

Ease your studies
(English version below)

## Introduction

Ce projet une évolution de [EzStudies](https://github.com/Klbgr/EzStudies) et à pour but de simplifier le quotidien des étudiants de CY Cergy Paris Université.

Comparé à la version précédente, cette version comporte de nombreuses différences. Les pricipales sont que celle-ci est une application Flutter, donc réalisée en Dart, et qu'elle est disponible sur Android, iOS et Web.

## Fonctionnalités

- Consultation de son emploi du temps via l'API de l'ENT de l'université, avec stockage hors ligne
- Consultation de l'emploi du temps des autres étudiants de l'université
- Connexion à l'application avec ses identifiants de l'ENT de l'université
- Communications sécurisées avec une API personnalisée pour réduire l'utilisation du processeur de l'appareil
- Stockage sécurisé des identifiants de l'ENT pour communiquer avec l'API
- Gestion de l'emploi du temps, comprenant ajout, modification et suppression de cours
- Gestion des devoirs, comprenant ajout, modification et suppression de devoirs
- Notifications pour les cours et/ou les devoirs
- Interface inspirée de Material You, avec thème clair et thème sombre
- Application en Anglais et en Français
- Et plus encore

## Téléchargement

Vous pouvez soit installer vous même les différents fichiers situés dans la section [Releases](https://github.com/Klbgr/EzStudies-Flutter/releases), soit utiliser l'[intallateur en ligne](https://ezstudies.alwaysdata.net/install).
La version Web est accéssible à [cette adresse](https://ezstudies.alwaysdata.net/).

## API

Le code source de l'API personnalisée, utilisée pour faire fonctionner cette application, se trouve dans le dossier `EzStudies-Flutter/web/api`. L'API est incluse dans ce projet pour facilliter le déploiement de l'application Web.

## Compilation

### Prérequis :
- Android Studio (avec les plugins requis pour Flutter)
- Flutter SDK
- FireBase CLI (optionnel)

Note : L'application est liée à FireBase dans l'unique but de profiter de FireBase Crashlitics. FireBase est donc optionnel au fonctionnement de l'application.

### Pour compiler l'application, il faut d'abord :
- Lier l'application à FireBase ou supprimer l'implémentation de FireBase
- Renseigner les variables d'environnement dans le fichier `/EzStudies-Flutter/.env`
```ini
SERVER_URL = "xxx"  
CIPHER_KEY = "xxx"  
```  
où `SERVER_URL` est l'URL de l'API personnalisée et `CIPHER_KEY` est la clé de chiffrement utilisée pour chiffrer et déchiffrer les identifiants de l'ENT
- Renseigner cette même clé de chiffrement dans le fichier `/EzStudies-Flutter/web/api/include/key`
```
xxx  
```
### Puis  :
- Générer les textes de l'application
```
flutter gen-l10n
```
Note : il faut utiliser cette commande après toutes modifications des fichiers `app_en.arb` ou `app_fr.arb`.
- Générer les variables d'environnement
```
flutter pub run build_runner build --delete-conflicting-outputs
```
Note : il faut utiliser cette commande après toutes modifications du fichier `.env`.
Enfin, l'application pourra être compilée et exécutée de façon habituelle.

# EzStudies (English)

Ease your studies

## Introduction

This project is an evolution of [EzStudies](https://github.com/Klbgr/EzStudies) and aims to simplify the daily lives of students of CY Cergy Paris Université.

Compared to the previous version, this one has many differences. The main differences are that this is a Flutter app, written in Dart, and that it's available for Android, iOS and Web.

## Features

- View your own agenda using the API of the ENT of the university, with offline storage
- View the agenda of other students of the university
- Log into the app with the credentials from the ENT of the university
- Secured communications with a customised API  to reduce the processor usage of the device
- Secured storage of credentials from the ENT of the university used to communicate with the custom API
- Manage your agenda, including adding, editing and deleting courses
- Manage your homeworks, including adding, editing and deleting homeworks
- Notifications for courses and/or homeworks
- Material You inspired interface, with light theme and dark theme
- Application in English and French
- And more

## Download

You can either download the files in the [Releases](https://github.com/Klbgr/EzStudies-Flutter/releases) section, or use the [online installer](https://ezstudies.alwaysdata.net/install).
The Web version is available at [this address](https://ezstudies.alwaysdata.net/).

## API

The source code of the custom API, used to make this app work, is located on the `EzStudies-Flutter/web/api` folder. The API is included in this procjet ease the deployment of the Web app.

## Compilation

### Prerequisites :
- Android Studio (with plugins required for Flutter)
- Flutter SDK
- FireBase CLI (optional)

Note : The app is linked to FireBase for the sole purpose of using FireBase Crashlytics. So FireBase optional to make the app work.

### Before compiling the app, you have to :
- Link the app to FireBase or delete the implementation of FireBase
- Type in environment variables in the `/EzStudies-Flutter/.env` file
```ini
SERVER_URL = "xxx"  
CIPHER_KEY = "xxx"  
```  
where `SERVER_URL` is the URL of the custom API and `CIPHER_KEY` cipher key used to encrypt and decrypt the credentials of the ENT
- Type in the same key in the `/EzStudies-Flutter/web/api/include/key` file
```
xxx  
```
### Then  :
- Generated texts of the app
```
flutter gen-l10n
```
Note : you have to use this command each time you edit the files `app_en.arb` or `app_fr.arb`.
- Generated environment variables
```
flutter pub run build_runner build --delete-conflicting-outputs
```
Note : you have to use this command each time you edit the `.env` file.
Finally, the app can be compiled and executed as usual.