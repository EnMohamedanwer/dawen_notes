 Notes App
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
├── core/                          # Shared utilities, constants, theme
├── features/
│   ├── lock/
│   │   └── presentation/
│   │       ├── pages/             # AppLockPage
│   │       └── widgets/           # PinPad widget
│   ├── notes/
│   │   ├── data/                  # Data sources, models, repositories impl
│   │   ├── domain/                # Entities, use cases, repository contracts
│   │   └── presentation/          # UI, BLoC/Cubit
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
│           ├── pages/             # SettingsPage, AboutPage
│           └── widgets/
├── injection_container.dart       # Dependency injection setup
└── main.dart

🛠️ Tech Stack
LayerTechnologyFrameworkFlutterLanguageDartState ManagementBLoC / CubitArchitectureClean ArchitectureDependency Injectionget_it

