## 📝 Notes App

A secure and feature-rich notes application built with Flutter, following Clean Architecture principles and BLoC/Cubit state management.

---

## ✨ Features

* 📋 **Create & Manage Notes** — Write, edit, and organize your notes effortlessly
* 🔒 **App Lock** — Protect your notes with a PIN pad for extra privacy
* 👤 **User Profile** — Personalized profile management
* ⚙️ **Settings** — Customize your experience with a dedicated settings page
* ℹ️ **About Page** — App info and version details

---

## 🏗️ Architecture

This project follows **Clean Architecture** with clear separation of concerns:

```
lib/
├── core/                # Shared utilities, constants, theme
├── features/
│   ├── lock/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── notes/
│   │   ├── data/        # Data sources, models, repositories implementation
│   │   ├── domain/      # Entities, use cases, repository contracts
│   │   └── presentation/# UI, BLoC/Cubit
│   │
│   ├── profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── settings/
│       └── presentation/
│           ├── pages/
│           └── widgets/
│
├── injection_container.dart  # Dependency Injection setup
└── main.dart
```

---

## 🛠️ Tech Stack

* **Flutter**
* **Dart**
* **BLoC / Cubit**
* **Clean Architecture**
* **get_it (Dependency Injection)**
