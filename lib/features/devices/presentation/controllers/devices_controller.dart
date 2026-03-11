import 'dart:async';
import 'package:get/get.dart';
import '../../domain/entities/entities.dart';
import '../../../auth/data/datasources/mock_data_service.dart';

enum DeviceFilter { all, online, offline }

class DevicesController extends GetxController {
  final _dataService = MockDataService();
  final allDevices = <Device>[].obs;
  final filteredDevices = <Device>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final activeFilter = DeviceFilter.all.obs;
  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _startStream();
    ever(searchQuery, (_) => _applyFilters());
    ever(activeFilter, (_) => _applyFilters());
  }

  void _startStream() {
    isLoading.value = true;
    _sub?.cancel();
    _sub = _dataService.watchDevices().listen((devices) {
      allDevices.value = devices;
      _dataService.cacheDevices(devices);
      _applyFilters();
      isLoading.value = false;
    });
  }

  void _applyFilters() {
    var result = List<Device>.from(allDevices);
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      result = result.where((d) =>
      d.name.toLowerCase().contains(q) ||
          d.ipAddress.contains(q) ||
          d.location.toLowerCase().contains(q)).toList();
    }
    switch (activeFilter.value) {
      case DeviceFilter.online:
        result = result.where((d) => d.isOnline).toList();
        break;
      case DeviceFilter.offline:
        result = result.where((d) => !d.isOnline).toList();
        break;
      case DeviceFilter.all:
        break;
    }
    filteredDevices.value = result;
  }

  void setFilter(DeviceFilter f) => activeFilter.value = f;
  void setSearch(String q) => searchQuery.value = q;
  void refresh() => _startStream();

  int get onlineCount => allDevices.where((d) => d.isOnline).length;
  int get offlineCount => allDevices.where((d) => !d.isOnline).length;

  @override
  void onClose() { _sub?.cancel(); super.onClose(); }
}
