// lib/features/travel/presentation/widgets/travel_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/travel.dart';

// ─── Status helpers ─────────────────────────────────────────────────────────

TravelStatusType computeTravelStatus(DateTime start, DateTime end) {
  final now = DateTime.now();
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay   = DateTime(end.year,   end.month,   end.day);
  final today    = DateTime(now.year,   now.month,   now.day);

  if (!today.isBefore(startDay) && !today.isAfter(endDay)) return TravelStatusType.ongoing;
  if (today.isAfter(endDay))                                return TravelStatusType.ended;
  final daysUntil = startDay.difference(today).inDays;
  return daysUntil <= 7 ? TravelStatusType.upcoming : TravelStatusType.planning;
}

String _labelFor(TravelStatusType status) => switch (status) {
  TravelStatusType.ongoing  => '旅行中',
  TravelStatusType.upcoming => '即将出发',
  TravelStatusType.planning => '规划中',
  TravelStatusType.ended    => '已结束',
};

// ─── TravelCard ─────────────────────────────────────────────────────────────

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
    final status = computeTravelStatus(travel.startDate, travel.endDate);
    final days   = travel.endDate.difference(travel.startDate).inDays + 1;
    final fmt    = DateFormat('MM/dd');

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: const [
              BoxShadow(color: Color(0x226478B4), blurRadius: 20, offset: Offset(0, 6)),
              BoxShadow(color: Color(0x0F6478B4), blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header: name + status badge ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    travel.name,
                    style: AppTextStyles.headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: status),
              ],
            ),
          ),

          // ── Date + days ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              '${fmt.format(travel.startDate)} — ${fmt.format(travel.endDate)}  ·  $days天',
              style: AppTextStyles.caption,
            ),
          ),

          // ── City tags ────────────────────────────────────────────────────
          if (travel.cities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (int i = 0; i < travel.cities.length && i < 4; i++)
                    _CityTag(city: travel.cities[i], index: i),
                ],
              ),
            ),

          // ── Dashed divider ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: CustomPaint(
              painter: _DashedLinePainter(color: const Color(0x141E243C)),
              size: const Size(double.infinity, 1),
            ),
          ),

          // ── Bottom row: collaborators + actions ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
            child: Row(
              children: [
                if (travel.collaborators.isNotEmpty)
                  _buildCollaborators(),
                const Spacer(),
                if (onEdit != null || onDelete != null)
                  _buildMoreMenu(),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildCollaborators() {
    final visible = travel.collaborators.take(5).toList();
    final overflow = travel.collaborators.length - 5;
    const double size = 26;
    const double overlap = 7;

    return SizedBox(
      width: size + (visible.length - 1) * (size - overlap) + (overflow > 0 ? 26 : 0),
      height: size,
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.tagAccents[i % AppColors.tagAccents.length].withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                ),
                child: ClipOval(
                  child: visible[i].user.avatar != null && visible[i].user.avatar!.isNotEmpty
                      ? Image.network(
                          visible[i].user.avatar!,
                          width: size, height: size, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _avatarFallback(
                              visible[i].user.name ?? visible[i].user.username, i),
                        )
                      : _avatarFallback(visible[i].user.name ?? visible[i].user.username, i),
                ),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: visible.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0x0D1E243C),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                ),
                child: Center(
                  child: Text('+$overflow',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String name, int index) {
    return Center(
      child: Text(
        name.characters.first,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.cityTagText(index),
        ),
      ),
    );
  }

  Widget _buildMoreMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, size: 18, color: AppColors.textTertiary),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: AppColors.surface,
      elevation: 4,
      itemBuilder: (_) => [
        if (onEdit != null)
          const PopupMenuItem(value: 'edit', height: 40,
            child: Row(children: [
              Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
              SizedBox(width: 10), Text('编辑'),
            ])),
        if (onDelete != null)
          const PopupMenuItem(value: 'delete', height: 40,
            child: Row(children: [
              Icon(Icons.delete_outline, size: 16, color: AppColors.destructive),
              SizedBox(width: 10), Text('删除', style: TextStyle(color: AppColors.destructive)),
            ])),
      ],
      onSelected: (v) {
        if (v == 'edit') onEdit?.call();
        if (v == 'delete') onDelete?.call();
      },
    );
  }
}

// ─── Status badge ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final TravelStatusType status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.statusBadgeBg(status),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.statusBadgeBorder(status), width: 1),
      ),
      child: Text(
        _labelFor(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.statusBadgeText(status),
        ),
      ),
    );
  }
}

// ─── City tag ───────────────────────────────────────────────────────────────

class _CityTag extends StatelessWidget {
  const _CityTag({required this.city, required this.index});
  final String city;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.cityTagBg(index),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.cityTagBorder(index), width: 1),
      ),
      child: Text(
        city,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.cityTagText(index),
        ),
      ),
    );
  }
}

// ─── Dashed line painter ────────────────────────────────────────────────────

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const dashWidth = 5.0;
    const dashGap = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) => old.color != color;
}
