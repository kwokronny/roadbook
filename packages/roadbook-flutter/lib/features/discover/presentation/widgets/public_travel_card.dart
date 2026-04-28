// lib/features/discover/presentation/widgets/public_travel_card.dart
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/public_travel.dart';

/// 发现页旅程卡片：封面色块 + 旅程信息 + 作者信息
class PublicTravelCard extends StatelessWidget {
  const PublicTravelCard({super.key, required this.travel, this.onTap});

  final PublicTravel travel;
  final VoidCallback? onTap;

  static const _gradients = [
    LinearGradient(colors: [Color(0xFFFF6B3D), Color(0xFFFF8C42)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
  ];

  static String _formatViewCount(int count) {
    if (count >= 1000) {
      final tenth = count ~/ 100; // e.g. 1200 → 12, 1050 → 10, 2000 → 20
      if (tenth % 10 == 0) {
        return '${tenth ~/ 10}k'; // whole number: 2000 → "2k"
      }
      return '${(tenth / 10).toStringAsFixed(1)}k'; // 1200 → "1.2k"
    }
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[travel.gradientIndex];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal, vertical: 5),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.cardSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover — warm gradient
            Container(
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x1FFF6B3D), // rgba(255,107,61,0.12)
                    Color(0x33F5D2AA), // rgba(245,210,170,0.20)
                  ],
                ),
              ),
            ),
            // Body — glass
            ClipRect(
              child: BackdropFilter(
                filter: GlassSpec.cardBlur,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: GlassSpec.cardBg,
                    border: Border.all(color: GlassSpec.cardBorder),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadius.cardSm),
                      bottomRight: Radius.circular(AppRadius.cardSm),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        travel.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${travel.cityLabel} · ${travel.days}天',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.inkTertiary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerAvatar extends StatelessWidget {
  const _OwnerAvatar({required this.owner});
  final PublicTravelOwner owner;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 16,
        height: 16,
        child: owner.avatar != null
            ? Image.network(owner.avatar!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder())
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
      );
}
