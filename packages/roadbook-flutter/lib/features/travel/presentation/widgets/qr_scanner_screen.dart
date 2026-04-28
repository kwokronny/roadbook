// lib/features/travel/presentation/widgets/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme.dart';
import 'package:hugeicons/hugeicons.dart';

/// Full-screen camera overlay. Pops with the scanned raw value (String) on
/// first successful QR detection, or null if the user cancels.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  static Future<String?> show(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const QrScannerScreen(),
      ),
    );
  }

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.isNotEmpty) {
        _handled = true;
        Navigator.of(context).pop(raw);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (_, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  '无法打开相机：${error.errorDetails?.message ?? error.errorCode.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
          // ── Dim overlay with cutout reticle
          const _ScannerReticle(),
          // ── Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0x66000000),
                  shape: BoxShape.circle,
                ),
                child: const Icon(HugeIcons.strokeRoundedCancel01, size: 18, color: Colors.white),
              ),
            ),
          ),
          // ── Hint
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 40,
            child: const Center(
              child: Text(
                '将二维码对准取景框',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerReticle extends StatelessWidget {
  const _ScannerReticle();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ReticlePainter(),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide * 0.68;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: center, width: side, height: side);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));

    // Dim everything except the reticle using even-odd fill.
    final dimPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect);
    canvas.drawPath(dimPath, Paint()..color = const Color(0x80000000));

    // Coral corner brackets
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const armLen = 22.0;
    final l = rect.left, r = rect.right, t = rect.top, b = rect.bottom;
    canvas.drawLine(Offset(l, t + armLen), Offset(l, t), paint);
    canvas.drawLine(Offset(l, t), Offset(l + armLen, t), paint);
    canvas.drawLine(Offset(r - armLen, t), Offset(r, t), paint);
    canvas.drawLine(Offset(r, t), Offset(r, t + armLen), paint);
    canvas.drawLine(Offset(r, b - armLen), Offset(r, b), paint);
    canvas.drawLine(Offset(r, b), Offset(r - armLen, b), paint);
    canvas.drawLine(Offset(l + armLen, b), Offset(l, b), paint);
    canvas.drawLine(Offset(l, b), Offset(l, b - armLen), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
