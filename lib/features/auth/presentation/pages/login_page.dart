import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_widgets.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'admin@plexus.com');
  final _passCtrl = TextEditingController(text: 'password123');
  bool _obscure = true;
  late AnimationController _bgCtrl;
  late AnimationController _floatCtrl;
  late Animation<double> _bgAnim;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);
    _floatAnim = CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _bgCtrl.dispose(); _floatCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Stack(
        children: [
          // ── Animated background ──────────────────────────────────────────
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => Stack(children: [
              // Deep hex grid
              CustomPaint(painter: HexGridPainter(), size: Size.infinite),

              // Orb 1 — top left electric blue
              Positioned(
                top: -120 + _bgAnim.value * 60,
                left: -80 + _bgAnim.value * 40,
                child: GlowOrb(color: AppColors.neonBlue, size: 400, opacity: 0.25),
              ),
              // Orb 2 — bottom right cyan
              Positioned(
                bottom: -100 + _bgAnim.value * -50,
                right: -60,
                child: GlowOrb(color: AppColors.neonCyan, size: 350, opacity: 0.20),
              ),
              // Orb 3 — center accent
              Positioned(
                top: size.height * 0.45 + _bgAnim.value * 30,
                left: size.width * 0.5,
                child: GlowOrb(color: AppColors.neonPurple, size: 200, opacity: 0.15),
              ),
              // Scanlines
              const ScanlineOverlay(),
            ]),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedBuilder(
                  animation: _floatAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _floatAnim.value * 6 - 3),
                    child: child,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 48),
                      _buildCard(auth),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Hexagonal logo container
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [AppColors.neonBlue, AppColors.neonCyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: AppColors.neonCyan.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 12)),
              BoxShadow(color: AppColors.neonBlue.withOpacity(0.3), blurRadius: 60),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.radar, color: AppColors.bg0.withOpacity(0.2), size: 80),
              const Icon(Icons.radar, color: Colors.white, size: 44),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'PLEXUS NOC',
          style: GoogleFonts.syne(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'NETWORK OPERATIONS CENTER',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: AppColors.neonCyan.withOpacity(0.8),
            letterSpacing: 3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(AuthController auth) {
    return GlassCard(
      blur: 24,
      borderRadius: BorderRadius.circular(28),
      borderColor: AppColors.glassBorderStrong,
      gradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.05)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(width: 3, height: 22, decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.neonBlue, AppColors.neonCyan], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.circular(2),
                )),
                const SizedBox(width: 12),
                Text('Sign In', style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text('Access your NOC dashboard', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 28),

            // Email
            _buildFieldLabel('EMAIL'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'admin@plexus.com',
                prefixIcon: Icon(Icons.alternate_email, color: AppColors.neonCyan.withOpacity(0.7), size: 18),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : !v.contains('@') ? 'Invalid email' : null,
            ),
            const SizedBox(height: 18),

            // Password
            _buildFieldLabel('PASSWORD'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscure,
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: '••••••••••',
                prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.neonCyan.withOpacity(0.7), size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 18),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 28),

            // Error
            Obx(() => auth.errorMsg.value.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neonRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.neonRed.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Icon(Icons.error_outline, color: AppColors.neonRed, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(auth.errorMsg.value, style: GoogleFonts.dmSans(color: AppColors.neonRed, fontSize: 12))),
                ]),
              ),
            )
                : const SizedBox.shrink()),

            // Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: NeonButton(
                label: 'ACCESS DASHBOARD',
                icon: Icons.arrow_forward_rounded,
                isLoading: auth.isLoading.value,
                onTap: _onLogin,
              ),
            )),
            const SizedBox(height: 20),

            // Hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.neonCyan.withOpacity(0.15)),
              ),
              child: Row(children: [
                Icon(Icons.info_outline, color: AppColors.neonCyan.withOpacity(0.7), size: 14),
                const SizedBox(width: 8),
                Text('admin@plexus.com · password123', style: GoogleFonts.dmSans(color: AppColors.neonCyan.withOpacity(0.8), fontSize: 12)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label, style: GoogleFonts.dmSans(
      fontSize: 10, fontWeight: FontWeight.w700,
      color: AppColors.textMuted, letterSpacing: 2,
    ));
  }

  void _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Get.find<AuthController>();
    final ok = await auth.login(_emailCtrl.text, _passCtrl.text);
    if (ok) Get.offAllNamed(AppRoutes.dashboard);
  }
}
