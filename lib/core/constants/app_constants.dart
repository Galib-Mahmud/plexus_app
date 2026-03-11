class AppConstants {
  static const String adminEmail = 'admin@plexus.com';
  static const String adminPassword = 'password123';
  static const Duration pollInterval = Duration(seconds: 5);
  static const Duration alertInterval = Duration(seconds: 7);
}

class HiveKeys {
  static const String dashboardBox = 'noc_dashboard';
  static const String devicesBox = 'noc_devices';
  static const String alertsBox = 'noc_alerts';
  static const String settingsBox = 'noc_settings';
  static const String metricsKey = 'metrics';
  static const String devicesKey = 'devices_list';
  static const String alertsKey = 'alerts_list';
  static const String loggedInKey = 'is_logged_in';
}

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String deviceDetail = '/device-detail';
}
