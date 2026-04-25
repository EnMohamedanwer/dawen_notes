📝 Notes App
A secure and feature-rich notes application built with Flutter, following Clean Architecture principles and BLoC/Cubit state management.

✨ Features

📋 Create & Manage Notes — Write, edit, and organize your notes effortlessly
🔒 App Lock — Protect your notes with a PIN pad for extra privacy
👤 User Profile — Personalized profile management
⚙️ Settings — Customize your experience with a dedicated settings page
ℹ️ About Page — App info and version details


🏗️ Architecture
This project follows Clean Architecture with a clear separation of concerns:
lib/
├── core/
├── features/
│   ├── lock/
│   │   └── presentation/
│   │       ├── pages/        # AppLockPage
│   │       └── widgets/      # PinPad
│   ├── notes/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── profile/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── cubit/
│   │       └── pages/
│   └── settings/
│       └── presentation/
│           ├── pages/        # SettingsPage, AboutPage
│           └── widgets/
├── injection_container.dart
└── main.dart
