import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_widgets.dart';
import '../../domain/entities/entities.dart';
import '../controllers/devices_controller.dart';
import 'device_detail_page.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        _buildBg(),
        SafeArea(child: Column(children: [
          _buildHeader(),
          _buildSearchFilter(),
          Expanded(child: _buildList()),
        ])),
      ]),
    );
  }

  Widget _buildBg() => Stack(children: [
    Container(decoration: const BoxDecoration(gradient: AppColors.bgGradient)),
    CustomPaint(painter: HexGridPainter(), size: Size.infinite),
    Positioned(top: -60, left: -60, child: GlowOrb(color: AppColors.neonCyan, size: 260, opacity: 0.14)),
    Positioned(bottom: 80, right: -40, child: GlowOrb(color: AppColors.neonPurple, size: 220, opacity: 0.12)),
    const ScanlineOverlay(),
  ]);

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Devices', style: GoogleFonts.syne(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
          Obx(() {
            final dc = Get.find<DevicesController>();
            return Text('${dc.filteredDevices.length} of ${dc.allDevices.length} shown', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary));
          }),
        ]),
        Obx(() {
          final dc = Get.find<DevicesController>();
          return Row(children: [
            _CountBadge(count: dc.onlineCount, color: AppColors.neonGreen),
            const SizedBox(width: 8),
            _CountBadge(count: dc.offlineCount, color: AppColors.neonRed),
          ]);
        }),
      ]),
    );
  }

  Widget _buildSearchFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Search
        GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(14),
          child: TextField(
            onChanged: Get.find<DevicesController>().setSearch,
            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search name, IP, location…',
              hintStyle: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.neonCyan.withOpacity(0.7), size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Filters
        Obx(() {
          final dc = Get.find<DevicesController>();
          return Row(children: DeviceFilter.values.map((f) {
            final active = dc.activeFilter.value == f;
            final color = f == DeviceFilter.online ? AppColors.neonGreen : f == DeviceFilter.offline ? AppColors.neonRed : AppColors.neonCyan;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => dc.setFilter(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? color.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? color.withOpacity(0.5) : AppColors.glassBorder, width: active ? 1.2 : 0.8),
                  ),
                  child: Text(
                    f == DeviceFilter.all ? 'All' : f.name[0].toUpperCase() + f.name.substring(1),
                    style: GoogleFonts.dmSans(color: active ? color : AppColors.textSecondary, fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w400),
                  ),
                ),
              ),
            );
          }).toList());
        }),
      ]),
    );
  }

  Widget _buildList() {
    return Obx(() {
      final dc = Get.find<DevicesController>();
      if (dc.isLoading.value && dc.allDevices.isEmpty) {
        return Center(child: CircularProgressIndicator(color: AppColors.neonCyan, strokeWidth: 2));
      }
      if (dc.filteredDevices.isEmpty) {
        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.devices_other_rounded, color: AppColors.textMuted, size: 52),
          const SizedBox(height: 12),
          Text('No devices found', style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 14)),
        ]));
      }
      return RefreshIndicator(
        color: AppColors.neonCyan, backgroundColor: AppColors.bg2,
        onRefresh: () async => dc.refresh(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: dc.filteredDevices.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DeviceCard(device: dc.filteredDevices[i]),
          ),
        ),
      );
    });
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3), width: 0.8),
    ),
    child: Row(children: [
      StatusDot(isOnline: color == AppColors.neonGreen, size: 6),
      const SizedBox(width: 5),
      Text('$count', style: GoogleFonts.syne(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _DeviceCard extends StatelessWidget {
  final Device device;
  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final isOnline = device.isOnline;
    final statusColor = isOnline ? AppColors.neonGreen : AppColors.neonRed;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      borderColor: isOnline ? AppColors.neonGreen.withOpacity(0.15) : AppColors.neonRed.withOpacity(0.12),
      onTap: () => Get.to(() => DeviceDetailPage(device: device), transition: Transition.rightToLeft),
      child: Row(children: [
        // Icon with glow
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: statusColor.withOpacity(0.2), width: 0.8),
          ),
          child: Stack(alignment: Alignment.center, children: [
            Icon(Icons.router_rounded, color: statusColor.withOpacity(0.3), size: 40),
            Icon(Icons.router_rounded, color: statusColor, size: 22),
          ]),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(device.name, style: GoogleFonts.syne(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 11, color: AppColors.textMuted),
            const SizedBox(width: 3),
            Expanded(child: Text(device.location, style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 11), overflow: TextOverflow.ellipsis)),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(device.ipAddress, style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 11, fontFeatures: const [FontFeature.tabularFigures()])),
          const SizedBox(height: 6),
          Row(children: [
            StatusDot(isOnline: isOnline, size: 7),
            const SizedBox(width: 5),
            Text(isOnline ? 'ONLINE' : 'OFFLINE', style: GoogleFonts.dmSans(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ]),
        ]),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
      ]),
    );
  }
}
