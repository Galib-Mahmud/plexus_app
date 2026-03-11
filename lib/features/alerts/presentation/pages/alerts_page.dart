import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_widgets.dart';
import '../../domain/entities/entities.dart';
import '../controllers/alerts_controller.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        _buildBg(),
        SafeArea(child: Column(children: [
          _buildHeader(),
          Expanded(child: _buildList()),
        ])),
      ]),
    );
  }

  Widget _buildBg() => Stack(children: [
    Container(decoration: const BoxDecoration(gradient: AppColors.bgGradient)),
    CustomPaint(painter: HexGridPainter(), size: Size.infinite),
    Positioned(top: -50, right: -40, child: GlowOrb(color: AppColors.neonAmber, size: 240, opacity: 0.13)),
    Positioned(bottom: 120, left: -60, child: GlowOrb(color: AppColors.neonRed, size: 200, opacity: 0.10)),
    const ScanlineOverlay(),
  ]);

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Alerts', style: GoogleFonts.syne(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
          Obx(() {
            final ac = Get.find<AlertsController>();
            return Text('${ac.alerts.length} total · ${ac.unreadCount} unread', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary));
          }),
        ]),
        Obx(() {
          final ac = Get.find<AlertsController>();
          return Row(children: [
            _SevBadge(count: ac.criticalCount, color: AppColors.neonRed, label: 'CRIT'),
            const SizedBox(width: 6),
            _SevBadge(count: ac.warningCount, color: AppColors.neonAmber, label: 'WARN'),
          ]);
        }),
      ]),
    );
  }

  Widget _buildList() {
    return Obx(() {
      final ac = Get.find<AlertsController>();
      if (ac.isLoading.value && ac.alerts.isEmpty) {
        return Center(child: CircularProgressIndicator(color: AppColors.neonCyan, strokeWidth: 2));
      }
      if (ac.alerts.isEmpty) {
        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.notifications_off_outlined, color: AppColors.textMuted, size: 52),
          const SizedBox(height: 12),
          Text('No alerts', style: GoogleFonts.dmSans(color: AppColors.textMuted)),
        ]));
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: ac.alerts.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _AlertCard(alert: ac.alerts[i], isNew: i == 0),
        ),
      );
    });
  }
}

class _SevBadge extends StatelessWidget {
  final int count;
  final Color color;
  final String label;
  const _SevBadge({required this.count, required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3), width: 0.8),
    ),
    child: Text('$count $label', style: GoogleFonts.dmSans(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}

class _AlertCard extends StatelessWidget {
  final AlertEntity alert;
  final bool isNew;
  const _AlertCard({required this.alert, this.isNew = false});

  Color get _color => alert.severity == AlertSeverity.critical ? AppColors.neonRed
      : alert.severity == AlertSeverity.warning ? AppColors.neonAmber : AppColors.neonCyan;

  IconData get _icon => alert.severity == AlertSeverity.critical ? Icons.error_rounded
      : alert.severity == AlertSeverity.warning ? Icons.warning_rounded : Icons.info_rounded;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      borderColor: isNew ? _color.withOpacity(0.5) : _color.withOpacity(0.15),
      gradient: isNew
          ? LinearGradient(colors: [_color.withOpacity(0.08), Colors.white.withOpacity(0.03)], begin: Alignment.topLeft, end: Alignment.bottomRight)
          : null,
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _color.withOpacity(0.25), width: 0.8),
          ),
          child: Icon(_icon, color: _color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(alert.deviceName, style: GoogleFonts.syne(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
            if (isNew) DataChip(label: 'NEW', color: AppColors.neonGreen),
          ]),
          const SizedBox(height: 3),
          Text(alert.message, style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          Row(children: [
            DataChip(label: alert.severity.name.toUpperCase(), color: _color),
            const SizedBox(width: 8),
            Icon(Icons.access_time_rounded, size: 10, color: AppColors.textMuted),
            const SizedBox(width: 3),
            Text(DateFormat('HH:mm · MMM d').format(alert.timestamp), style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 10)),
          ]),
        ])),
      ]),
    );
  }
}
