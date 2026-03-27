// lib/features/travel/presentation/widgets/travel_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/travel.dart';

// ─── Status enum (4 states) ──────────────────────────────────────────────────

enum TravelStatus { ongoing, upcoming, planning, ended }

TravelStatus computeTravelStatus(DateTime start, DateTime end) {
  final now = DateTime.now();
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay   = DateTime(end.year,   end.month,   end.day);
  final today    = DateTime(now.year,   now.month,   now.day);

  // startDay ≤ today ≤ endDay
  if (!today.isBefore(startDay) && !today.isAfter(endDay)) return TravelStatus.ongoing;
  if (today.isAfter(endDay))                                return TravelStatus.ended;
  // today < startDay
  final daysUntil = startDay.difference(today).inDays;
  return daysUntil <= 7 ? TravelStatus.upcoming : TravelStatus.planning;
}

// ─── TravelCard ──────────────────────────────────────────────────────────────

class TravelCard extends StatelessWidget {
  const TravelCard({
    super.key,
    required this.travel,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Travel travel;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final status   = computeTravelStatus(travel.startDate, travel.endDate);
    final gradient = _gradientFor(status);
    final days     = travel.endDate.difference(travel.startDate).inDays + 1;
    final fmt      = DateFormat('MM/dd');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              // ── Left icon box ──────────────────────────────────────────
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconFor(status), color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),

              // ── Content ───────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      travel.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (travel.cities.isNotEmpty)
                      Text(
                        travel.cities.join(' · '),
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.75)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${fmt.format(travel.startDate)} — ${fmt.format(travel.endDate)}  ·  $days 天',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius:
                                BorderRadius.circular(AppRadius.badge),
                          ),
                          child: Text(
                            _labelFor(status),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── More menu ─────────────────────────────────────────────
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      size: 18, color: Colors.white.withValues(alpha: 0.8)),
                  padding: EdgeInsets.zero,
                  itemBuilder: (_) => [
                    if (onEdit != null)
                      const PopupMenuItem(value: 'edit', child: Text('编辑')),
                    if (onDelete != null)
                      const PopupMenuItem(
                          value: 'delete',
                          child: Text('删除',
                              style: TextStyle(color: Colors.red))),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  static LinearGradient _gradientFor(TravelStatus status) => switch (status) {
        TravelStatus.ongoing   => AppColors.ongoingGradient,
        TravelStatus.upcoming  => AppColors.upcomingGradient,
        TravelStatus.planning  => AppColors.planningGradient,
        TravelStatus.ended     => AppColors.endedGradient,
      };

  static IconData _iconFor(TravelStatus status) => switch (status) {
        TravelStatus.ongoing   => Icons.flight_takeoff_outlined,
        TravelStatus.upcoming  => Icons.access_time_outlined,
        TravelStatus.planning  => Icons.map_outlined,
        TravelStatus.ended     => Icons.check_circle_outline,
      };

  static String _labelFor(TravelStatus status) => switch (status) {
        TravelStatus.ongoing   => '旅行中',
        TravelStatus.upcoming  => '即将出发',
        TravelStatus.planning  => '规划中',
        TravelStatus.ended     => '已结束',
      };
}
