// lib/features/schedule/presentation/widgets/schedule_item_skeleton.dart
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/skeleton.dart';

class ScheduleItemSkeleton extends StatelessWidget {
  const ScheduleItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: GlassSpec.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: BackdropFilter(
            filter: GlassSpec.cardBlur,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: BoxDecoration(
                color: GlassSpec.cardBg,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                    color: const Color(0x40FFFFFF), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover image placeholder (matches _CoverImage: 52x52)
                  const Bone(
                    width: 52,
                    height: 52,
                    borderRadius:
                        BorderRadius.all(Radius.circular(10)),
                  ),
                  const SizedBox(width: 10),
                  // Right column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time badge pill
                        const Bone(
                          width: 70,
                          height: 22,
                          borderRadius: BorderRadius.all(
                              Radius.circular(AppRadius.pill)),
                        ),
                        const SizedBox(height: 6),
                        // Name line
                        const Bone(height: 17),
                        const SizedBox(height: 5),
                        // Address line (shorter)
                        Bone(
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: 13,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
