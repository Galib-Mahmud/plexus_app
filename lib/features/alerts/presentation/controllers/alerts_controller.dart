import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/entities.dart';
import '../../../auth/data/datasources/mock_data_service.dart';

class AlertsController extends GetxController {
  final _dataService = MockDataService();
  final alerts = <AlertEntity>[].obs;
  final isLoading = true.obs;
  StreamSubscription? _sub;
  AlertEntity? _lastSeen;

  @override
  void onInit() {
    super.onInit();
    _sub = _dataService.watchAlerts().listen((list) {
      alerts.value = list;
      isLoading.value = false;
      if (list.isNotEmpty && list.first.id != _lastSeen?.id) {
        if (_lastSeen != null) _showAlertSnackbar(list.first);
        _lastSeen = list.first;
      } else if (_lastSeen == null && list.isNotEmpty) {
        _lastSeen = list.first;
      }
    });
  }

  void _showAlertSnackbar(AlertEntity alert) {
    final color = alert.severity == AlertSeverity.critical
        ? const Color(0xFFFF1744)
        : alert.severity == AlertSeverity.warning
        ? const Color(0xFFFFAB00)
        : const Color(0xFF00F5FF);
    Get.snackbar(
      alert.severity.name.toUpperCase(), alert.message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF070F23).withOpacity(0.96),
      colorText: const Color(0xFFF0F4FF),
      borderColor: color.withOpacity(0.5),
      borderWidth: 1.5,
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 5),
      icon: Icon(
        alert.severity == AlertSeverity.critical ? Icons.error_outline
            : alert.severity == AlertSeverity.warning ? Icons.warning_amber_outlined
            : Icons.info_outline,
        color: color, size: 24,
      ),
      shouldIconPulse: alert.severity == AlertSeverity.critical,
      barBlur: 20,
      overlayBlur: 0,
      snackStyle: SnackStyle.FLOATING,
      forwardAnimationCurve: Curves.easeOutCubic,
    );
  }

  int get unreadCount => alerts.where((a) => !a.isRead).length;
  int get criticalCount => alerts.where((a) => a.severity == AlertSeverity.critical).length;
  int get warningCount => alerts.where((a) => a.severity == AlertSeverity.warning).length;

  @override
  void onClose() { _sub?.cancel(); super.onClose(); }
}
