# 🛰️ Plexus NOC — GetX Edition
### Real-Time Network Monitoring App · Flutter + GetX + Glassmorphism

---

## 🎨 Design Philosophy
**Deep Space Glassmorphism** — A NOC that feels like a sci-fi command center:
- `BackdropFilter` blur cards with layered transparency
- Animated neon glow orbs as atmospheric background elements
- Hexagonal grid overlay for a technical aesthetic
- Pulsing status indicators with `BoxShadow` glow
- `Syne` (display) + `DM Sans` (body) typography pairing
- Electric cyan/blue neon palette on deep void background

---

## 🏗️ Architecture — Clean Architecture + GetX

```
lib/
├── core/
│   ├── constants/       app_constants.dart  (HiveKeys, AppRoutes, AppConstants)
│   ├── error/           failures.dart        (Failure, AppException hierarchy)
│   ├── network/         network_service.dart (GetxService connectivity watcher)
│   ├── theme/           app_theme.dart       (AppColors, AppTheme)
│   └── widgets/         glass_widgets.dart   (GlassCard, NeonButton, StatusDot, ...)
│
└── features/
    ├── auth/
    │   ├── data/datasources/    mock_data_service.dart  (MockDataService singleton)
    │   ├── domain/entities/     entities.dart            (User, Device, DashboardMetrics, AlertEntity)
    │   └── presentation/
    │       ├── controllers/     auth_controller.dart     (GetxController)
    │       └── pages/           login_page.dart
    │
    ├── dashboard/
    │   └── presentation/
    │       ├── controllers/     dashboard_controller.dart
    │       └── pages/           dashboard_page.dart, home_tab.dart
    │
    ├── devices/
    │   └── presentation/
    │       ├── controllers/     devices_controller.dart
    │       └── pages/           devices_page.dart, device_detail_page.dart
    │
    └── alerts/
        └── presentation/
            ├── controllers/     alerts_controller.dart
            └── pages/           alerts_page.dart
```

---

## 🚀 Features

### ✅ Authentication
- Glassmorphism login with animated floating card
- Animated neon background orbs + hexagonal grid
- Form validation with beautiful error states
- Demo: `admin@plexus.com` / `password123`

### ✅ Dashboard (Real-Time, every 5s)
- Live metrics: Total / Online / Offline / Alerts
- Pulsing neon glow on alert/offline counts
- Donut chart with animated health percentage
- Recent alerts feed + offline device list

### ✅ Device Monitoring
- 24 simulated network devices (Routers, Switches, Servers...)
- **Real-time status updates** — devices toggle online/offline every 5s
- **Search** by name, IP, location
- **Filter** chips: All / Online / Offline
- **Pull to refresh**

### ✅ Device Detail
- Live-updating device (subscribes to stream)
- CPU + Memory usage cards with color thresholds
- Gradient line charts (fl_chart) with fill area
- Complete device info grid

### ✅ Real-Time Alerts
- New alert every ~7s via stream
- **GetX Snackbar** popup — glassmorphism style with neon border
- Badge count on bottom nav tab
- Severity: Critical / Warning / Info

### ✅ Offline Mode
- Hive caching of devices + alerts
- Shows cached data when disconnected

### ✅ Dark Mode
- Fully themed dark glassmorphism UI

---

## 🛠️ Tech Stack

| | Package |
|--|--|
| State Management | `get ^4.6.6` |
| Local Storage | `hive + hive_flutter` |
| Charts | `fl_chart` |
| Network Detection | `connectivity_plus` |
| UI Effects | `BackdropFilter` + `RadialGradient` |
| Typography | `google_fonts` (Syne + DM Sans) |

---

## ⚙️ Setup

```bash
git clone <repo-url>
cd noc_getx
flutter pub get
flutter run
```

### Build
```bash
flutter build apk --release   # Android
flutter build ios --release    # iOS
```

---

## 🔄 GetX Reactive Pattern

```dart
// Controller
class DevicesController extends GetxController {
  final devices = <Device>[].obs;   // RxList
  final isLoading = true.obs;       // RxBool

  @override
  void onInit() {
    super.onInit();
    _sub = MockDataService().watchDevices().listen(
      (list) => devices.value = list,
    );
  }
}

// UI — auto-rebuilds on change
Obx(() {
  final devices = Get.find<DevicesController>().devices;
  return ListView.builder(itemCount: devices.length, ...);
})
```

---

## 📐 SOLID Principles

| Principle | Applied |
|--|--|
| **S**ingle Responsibility | Controllers only manage state; MockDataService only provides data |
| **O**pen/Closed | New data sources can be swapped without changing controllers |
| **L**iskov | All GetxController subclasses are interchangeable |
| **I**nterface Segregation | Separated read/write concerns |
| **D**ependency Inversion | `Get.find<T>()` decouples UI from controllers |
