// lib/features/travel/presentation/widgets/travel_card_skeleton.dart
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/skeleton.dart';

class TravelCardSkeleton extends StatelessWidget {
  const TravelCardSkeleton({super.key});

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
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                color: GlassSpec.cardBg,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                    color: const Color(0x40FFFFFF), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: name (with right space for more button)
                  const Padding(
                    padding: EdgeInsets.only(right: 36),
                    child: Bone(height: 20),
                  ),
                  const SizedBox(height: 10),
                  // Row 2: status pill + spacer + X天·X人
                  Row(
                    children: [
                      const Bone(
                        width: 72,
                        height: 24,
                        borderRadius:
                            BorderRadius.all(Radius.circular(AppRadius.pill)),
                      ),
                      const Spacer(),
                      Bone(
                        width: 56,
                        height: 14,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Bottom row: avatar circles + city chips
                  Row(
                    children: [
                      // 3 avatar circles overlapping
                      for (int i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 4),
                        const Bone(width: 28, height: 28, isCircle: true),
                      ],
                      const Spacer(),
                      // 2 city chips
                      const Bone(
                        width: 48,
                        height: 20,
                        borderRadius:
                            BorderRadius.all(Radius.circular(AppRadius.pill)),
                      ),
                      const SizedBox(width: 4),
                      const Bone(
                        width: 40,
                        height: 20,
                        borderRadius:
                            BorderRadius.all(Radius.circular(AppRadius.pill)),
                      ),
                    ],
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
