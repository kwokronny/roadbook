// lib/features/luggage/presentation/widgets/template_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../../shared/constants/luggage_presets.dart';
import '../../domain/luggage_provider.dart';

class TemplateSheet extends ConsumerWidget {
  const TemplateSheet({super.key, required this.travelId});

  final int travelId;

  static Future<void> show(BuildContext context,
      {required int travelId}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TemplateSheet(travelId: travelId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text('选择出行季节',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('点击即导入对应季节的打包建议', style: AppTextStyles.caption),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
            children: [
              _SeasonCard(
                  travelId: travelId,
                  season: LuggageSeason.spring,
                  emoji: '🌸',
                  label: '春季',
                  months: '3–5月'),
              _SeasonCard(
                  travelId: travelId,
                  season: LuggageSeason.summer,
                  emoji: '☀️',
                  label: '夏季',
                  months: '6–8月'),
              _SeasonCard(
                  travelId: travelId,
                  season: LuggageSeason.autumn,
                  emoji: '🍂',
                  label: '秋季',
                  months: '9–11月'),
              _SeasonCard(
                  travelId: travelId,
                  season: LuggageSeason.winter,
                  emoji: '❄️',
                  label: '冬季',
                  months: '12–2月'),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SeasonCard extends ConsumerWidget {
  const _SeasonCard({
    required this.travelId,
    required this.season,
    required this.emoji,
    required this.label,
    required this.months,
  });

  final int travelId;
  final LuggageSeason season;
  final String emoji;
  final String label;
  final String months;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final added = await ref
            .read(luggageProvider(travelId).notifier)
            .importTemplate(season);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已导入$label模板，新增 $added 项')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius:
              BorderRadius.circular(AppRadius.contentCard),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(months, style: AppTextStyles.micro),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
