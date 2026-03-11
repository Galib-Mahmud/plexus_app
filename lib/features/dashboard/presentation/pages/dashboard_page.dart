import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../alerts/presentation/controllers/alerts_controller.dart';
import '../../../devices/presentation/controllers/devices_controller.dart';
import '../controllers/dashboard_controller.dart';
import 'home_tab.dart';
import '../../../devices/presentation/pages/devices_page.dart';
import '../../../alerts/presentation/pages/alerts_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _idx = 0;
  final _pages = const [HomeTab(), DevicesPage(), AlertsPage()];

  @override
  void initState() {
    super.initState();
    Get.put(DashboardController());
    Get.put(DevicesController());
    Get.put(AlertsController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: IndexedStack(index: _idx, children: _pages),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.glassBorder, width: 0.5)),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: AppColors.bg1.withOpacity(0.85),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard', idx: 0, current: _idx, onTap: () => setState(() => _idx = 0)),
                  _NavItem(icon: Icons.router_outlined, label: 'Devices', idx: 1, current: _idx, onTap: () => setState(() => _idx = 1)),
                  _AlertsNavItem(idx: 2, current: _idx, onTap: () => setState(() => _idx = 2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int idx, current;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.idx, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = idx == current;
    return GestureDetector(
      onTap: onTap, behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: active ? AppColors.neonCyan.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? AppColors.neonCyan.withOpacity(0.3) : Colors.transparent, width: 0.8),
            ),
            child: Icon(icon, color: active ? AppColors.neonCyan : AppColors.textMuted, size: 22),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.dmSans(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? AppColors.neonCyan : AppColors.textMuted),
            child: Text(label),
          ),
        ]),
      ),
    );
  }
}

class _AlertsNavItem extends StatelessWidget {
  final int idx, current;
  final VoidCallback onTap;
  const _AlertsNavItem({required this.idx, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = idx == current;
    return GestureDetector(
      onTap: onTap, behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: active ? AppColors.neonCyan.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? AppColors.neonCyan.withOpacity(0.3) : Colors.transparent, width: 0.8),
            ),
            child: Stack(clipBehavior: Clip.none, children: [
              Icon(active ? Icons.notifications : Icons.notifications_outlined, color: active ? AppColors.neonCyan : AppColors.textMuted, size: 22),
              Obx(() {
                final count = Get.find<AlertsController>().unreadCount;
                if (count == 0) return const SizedBox.shrink();
                return Positioned(right: -6, top: -6, child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: AppColors.neonRed, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                  child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                ));
              }),
            ]),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.dmSans(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? AppColors.neonCyan : AppColors.textMuted),
            child: const Text('Alerts'),
          ),
        ]),
      ),
    );
  }
}
