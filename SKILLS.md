# Technology Stack & Capabilities (SKILLS.md)

This document catalogs the exact technology stack, software development kits (SDKs), dependency packages, design architectures, and setup configurations used to implement the Digital Wedding Invitation builder.

---

## 🛠️ Core Technology Stack

* **Framework**: Flutter Web (Targeting responsive desktop, tablet, and mobile browsers)
* **SDK Version**: Flutter SDK `3.44.0` • Dart SDK `3.12.0` (Stable channel)
* **Execution Environment**: Chrome, Edge, Safari, Firefox web environments

---

## 📦 Dependency Packages

We use the following production-grade, stable packages to construct our application architecture:

| Package | Version | Purpose |
| :--- | :--- | :--- |
| `provider` | `^6.1.2` | State Management & Dependency Injection for ViewModels |
| `go_router` | `^14.2.0` | Declarative Routing & Web URL navigation mapping |
| `screenshot` | `^3.0.0` | Rendering widgets into high-resolution PNG image bytes |
| `shared_preferences` | `^2.2.3` | Local key-value store for storing and retrieving invitation data |
| `uuid` | `^4.3.3` | Generating cryptographically secure unique IDs for shareable URLs |
| `intl` | `^0.19.0` | DateTime formatting for displaying elegant wedding dates |

---

## 🏗️ Design Patterns & Architecture

### 1. MVVM (Model-View-ViewModel) Pattern
* **Model**: Represents raw structures (`InvitationModel`, `TemplateModel`). Free from state-management hooks or rendering logic.
* **View**: Consists of pure UI widgets. Listens to ViewModels for data states. Dispatches user interactions back to ViewModels.
* **ViewModel**: Coordinates presentation logic. Extends `ChangeNotifier`. Modifies internal states, interacts with service layers, and calls `notifyListeners()` to rebuild the listening views.

### 2. Service Locator / Dependency Injection
* Utilizing `Provider` as a dependency injection wrapper to supply ViewModels and Service instances downstream in the widget tree.

### 3. Repository & Service Layer Pattern
* Abstracting database/storage actions (`InvitationRepository`) and image rendering actions (`ExportService`) to maintain strict separation of concerns.

---

## 💻 Development & System Setup

To run or build this application locally, ensure your environment meets the following baseline requirements:

1. **Flutter SDK Setup**:
   Ensure Flutter `3.44.0` or higher is installed:
   ```bash
   flutter --version
   ```
2. **Web Build Enabling**:
   Verify web support is active:
   ```bash
   flutter devices
   # Chrome should be listed as a connected device
   ```
3. **Download Project Dependencies**:
   Run the package downloader inside the root folder:
   ```bash
   flutter pub get
   ```
4. **Local Execution**:
   Start a local dev server with auto-reloading:
   ```bash
   flutter run -d chrome
   ```
5. **Release Production Build**:
   To compile the optimized web bundle:
   ```bash
   flutter build web --release
   ```
