# flutter_base_app

Base Flutter app template with a complete, production-ready auth system.

## Included

- **Clean Architecture** (domain / infrastructure / presentation) per feature
- **Riverpod** state management
- **go_router** navigation with auth redirect guards
- **Full Auth feature**: email/password login & register, Google Sign-In, Apple Sign-In, token refresh, password recovery (OTP flow)
- **Firebase** (Auth + Messaging)
- **Dio** HTTP client with auth interceptor (auto token refresh on 401)
- **Formz** form validation (email, password, name, username, gender, date of birth, T&C)
- **SharedPreferences** key-value storage abstraction
- **Environment** config via `.env`
- Custom theme, fonts (Avenir family + Nohemi), splash screen, onboarding skeleton
- Placeholder `home` feature ready to build on

## Setup

1. Copy `.env.template` to `.env` and fill in `API_URL`
2. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Run `flutterfire configure` and add the generated `lib/firebase_options.dart`
4. Add your app assets to `assets/` (see `pubspec.yaml` for expected paths)
5. Copy fonts to `fonts/`
6. Run `flutter pub get`

## Architecture

```
lib/
├── main.dart
├── firebase_options.dart          # Generated — NOT committed
├── config/
│   ├── const/environment.dart     # .env loader
│   ├── router/                    # go_router + auth redirect
│   └── theme/app_theme.dart
└── features/
    ├── auth/                      # Full auth feature
    ├── home/                      # Placeholder — build here
    └── shared/                    # Inputs, services, widgets, interceptor
```
