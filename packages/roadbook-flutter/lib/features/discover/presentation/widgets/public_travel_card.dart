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
    LinearGradient(colors: [Color(0xFFFF5B2E), Color(0xFFFF8C42)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
  ];

  String _formatViewCount(int count) {
    if (count >= 1000) {
      final k = count / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
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
            horizontal: AppSpacing.pageHorizontal, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.contentCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.contentCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 封面色块
              Container(
                height: 60,
                decoration: BoxDecoration(gradient: gradient),
              ),
              // 内容区
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      travel.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${travel.cityLabel} · ${travel.days}天',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // 作者头像
                        _OwnerAvatar(owner: travel.owner),
                        const SizedBox(width: 5),
                        Text(
                          travel.owner.name,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const Spacer(),
                        Text(
                          '${_formatViewCount(travel.viewCount)} 浏览',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
