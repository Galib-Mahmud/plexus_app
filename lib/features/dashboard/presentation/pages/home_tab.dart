import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_widgets.dart';
import '../../../alerts/domain/entities/entities.dart';
import '../../../alerts/presentation/controllers/alerts_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/domain/entities/entities.dart';
import '../../../devices/presentation/controllers/devices_controller.dart';
import '../controllers/dashboard_controller.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Deep space background
          _buildBackground(),
          // Content
          SafeArea(
            child: RefreshIndicator(
              color: AppColors.neonCyan,
              backgroundColor: AppColors.bg2,
              onRefresh: () async => Get.find<DashboardController>().refresh(),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(delegate: SliverChildListDelegate([
                      _buildOfflineBanner(),
                      const SizedBox(height: 20),
                      _buildMetricsRow(),
                      const SizedBox(height: 16),
                      _buildMetricsRow2(),
                      const SizedBox(height: 24),
                      _buildHealthGauge(),
                      const SizedBox(height: 24),
                      _buildRecentAlerts(),
                      const SizedBox(height: 24),
                      _buildOfflineDevices(),
                    ])),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(children: [
      Container(decoration: const BoxDecoration(gradient: AppColors.bgGradient)),
      CustomPaint(painter: HexGridPainter(), size: Size.infinite),
      Positioned(top: -80, right: -60, child: GlowOrb(color: AppColors.neonBlue, size: 320, opacity: 0.18)),
      Positioned(bottom: 100, left: -80, child: GlowOrb(color: AppColors.neonPurple, size: 280, opacity: 0.15)),
      const ScanlineOverlay(),
    ]);
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Obx(() {
                final dc = Get.find<DashboardController>();
                return Text(
                  dc.metrics.value?.lastUpdated != null
                      ? 'Last sync ${DateFormat('HH:mm:ss').format(dc.metrics.value!.lastUpdated!)}'
                      : 'Connecting...',
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.neonCyan.withOpacity(0.7), letterSpacing: 1),
                );
              }),
              Text('NOC Dashboard', style: GoogleFonts.syne(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
            ]),
          ),
          GestureDetector(
            onTap: () => _showUserMenu(),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              borderRadius: BorderRadius.circular(50),
              blur: 12,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [AppColors.neonBlue, AppColors.neonCyan]),
                  ),
                  child: Obx(() {
                    final auth = Get.find<AuthController>();
                    final n = auth.user.value?.name ?? 'A';
                    return Center(child: Text(n[0], style: GoogleFonts.syne(color: AppColors.bg0, fontSize: 13, fontWeight: FontWeight.w800)));
                  }),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final name = Get.find<AuthController>().user.value?.name.split(' ').first ?? 'Admin';
                  return Text(name, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600));
                }),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Obx(() {
      final isOffline = Get.find<DashboardController>().isOffline.value;
      if (!isOffline) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          borderRadius: BorderRadius.circular(12),
          borderColor: AppColors.neonAmber.withOpacity(0.4),
          child: Row(children: [
            Icon(Icons.wifi_off_rounded, color: AppColors.neonAmber, size: 16),
            const SizedBox(width: 10),
            Text('Offline — Showing cached data', style: GoogleFonts.dmSans(color: AppColors.neonAmber, fontSize: 12, fontWeight: FontWeight.w500)),
          ]),
        ),
      );
    });
  }

  Widget _buildMetricsRow() {
    return Obx(() {
      final m = Get.find<DashboardController>().metrics.value;
      final loading = Get.find<DashboardController>().isLoading.value && m == null;
      return Row(children: [
        Expanded(child: _MetricCard(label: 'TOTAL DEVICES', value: m?.total.toString() ?? '--', icon: Icons.devices_rounded, color: AppColors.neonBlue, isLoading: loading)),
        const SizedBox(width: 12),
        Expanded(child: _MetricCard(label: 'ONLINE', value: m?.online.toString() ?? '--', icon: Icons.check_circle_rounded, color: AppColors.neonGreen, isLoading: loading, sub: m != null ? '${m.healthPercent.toStringAsFixed(0)}%' : null)),
      ]);
    });
  }

  Widget _buildMetricsRow2() {
    return Obx(() {
      final m = Get.find<DashboardController>().metrics.value;
      final loading = Get.find<DashboardController>().isLoading.value && m == null;
      return Row(children: [
        Expanded(child: _MetricCard(label: 'OFFLINE', value: m?.offline.toString() ?? '--', icon: Icons.cancel_rounded, color: AppColors.neonRed, isLoading: loading, pulse: (m?.offline ?? 0) > 0)),
        const SizedBox(width: 12),
        Expanded(child: _MetricCard(label: 'ALERTS', value: m?.alerts.toString() ?? '--', icon: Icons.warning_rounded, color: AppColors.neonAmber, isLoading: loading, pulse: (m?.alerts ?? 0) > 0)),
      ]);
    });
  }

  Widget _buildHealthGauge() {
    return Obx(() {
      final m = Get.find<DashboardController>().metrics.value;
      if (m == null) return const SizedBox.shrink();
      return GlassCard(
        borderRadius: BorderRadius.circular(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NETWORK HEALTH', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 2)),
          const SizedBox(height: 16),
          Row(children: [
            SizedBox(
              width: 130, height: 130,
              child: Stack(alignment: Alignment.center, children: [
                PieChart(PieChartData(
                  sectionsSpace: 4, centerSpaceRadius: 44,
                  sections: [
                    PieChartSectionData(value: m.online.toDouble(), color: AppColors.neonGreen, radius: 18, showTitle: false),
                    PieChartSectionData(value: m.offline.toDouble(), color: AppColors.neonRed, radius: 18, showTitle: false),
                  ],
                  startDegreeOffset: -90,
                )),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${m.healthPercent.toStringAsFixed(0)}%', style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('health', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary)),
                ]),
              ]),
            ),
            const SizedBox(width: 24),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _LegendRow(color: AppColors.neonGreen, label: 'Online', value: '${m.online}', pct: '${m.healthPercent.toStringAsFixed(1)}%'),
              const SizedBox(height: 14),
              _LegendRow(color: AppColors.neonRed, label: 'Offline', value: '${m.offline}', pct: m.total > 0 ? '${(m.offline/m.total*100).toStringAsFixed(1)}%' : '0%'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.neonGreen.withOpacity(0.08), AppColors.neonCyan.withOpacity(0.06)]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neonGreen.withOpacity(0.2)),
                ),
                child: Row(children: [
                  Icon(Icons.verified_rounded, color: AppColors.neonGreen, size: 14),
                  const SizedBox(width: 6),
                  Text('${m.total} total nodes', style: GoogleFonts.dmSans(color: AppColors.neonGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            ])),
          ]),
        ]),
      );
    });
  }

  Widget _buildRecentAlerts() {
    return Obx(() {
      final recent = Get.find<AlertsController>().alerts.take(4).toList();
      if (recent.isEmpty) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('RECENT ALERTS', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 2)),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(20),
          child: Column(children: recent.asMap().entries.map((e) {
            return Column(children: [
              _AlertRow(alert: e.value),
              if (e.key < recent.length - 1) Divider(height: 0.5, color: AppColors.glassBorder, indent: 16, endIndent: 16),
            ]);
          }).toList()),
        ),
      ]);
    });
  }

  Widget _buildOfflineDevices() {
    return Obx(() {
      final offline = Get.find<DevicesController>().allDevices.where((d) => !d.isOnline).take(4).toList();
      if (offline.isEmpty) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('OFFLINE DEVICES', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 2)),
        ),
        ...offline.map((d) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            borderRadius: BorderRadius.circular(16),
            borderColor: AppColors.neonRed.withOpacity(0.25),
            child: Row(children: [
              StatusDot(isOnline: false, size: 8),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.name, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(d.ipAddress, style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 11)),
              ])),
              DataChip(label: d.location.split('—').last.trim(), color: AppColors.neonRed),
            ]),
          ),
        )),
      ]);
    });
  }

  void _showUserMenu() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassBorder),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 3, decoration: BoxDecoration(color: AppColors.glassBorder, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Obx(() {
            final auth = Get.find<AuthController>();
            final u = auth.user.value;
            return Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [AppColors.neonBlue, AppColors.neonCyan])),
                child: Center(child: Text(u?.name[0] ?? 'A', style: GoogleFonts.syne(color: AppColors.bg0, fontSize: 18, fontWeight: FontWeight.w800))),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u?.name ?? 'Admin', style: GoogleFonts.syne(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                Text(u?.role ?? '', style: GoogleFonts.dmSans(color: AppColors.neonCyan, fontSize: 12)),
              ]),
            ]);
          }),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () { Get.back(); Get.find<AuthController>().logout(); },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.neonRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.neonRed.withOpacity(0.25)),
              ),
              child: Row(children: [
                Icon(Icons.logout_rounded, color: AppColors.neonRed, size: 18),
                const SizedBox(width: 12),
                Text('Sign Out', style: GoogleFonts.dmSans(color: AppColors.neonRed, fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _MetricCard extends StatefulWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool isLoading, pulse;
  final String? sub;

  const _MetricCard({
    required this.label, required this.value, required this.icon, required this.color,
    this.isLoading = false, this.pulse = false, this.sub,
  });

  @override State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return GlassCard(
        height: 120, borderRadius: BorderRadius.circular(20),
        child: const SizedBox.shrink(),
      );
    }

    return GlassCard(
      borderRadius: BorderRadius.circular(20),
      borderColor: widget.color.withOpacity(0.2),
      gradient: LinearGradient(
        colors: [widget.color.withOpacity(0.08), Colors.white.withOpacity(0.03)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.color.withOpacity(0.25), width: 0.8),
            ),
            child: Icon(widget.icon, color: widget.color, size: 18),
          ),
          if (widget.pulse)
            AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(_anim.value),
                  boxShadow: [BoxShadow(color: widget.color.withOpacity(_anim.value * 0.6), blurRadius: 8, spreadRadius: 2)],
                ),
              ),
            ),
        ]),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(widget.value, style: GoogleFonts.syne(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
          if (widget.sub != null) ...[
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: widget.color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(widget.sub!, style: GoogleFonts.dmSans(color: widget.color, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 4),
        Text(widget.label, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2)),
      ]),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label, value, pct;
  const _LegendRow({required this.color, required this.label, required this.value, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13))),
      Text(value, style: GoogleFonts.syne(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
      const SizedBox(width: 6),
      Text('($pct)', style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 11)),
    ]);
  }
}

class _AlertRow extends StatelessWidget {
  final AlertEntity alert;
  const _AlertRow({required this.alert});

  Color get _c => alert.severity == AlertSeverity.critical ? AppColors.neonRed
      : alert.severity == AlertSeverity.warning ? AppColors.neonAmber : AppColors.neonCyan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(width: 3, height: 36, decoration: BoxDecoration(color: _c, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(alert.message, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(DateFormat('HH:mm · MMM d').format(alert.timestamp), style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 10)),
        ])),
        DataChip(label: alert.severity.name, color: _c),
      ]),
    );
  }
}
