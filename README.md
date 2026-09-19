# Step Counter & Walking Goals

A privacy-friendly Flutter application for Android that helps users track their daily physical activity and stay motivated toward a healthier lifestyle. The app uses the device's built-in motion and activity sensors to automatically count steps, with no external hardware, wearables, or manual logging required.

## Overview

Step Counter & Walking Goals lets users set a personal daily step goal and visualize their progress in real time through a progress ring on the home dashboard. Alongside the live step count, the app estimates distance walked and maintains a running history of past days, giving users insight into both daily activity and long-term consistency.

To encourage habit-building, the app includes a streak system that tracks consecutive days a goal has been met, along with a weekly chart that visualizes step trends. A lightweight reminder notification nudges users who are falling behind their daily target, and an optional data export feature allows users to save or share their walking history outside the app.

The app is deliberately minimal: no user account, no sign-up, and no social features. All step data is stored locally on the user's device, making the app privacy-respecting by default while still delivering real, everyday value.

This project was built as a semester project for a Mobile Application Development course.

## Features

- Automatic step counting using native device sensors
- Custom daily step goal configuration
- Real-time progress visualization with a home dashboard progress ring
- Estimated distance walked
- Historical log of daily step counts
- Streak tracking for consecutive goal completions
- Weekly step trend chart
- Reminder notifications for users falling behind their goal
- Local data export/sharing of walking history
- Fully offline, on-device data storage with no account or sign-up required

## Tech Stack

### Core

- **Flutter** - Cross-platform UI toolkit used to build the application
- **Dart** - Programming language used throughout the app

### Platform

- **Android** - Sole target platform for this project (iOS, web, and desktop targets are excluded)
- **Kotlin** - Android platform-specific native code (`MainActivity`)
- **Gradle** - Android build system

### Planned Packages and Tools

- **Sensors package** (e.g. `sensors_plus` / `pedometer`) - Access to device accelerometer and step-detection APIs
- **Local storage** (e.g. `sqflite` / `hive` / `shared_preferences`) - On-device persistence for step history, goals, and settings
- **State management** (e.g. `provider` / `riverpod` / `bloc`) - Application state handling
- **Charting library** (e.g. `fl_chart` / `syncfusion_flutter_charts`) - Weekly step trend visualization
- **Local notifications** (e.g. `flutter_local_notifications`) - Daily goal reminder nudges
- **File/data export** (e.g. `share_plus` / `csv`) - Exporting and sharing walking history

### Tooling

- **Flutter SDK** (^3.13.2 Dart SDK constraint)
- **flutter_lints** - Static analysis and recommended lint rules
- **Android Studio / VS Code** - Development environment
- **Git & GitHub** - Version control and source hosting

## Project Structure

```
lib/
  core/
    constants/       Application-wide constant values
    theme/            App theming and styling
    utils/            Shared utility/helper functions
    services/         Sensor, notification, and other platform services
  data/
    models/           Data models (step entries, goals, streaks)
    repositories/      Data access layer
    local/            Local persistence implementation
  features/
    home/             Home dashboard with live step count and progress ring
    history/          Historical step data views
    streak/           Streak tracking logic and UI
    goals/            Daily goal configuration
    settings/         App settings and preferences
    export/           Data export and sharing
  widgets/            Shared, reusable UI components
assets/
  images/             Image assets
  icons/              Icon assets
```

## Getting Started

### Prerequisites

- Flutter SDK (^3.13.2 or later)
- Android Studio or VS Code with the Flutter/Dart plugins
- An Android device or emulator running Android 5.0 (API 21) or higher

### Setup

1. Clone the repository:
   ```
   git clone https://github.com/Abdullah-819/Fitness-App-Flutter.git
   ```
2. Navigate into the project directory:
   ```
   cd Fitness-App-Flutter
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the application on a connected Android device or emulator:
   ```
   flutter run
   ```

## Platform Scope

This application targets Android exclusively. iOS, web, Windows, macOS, and Linux platform folders are intentionally not included, as this project is not intended for cross-platform distribution.

## Privacy

All step, goal, streak, and history data is stored locally on the user's device. The application does not require an account, does not include social or networked features, and does not transmit user data to any external server.

## License

This project was developed for academic purposes as part of a Mobile Application Development course.
