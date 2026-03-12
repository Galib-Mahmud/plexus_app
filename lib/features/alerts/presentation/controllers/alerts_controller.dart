import 'dart:async';
import 'dart:ui';
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
        : const Color(0xFF00C8FF);

    final icon = alert.severity == AlertSeverity.critical
        ? Icons.error_rounded
        : alert.severity == AlertSeverity.warning
        ? Icons.warning_rounded
        : Icons.info_rounded;

    // Dismiss any existing snackbar first
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      borderWidth: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      duration: const Duration(seconds: 6),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      barBlur: 0,
      overlayBlur: 0,
      snackStyle: SnackStyle.FLOATING,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 400),
      titleText: const SizedBox.shrink(),
      messageText: _AlertSnackbarContent(alert: alert, color: color, icon: icon),
    );
  }

  int get unreadCount  => alerts.where((a) => !a.isRead).length;
  int get criticalCount => alerts.where((a) => a.severity == AlertSeverity.critical).length;
  int get warningCount  => alerts.where((a) => a.severity == AlertSeverity.warning).length;

  @override
  void onClose() { _sub?.cancel(); super.onClose(); }
}

// ─── Custom snackbar content widget ──────────────────────────────────────────

class _AlertSnackbarContent extends StatelessWidget {
  final AlertEntity alert;
  final Color color;
  final IconData icon;

  const _AlertSnackbarContent({
    required this.alert,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.12),
                const Color(0xFF070F23).withOpacity(0.92),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.45), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.20),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.40),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            children: [
              // Severity icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.30), width: 0.8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color.withOpacity(0.30), width: 0.8),
                          ),
                          child: Text(
                            alert.severity.name.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          alert.deviceName,
                          style: const TextStyle(
                            color: Color(0xFF8899BB),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      style: const TextStyle(
                        color: Color(0xFFF0F4FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ── Close button ─────────────────────────────────────────────
              GestureDetector(
                onTap: () {
                  if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withOpacity(0.60),
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}