import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_widgets.dart';
import '../../domain/entities/entities.dart';
import '../controllers/devices_controller.dart';

class DeviceDetailPage extends StatefulWidget {
  final Device device;
  const DeviceDetailPage({super.key, required this.device});
  @override State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  late Device _device;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _device = widget.device;
    // Listen to live updates for this device
    _sub = Get.find<DevicesController>().allDevices.listen((list) {
      final updated = list.cast<Device?>().firstWhere((d) => d?.id == _device.id, orElse: () => null);
      if (updated != null && mounted) setState(() => _device = updated);
    });
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isOnline = _device.isOnline;
    final statusColor = isOnline ? AppColors.neonGreen : AppColors.neonRed;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Stack(children: [
        // Background
        Stack(children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.bgGradient)),
          CustomPaint(painter: HexGridPainter(), size: Size.infinite),
          Positioned(top: -40, right: -40, child: GlowOrb(color: statusColor, size: 280, opacity: 0.15)),
          const ScanlineOverlay(),
        ]),
        // Content
        SafeArea(
          child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
            _buildAppBar(statusColor, isOnline),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(delegate: SliverChildListDelegate([
                _buildHeroCard(statusColor, isOnline),
                const SizedBox(height: 16),
                _buildInfoGrid(),
                const SizedBox(height: 16),
                if (isOnline) ...[
                  _buildUsageRow(),
                  const SizedBox(height: 16),
                  _buildChart('CPU USAGE', _device.cpuHistory, AppColors.neonBlue, AppColors.neonCyan),
                  const SizedBox(height: 12),
                  _buildChart('MEMORY USAGE', _device.memoryHistory, AppColors.neonPurple, AppColors.neonPink),
                ],
              ])),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildAppBar(Color statusColor, bool isOnline) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: GlassCard(
            padding: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(12),
            child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
          ),
        ),
      ),
      title: Text(_device.name, style: GoogleFonts.syne(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            borderRadius: BorderRadius.circular(20),
            borderColor: statusColor.withOpacity(0.4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              StatusDot(isOnline: isOnline, size: 8),
              const SizedBox(width: 6),
              Text(isOnline ? 'ONLINE' : 'OFFLINE', style: GoogleFonts.dmSans(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(Color statusColor, bool isOnline) {
    return GlassCard(
      borderRadius: BorderRadius.circular(24),
      borderColor: statusColor.withOpacity(0.25),
      gradient: LinearGradient(
        colors: [statusColor.withOpacity(0.08), Colors.white.withOpacity(0.03)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      child: Row(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Stack(alignment: Alignment.center, children: [
            Icon(Icons.router_rounded, color: statusColor.withOpacity(0.2), size: 60),
            Icon(Icons.router_rounded, color: statusColor, size: 30),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_device.name, style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text(_device.ipAddress, style: GoogleFonts.dmSans(color: AppColors.neonCyan, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.location_on_rounded, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 3),
            Expanded(child: Text(_device.location, style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
          ]),
        ])),
      ]),
    );
  }

  Widget _buildInfoGrid() {
    return GlassCard(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _InfoRow(icon: Icons.access_time_rounded, label: 'Last Ping', value: DateFormat('HH:mm:ss · MMM d').format(_device.lastPingTime), color: AppColors.neonCyan),
        _Divider(),
        _InfoRow(icon: Icons.language_rounded, label: 'IP Address', value: _device.ipAddress, color: AppColors.neonBlue),
        _Divider(),
        _InfoRow(icon: Icons.place_rounded, label: 'Location', value: _device.location, color: AppColors.neonPurple),
        _Divider(),
        _InfoRow(icon: Icons.fingerprint_rounded, label: 'Device ID', value: _device.id, color: AppColors.textMuted),
      ]),
    );
  }

  Widget _buildUsageRow() {
    return Row(children: [
      Expanded(child: _UsageCard(label: 'CPU', value: _device.cpuUsage, color: AppColors.neonBlue, icon: Icons.memory_rounded)),
      const SizedBox(width: 12),
      Expanded(child: _UsageCard(label: 'Memory', value: _device.memoryUsage, color: AppColors.neonPurple, icon: Icons.storage_rounded)),
    ]);
  }

  Widget _buildChart(String title, List<double> data, Color startColor, Color endColor) {
    if (data.isEmpty) return const SizedBox.shrink();
    final spots = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    final maxY = (data.reduce((a, b) => a > b ? a : b) * 1.2).clamp(10.0, 100.0);

    return GlassCard(
      borderRadius: BorderRadius.circular(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 2)),
          Text('${data.last.toStringAsFixed(1)}%', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w800, color: endColor)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: LineChart(LineChartData(
            gridData: FlGridData(
              show: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(color: AppColors.glassBorder, strokeWidth: 0.5),
              horizontalInterval: 25,
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 25,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}%', style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 9)))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minY: 0, maxY: 100,
            lineBarsData: [LineChartBarData(
              spots: spots,
              isCurved: true, curveSmoothness: 0.3,
              gradient: LinearGradient(colors: [startColor, endColor]),
              barWidth: 2.5,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [endColor.withOpacity(0.25), endColor.withOpacity(0.0)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
            )],
          )),
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _InfoRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 10),
      Text(label, style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13)),
      const Spacer(),
      Flexible(child: Text(value, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
    ]),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(height: 0.5, color: AppColors.glassBorder);
}

class _UsageCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  const _UsageCard({required this.label, required this.value, required this.color, required this.icon});

  Color get _statusColor => value > 85 ? AppColors.neonRed : value > 65 ? AppColors.neonAmber : color;

  @override
  Widget build(BuildContext context) => GlassCard(
    borderRadius: BorderRadius.circular(18),
    borderColor: _statusColor.withOpacity(0.2),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: _statusColor, size: 16),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 12)),
      ]),
      const SizedBox(height: 10),
      Text('${value.toStringAsFixed(1)}%', style: GoogleFonts.syne(color: _statusColor, fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value / 100, minHeight: 4,
          backgroundColor: AppColors.glassBorder,
          valueColor: AlwaysStoppedAnimation(_statusColor),
        ),
      ),
    ]),
  );
}
