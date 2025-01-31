# Megafonito - Frontend (Flutter)

This README will guide you through the frontend setup for the Megafonito app.

## Requisites

- Flutter 3.19.5+ ([VSCode install recommended](https://docs.flutter.dev/get-started/install/windows/mobile))
- Android Studio ([Android Studio Website](https://developer.android.com/studio?_gl=1*kl6r1q*_up*MQ..&gclid=Cj0KCQiAhvK8BhDfARIsABsPy4gjQp6afGZmRLe9BfikRuGRt5FtpKKo2xQ2O24Q-PfzddGL0Q_3YTwaAj_4EALw_wcB&gclsrc=aw.ds))
- Java JDK 17 - LTS ([Temurin by Adoption](https://adoptium.net/es/temurin/archive/?version=17) version recommmended)
- Docker ([Desktop version for Windows and Mac users](https://www.docker.com/products/docker-desktop/))

---

## Configuration disclaimers

In this repository, only the essential files for the app use are contained, many files must be manually created with the console commands explained below.

---

## Initial configuration

1. Clone the repository:

   ```bash
   mkdir Megafonito
   cd Megafonito
   git clone https://github.com/PowerMonk/Megafonito_Project.git
   cd Megafonito/frontend
   ```

2. Create the rest of the files

#### Generate the missing files (android/app/, ios/, etc.)

```bash
flutter create .
```

#### Install dependencies

```bash
flutter pub get
```

#### Locally run the app (first time might take some minutes)

```bash
flutter run
```
