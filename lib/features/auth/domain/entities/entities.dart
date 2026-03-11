import 'package:equatable/equatable.dart';

// ─── User ─────────────────────────────────────────────────────────────────────
class User extends Equatable {
  final String email;
  final String name;
  final String role;
  const User({required this.email, required this.name, required this.role});
  @override List<Object?> get props => [email, name, role];
}

// ─── Device ───────────────────────────────────────────────────────────────────
enum DeviceStatus { online, offline }

class Device extends Equatable {
  final String id;
  final String name;
  final String ipAddress;
  final String location;
  final DeviceStatus status;
  final DateTime lastPingTime;
  final double cpuUsage;
  final double memoryUsage;
  final List<double> cpuHistory;
  final List<double> memoryHistory;

  const Device({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.location,
    required this.status,
    required this.lastPingTime,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.cpuHistory,
    required this.memoryHistory,
  });

  bool get isOnline => status == DeviceStatus.online;

  Device copyWith({
    DeviceStatus? status,
    DateTime? lastPingTime,
    double? cpuUsage,
    double? memoryUsage,
    List<double>? cpuHistory,
    List<double>? memoryHistory,
  }) => Device(
    id: id, name: name, ipAddress: ipAddress, location: location,
    status: status ?? this.status,
    lastPingTime: lastPingTime ?? this.lastPingTime,
    cpuUsage: cpuUsage ?? this.cpuUsage,
    memoryUsage: memoryUsage ?? this.memoryUsage,
    cpuHistory: cpuHistory ?? this.cpuHistory,
    memoryHistory: memoryHistory ?? this.memoryHistory,
  );

  @override List<Object?> get props => [id, status, cpuUsage, memoryUsage];
}

// ─── Dashboard Metrics ────────────────────────────────────────────────────────
class DashboardMetrics extends Equatable {
  final int total;
  final int online;
  final int offline;
  final int alerts;
  final DateTime? lastUpdated;

  const DashboardMetrics({
    required this.total,
    required this.online,
    required this.offline,
    required this.alerts,
    this.lastUpdated,
  });

  double get healthPercent => total > 0 ? (online / total) * 100 : 0;

  @override List<Object?> get props => [total, online, offline, alerts];
}

// ─── Alert ────────────────────────────────────────────────────────────────────
enum AlertSeverity { critical, warning, info }

class AlertEntity extends Equatable {
  final String id;
  final String deviceName;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isRead;

  const AlertEntity({
    required this.id,
    required this.deviceName,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
  });

  @override List<Object?> get props => [id, isRead];
}
