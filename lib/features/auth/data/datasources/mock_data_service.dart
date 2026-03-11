import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';


class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal() {
    _devices = _generateDevices();
  }

  final Random _rng = Random();
  late List<Device> _devices;
  int _online = 19;
  int _offline = 5;
  int _alertCount = 3;
  List<AlertEntity> _alerts = [];

  StreamController<List<Device>>? _devicesCtrl;
  StreamController<DashboardMetrics>? _dashCtrl;
  StreamController<List<AlertEntity>>? _alertsCtrl;
  Timer? _deviceTimer;
  Timer? _dashTimer;
  Timer? _alertTimer;

  // ─── Device Generation ─────────────────────────────────────────────────
  List<Device> _generateDevices() {
    const types = ['Router', 'Switch', 'Firewall', 'Server', 'Load Balancer', 'Access Point'];
    const locations = [
      'DC Alpha — Rack A1', 'DC Alpha — Rack B3', 'DC Beta — Rack C2',
      'Server Room 1F', 'Server Room 2F', 'Branch NYC',
      'Branch LA', 'Branch Chicago', 'Cloud US-East',
      'Cloud EU-West', 'Edge Node A', 'DMZ Zone',
    ];

    return List.generate(24, (i) {
      final type = types[i % types.length];
      final loc = locations[i % locations.length];
      final isOnline = _rng.nextDouble() > 0.2;
      final cpu = isOnline ? 8.0 + _rng.nextDouble() * 75 : 0.0;
      final mem = isOnline ? 15.0 + _rng.nextDouble() * 65 : 0.0;

      return Device(
        id: 'dev_$i',
        name: '$type ${String.fromCharCode(65 + i ~/ 6)}${(i % 6 + 1).toString().padLeft(2, '0')}',
        ipAddress: '10.${(i ~/ 10) + 1}.${(i % 10) * 25 + 1}.${(i % 254) + 1}',
        location: loc,
        status: isOnline ? DeviceStatus.online : DeviceStatus.offline,
        lastPingTime: DateTime.now().subtract(Duration(seconds: _rng.nextInt(120))),
        cpuUsage: cpu,
        memoryUsage: mem,
        cpuHistory: List.generate(12, (_) => isOnline ? 5.0 + _rng.nextDouble() * 85 : 0.0),
        memoryHistory: List.generate(12, (_) => isOnline ? 10.0 + _rng.nextDouble() * 80 : 0.0),
      );
    });
  }

  void _seedAlerts() {
    _alerts = [
      AlertEntity(id: 'a1', deviceName: 'Router A01', message: 'Router A01 is offline', severity: AlertSeverity.critical, timestamp: DateTime.now().subtract(const Duration(minutes: 3))),
      AlertEntity(id: 'a2', deviceName: 'Server D03', message: 'Server D03 CPU exceeded 92%', severity: AlertSeverity.warning, timestamp: DateTime.now().subtract(const Duration(minutes: 11))),
      AlertEntity(id: 'a3', deviceName: 'Firewall C01', message: 'Firewall C01 memory pressure detected', severity: AlertSeverity.warning, timestamp: DateTime.now().subtract(const Duration(minutes: 25))),
    ];
  }

  void _updateDevices() {
    _devices = _devices.map((d) {
      final toggle = _rng.nextDouble() < 0.06;
      final newOnline = toggle ? !d.isOnline : d.isOnline;
      final newStatus = newOnline ? DeviceStatus.online : DeviceStatus.offline;
      final newCpu = newOnline ? (d.cpuUsage + _rng.nextDouble() * 12 - 6).clamp(3.0, 96.0) : 0.0;
      final newMem = newOnline ? (d.memoryUsage + _rng.nextDouble() * 8 - 4).clamp(8.0, 92.0) : 0.0;
      return d.copyWith(
        status: newStatus,
        lastPingTime: newOnline ? DateTime.now() : d.lastPingTime,
        cpuUsage: newCpu,
        memoryUsage: newMem,
        cpuHistory: [...d.cpuHistory.skip(1), newCpu],
        memoryHistory: [...d.memoryHistory.skip(1), newMem],
      );
    }).toList();
    _online = _devices.where((d) => d.isOnline).length;
    _offline = _devices.length - _online;
    _devicesCtrl?.add(List.from(_devices));
  }

  void _maybeAddAlert() {
    if (_rng.nextDouble() < 0.45) {
      final names = ['Router B02', 'Switch A03', 'Server E01', 'Access Point F03', 'Load Balancer B01'];
      final msgs = [
        '{d} went offline',
        '{d} CPU usage at 94%',
        '{d} high memory consumption',
        '{d} packet loss > 15%',
        '{d} connectivity restored',
      ];
      final sevs = [AlertSeverity.critical, AlertSeverity.warning, AlertSeverity.warning, AlertSeverity.warning, AlertSeverity.info];
      final idx = _rng.nextInt(msgs.length);
      final name = names[_rng.nextInt(names.length)];
      _alertCount++;
      final alert = AlertEntity(
        id: 'a_${DateTime.now().millisecondsSinceEpoch}',
        deviceName: name,
        message: msgs[idx].replaceAll('{d}', name),
        severity: sevs[idx],
        timestamp: DateTime.now(),
      );
      _alerts.insert(0, alert);
      if (_alerts.length > 50) _alerts.removeLast();
      _alertsCtrl?.add(List.from(_alerts));
      _cacheAlerts();
    }
  }

  // ─── Streams ───────────────────────────────────────────────────────────
  Stream<List<Device>> watchDevices() {
    _devicesCtrl?.close();
    _devicesCtrl = StreamController<List<Device>>.broadcast();
    _deviceTimer?.cancel();
    _devicesCtrl!.add(List.from(_devices));
    _deviceTimer = Timer.periodic(AppConstants.pollInterval, (_) => _updateDevices());
    return _devicesCtrl!.stream;
  }

  Stream<DashboardMetrics> watchDashboard() {
    _dashCtrl?.close();
    _dashCtrl = StreamController<DashboardMetrics>.broadcast();
    _dashTimer?.cancel();
    _emitDash();
    _dashTimer = Timer.periodic(AppConstants.pollInterval, (_) => _emitDash());
    return _dashCtrl!.stream;
  }

  Stream<List<AlertEntity>> watchAlerts() {
    if (_alerts.isEmpty) _seedAlerts();
    _alertsCtrl?.close();
    _alertsCtrl = StreamController<List<AlertEntity>>.broadcast();
    _alertTimer?.cancel();
    _alertsCtrl!.add(List.from(_alerts));
    _alertTimer = Timer.periodic(AppConstants.alertInterval, (_) => _maybeAddAlert());
    return _alertsCtrl!.stream;
  }

  void _emitDash() {
    _dashCtrl?.add(DashboardMetrics(
      total: _devices.length,
      online: _online,
      offline: _offline,
      alerts: _alertCount,
      lastUpdated: DateTime.now(),
    ));
  }

  // ─── One-shot ──────────────────────────────────────────────────────────
  Future<List<Device>> getDevices() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_devices);
  }

  Future<Device> getDeviceById(String id) async {
    return _devices.firstWhere((d) => d.id == id);
  }

  Future<DashboardMetrics> getMetrics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return DashboardMetrics(total: _devices.length, online: _online, offline: _offline, alerts: _alertCount, lastUpdated: DateTime.now());
  }

  // ─── Caching ──────────────────────────────────────────────────────────
  void _cacheAlerts() {
    try {
      final box = Hive.box(HiveKeys.alertsBox);
      final list = _alerts.map((a) => jsonEncode({
        'id': a.id, 'deviceName': a.deviceName, 'message': a.message,
        'severity': a.severity.index, 'timestamp': a.timestamp.toIso8601String(), 'isRead': a.isRead,
      })).toList();
      box.put(HiveKeys.alertsKey, list);
    } catch (_) {}
  }

  void cacheDevices(List<Device> devices) {
    try {
      final box = Hive.box(HiveKeys.devicesBox);
      final list = devices.map((d) => jsonEncode({
        'id': d.id, 'name': d.name, 'ip': d.ipAddress, 'location': d.location,
        'status': d.status.index, 'lastPing': d.lastPingTime.toIso8601String(),
        'cpu': d.cpuUsage, 'mem': d.memoryUsage, 'cpuH': d.cpuHistory, 'memH': d.memoryHistory,
      })).toList();
      box.put(HiveKeys.devicesKey, list);
    } catch (_) {}
  }

  List<Device> getCachedDevices() {
    try {
      final box = Hive.box(HiveKeys.devicesBox);
      final list = box.get(HiveKeys.devicesKey) as List<dynamic>?;
      if (list == null) return [];
      return list.map((e) {
        final m = jsonDecode(e as String) as Map<String, dynamic>;
        return Device(
          id: m['id'], name: m['name'], ipAddress: m['ip'], location: m['location'],
          status: DeviceStatus.values[m['status']],
          lastPingTime: DateTime.parse(m['lastPing']),
          cpuUsage: (m['cpu'] as num).toDouble(),
          memoryUsage: (m['mem'] as num).toDouble(),
          cpuHistory: (m['cpuH'] as List).map((x) => (x as num).toDouble()).toList(),
          memoryHistory: (m['memH'] as List).map((x) => (x as num).toDouble()).toList(),
        );
      }).toList();
    } catch (_) { return []; }
  }
}
