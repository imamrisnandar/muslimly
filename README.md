# Muslimly - Daily Islamic Companion App

Muslimly is a modern, premium-designed Flutter application dedicated to supporting daily Islamic activities. It provides accurate Prayer Times, a comprehensive Al-Quran reading experience (Mushaf Madinah), and tools for tracking daily worship habits.

Built with **Clean Architecture** and **Flutter Bloc**, aiming for high performance, offline capability, and a beautiful user interface.

## ✨ Key Features

### 🕌 Prayer Times & Notifications

- **Accurate Schedule**: Calculates prayer times based on user location (GPS).
- **Adhan Notifications**: Customizable alerts (Adhan Audio, Beep, or Silent) for each prayer time.
- **Hijri Calendar**: Displays the current Islamic Date.
- **Next Prayer Countdown**: Hero widget on dashboard showing time remaining for the next prayer.
- **Imsak & Sunrise**: Essential times for fasting and Dhuha.

### 📖 Al-Quran (Mushaf Madinah)

- **Mushaf View**: Authentic page-turning experience similar to a physical Quran (Madinah Layout).
- **Vector-Based Rendering**: High-quality Arabic text using vector fonts for perfect scaling on any device.
- **Interactive Ayah**: Tap on any Ayah to see options or translations (Expandable).
- **Offline Mode**: Full Quran data is bundled locally; no internet required for reading.
- **Reading History**: Automatically tracks time spent, pages read, and recent sessions.
- **Bookmarks**: Save pages to resume reading later.
- **Daily Targets**: Set reading goals (e.g., 4 pages/day) and track progress on the dashboard.

### ⚙️ Personalization

- **Localization**: Full support for **English** and **Indonesian**.
- **Onboarding**: Personalized name input for a welcoming dashboard experience.
- **Theme**: Sleek Dark Mode optimized for reading comfort.

## 🛠️ Technology Stack

| Category             | Library                         | Purpose                                             |
| :------------------- | :------------------------------ | :-------------------------------------------------- |
| **Framework**        | Flutter                         | Cross-platform UI Toolkit                           |
| **State Management** | `flutter_bloc`                  | Predictable state & Business Logic Component (BLoC) |
| **Architecture**     | Clean Architecture              | Separation of concerns (Domain, Data, Presentation) |
| **DI**               | `get_it`                        | Service Locator / Dependency Injection              |
| **Navigation**       | `go_router`                     | Declarative routing and deep linking                |
| **Local DB**         | `sqflite`                       | Relational database for Bookmarks & History         |
| **Preferences**      | `shared_preferences`            | Simple key-value storage for settings               |
| **Notifications**    | `flutter_local_notifications`   | Scheduled alarms for Prayer Times                   |
| **Location**         | `geolocator`                    | GPS data for prayer calculation                     |
| **Timezone**         | `timezone` + `flutter_timezone` | Accurate local time handling                        |

## � Getting Started

### Prerequisites

- Flutter SDK (3.x or later)
- Android Studio / VS Code
- JDK 11+ (for Android Build)

### Installation

1.  **Clone the Repository**

    ```bash
    git clone https://github.com/yourusername/muslimly.git
    cd muslimly
    ```

2.  **Install Dependencies**

    ```bash
    flutter pub get
    ```

3.  **Run the App**
    Connect your device or emulator and run:
    ```bash
    flutter run
    ```

### ⚠️ Important Note on Notifications (Android)

On newer Android versions (12+), scheduled alarms for Prayer Times require the **"Alarms & Reminders"** permission.
If notifications do not appear:

1.  Go to **Settings > Apps > Muslimly**.
2.  Enable **"Allow Alarms & Reminders"**.
3.  Ensure **Battery Optimization** is set to "Unrestricted" for reliable background wake-ups.

## 📂 Project Structure

```text
lib/
├── src/
│   ├── config/           # App Configuration (Routes, Themes)
│   ├── core/             # Shared Utilities (DI, Network, Extensions)
│   ├── features/         # Feature Modules
│   │   ├── dashboard/    # Home Screen & Navigation
│   │   ├── prayer/       # Prayer Times Logic & UI
│   │   ├── quran/        # Al-Quran Reading Engine, Data, UI
│   │   ├── settings/     # App Settings & Localization
│   │   └── intro/        # Splash & Onboarding
│   └── l10n/             # ARB Files for Localization
└── main.dart             # App Entry Point
```

## 📜 License

This project is for educational and personal use. Asset attributions (Fonts/Images) belong to their respective owners.
