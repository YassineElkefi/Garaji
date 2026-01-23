# 🚗 Garaji

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

Garaji is a sleek, user-friendly mobile application for personal vehicle management. Effortlessly track your vehicles, log maintenance activities, and stay ahead with smart health insights. Built with Flutter for seamless cross-platform experience on iOS and Android.

## ✨ Features

### 🏎️ Vehicle Management
- **Add Vehicles**: Store detailed info like make, model, year, VIN, and custom notes.
- **Vehicle Dashboard**: Quick overview of all your vehicles in one place.

### 🔧 Maintenance Tracking
- **Maintenance Logs**: Record with categories, dates, mileage, costs, and notes.
- **Timeline View**: Interactive chronological history of all maintenance.
- **Smart Date Picker**: Intuitive calendar for scheduling and logging.
- **Mileage Integration**: Automatic mileage tracking and alerts.

### 🧠 Smart Extras
- **Recommended Repairs**: AI-like suggestions for upcoming maintenance based on standards.
- **Mileage Warnings**: Proactive alerts for oil changes, inspections, and more.
- **PDF Export**: (Coming Soon) Generate reports for sharing or archiving.

### 📊 Statistics (Future Feature)
- **Total Cost**: Aggregate expenses per vehicle.
- **Monthly Breakdown**: Visualize spending trends.
- **Top Repairs**: Highlight the most costly fixes.

## 📸 Screenshots

| Home Screen | Vehicle Details | Maintenance Log |
|-------------|-----------------|-----------------|
| ![Home](screenshots/home.png) | ![Details](screenshots/details.png) | ![Log](screenshots/log.png) |

*(Screenshots will be added as the app develops)*

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.0+)
- Dart SDK
- IDE: Android Studio / VS Code / Xcode

### Installation
1. **Clone the repo**:
   ```bash
   git clone https://github.com/YassineElkefi/Garaji.git
   cd Garaji
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

### Build for Release
- **Android APK**: `flutter build apk --release`
- **iOS App**: `flutter build ios --release`

## 📖 Usage Guide

1. **Launch Garaji** on your device.
2. **Add Your First Vehicle** via the + button – enter details and save.
3. **Log Maintenance** by selecting a vehicle and adding entries with date, mileage, and cost.
4. **Explore Timeline** to review history and upcoming tasks.
5. **Stay Smart** with warnings and recommendations popping up as needed.

## 🏗️ Project Structure

```
lib/
├── core/
│   └── utils/
│       └── date_formatter.dart
│
├── data/
│   └── models/
│       ├── vehicle.dart
│       └── maintenance_entry.dart
│
├── providers/
│   ├── vehicle_provider.dart
│   └── maintenance_provider.dart
│
├── features/
│   └── vehicles/
│       ├── screens/
│       │   └── vehicles_list_screen.dart
│       └── widgets/
│
└── main.dart
```

## 🤝 Contributing

We love contributions! Here's how:
1. Fork the repo.
2. Create a branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push: `git push origin feature/amazing-feature`
5. Open a Pull Request.

## 🙏 Acknowledgments

- Powered by [Flutter](https://flutter.dev/)
- Icons from [Material Design](https://material.io/design/iconography/)

## 🔮 Roadmap

- [ ] Statistics dashboard
- [ ] PDF export
- [ ] API integrations for real-time vehicle data
- [ ] Offline mode
- [ ] Localization

## 📄 Author
- Yassine Elkefi - [GitHub](https://github.com/YassineElkefi)