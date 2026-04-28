// lib/features/schedule/presentation/widgets/day_sidebar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import 'package:hugeicons/hugeicons.dart';


/// Horizontal scrollable day bar with sliding glass indicator (like dock).
class DayBar extends StatefulWidget {
  const DayBar({
    super.key,
    required this.totalDays,
    required this.selectedDay,
    required this.travelStartDate,
    required this.onDaySelected,
    this.enabled = true,
  });

  final int totalDays;
  final int selectedDay;
  final DateTime travelStartDate;
  final ValueChanged<int> onDaySelected;
  final bool enabled;

  @override
  State<DayBar> createState() => _DayBarState();
}

class _DayBarState extends State<DayBar> with TickerProviderStateMixin {
  static const _weekLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  static const _barHeight = 54.0;
  static const _itemWidth = 72.0;
  static const _itemPad = 4.0;
  static const _spring = Cubic(0.34, 1.3, 0.64, 1.0);

  final ScrollController _scrollCtrl = ScrollController();
  late final AnimationController _slideCtrl;
  int _prevIndex = 0;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  List<int> get _days => [for (int d = 1; d <= widget.totalDays; d++) d, 0];

  int _dayToIndex(int day) {
    final idx = _days.indexOf(day);
    return idx >= 0 ? idx : 0;
  }

  String _weekLabel(int day) {
    final date = widget.travelStartDate.add(Duration(days: day - 1));
    return _weekLabels[date.weekday - 1];
  }

  @override
  void initState() {
    super.initState();
    _prevIndex = _dayToIndex(widget.selectedDay);
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..value = 1.0;

    _scrollCtrl.addListener(() {
      _updateScrollIndicators();
      setState(() {}); // repaint indicator with new scroll offset
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollIndicators());
  }

  @override
  void didUpdateWidget(covariant DayBar old) {
    super.didUpdateWidget(old);
    if (old.selectedDay != widget.selectedDay) {
      _prevIndex = _dayToIndex(old.selectedDay);
      _slideCtrl.forward(from: 0);
      _scrollToActive();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollIndicators());
  }

  void _scrollToActive() {
    if (!_scrollCtrl.hasClients) return;
    final idx = _dayToIndex(widget.selectedDay);
    final viewW = _scrollCtrl.position.viewportDimension;
    final target = (idx * (_itemWidth + _itemPad)) - (viewW / 2) + (_itemWidth / 2);
    _scrollCtrl.animateTo(
      target.clamp(0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _updateScrollIndicators() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    final l = pos.pixels > 0;
    final r = pos.pixels < pos.maxScrollExtent - 1;
    if (l != _canScrollLeft || r != _canScrollRight) {
      setState(() { _canScrollLeft = l; _canScrollRight = r; });
    }
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  double _indicatorLeft(int index) {
    final scrollOffset = _scrollCtrl.hasClients ? _scrollCtrl.offset : 0.0;
    return _itemPad + index * (_itemWidth + _itemPad) - scrollOffset;
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;
    final curIndex = _dayToIndex(widget.selectedDay);

    return AnimatedOpacity(
      opacity: widget.enabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !widget.enabled,
        child: Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal, vertical: 4),
      child: SizedBox(
        height: _barHeight,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, 6)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0x40FFFFFF),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: const Color(0x80FFFFFF)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final barH = constraints.maxHeight;
                    return Stack(
                  children: [
                    // ── Specular top line
                    Positioned(
                      top: 0, left: 24, right: 24,
                      child: IgnorePointer(
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Color(0x00FFFFFF), Color(0x55FFFFFF), Color(0x00FFFFFF),
                            ]),
                          ),
                        ),
                      ),
                    ),

                    // ── Sliding glass indicator
                    AnimatedBuilder(
                      animation: Listenable.merge([_slideCtrl, _scrollCtrl]),
                      builder: (context, _) {
                        final t = _spring.transform(_slideCtrl.value.clamp(0.0, 1.0));
                        final fromL = _indicatorLeft(_prevIndex);
                        final toL = _indicatorLeft(curIndex);
                        final left = fromL + (toL - fromL) * t;

                        // Motion blur alpha
                        final blur = (1.0 - (2.0 * t - 1.0).abs()).clamp(0.0, 1.0);
                        final alpha = 0.45 - blur * 0.20;

                        return Positioned(
                          left: left,
                          top: _itemPad,
                          width: _itemWidth,
                          height: barH - _itemPad * 2,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, alpha),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                border: Border.all(color: const Color(0x80FFFFFF)),
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  gradient: const LinearGradient(
                                    begin: Alignment(-0.5, -0.87),
                                    end: Alignment(0.5, 0.87),
                                    colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
                                    stops: [0.0, 0.45],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // ── Scrollable day items
                    ListView.separated(
                      controller: _scrollCtrl,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(_itemPad),
                      itemCount: days.length,
                      separatorBuilder: (_, __) => const SizedBox(width: _itemPad),
                      itemBuilder: (context, i) {
                        final day = days[i];
                        final isSelected = day == widget.selectedDay;
                        return GestureDetector(
                          onTap: widget.enabled ? () => widget.onDaySelected(day) : null,
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: _itemWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day == 0 ? '待规划' : 'Day $day',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.inkTertiary,
                                  ),
                                ),
                                if (day > 0)
                                  Text(
                                    _weekLabel(day),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.inkTertiary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // ── Left scroll button
                    if (_canScrollLeft)
                      Positioned(
                        left: 0, top: 0, bottom: 0,
                        child: GestureDetector(
                          onTap: () => _scrollCtrl.animateTo(
                            (_scrollCtrl.offset - 120).clamp(0, _scrollCtrl.position.maxScrollExtent),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          ),
                          child: Container(
                            width: 48,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(AppRadius.pill)),
                              gradient: LinearGradient(
                                colors: [Color(0xE6FFFFFF), Color(0x00FFFFFF)],
                              ),
                            ),
                            child: const Align(
                              alignment: Alignment(-0.2, 0),
                              child: Icon(HugeIcons.strokeRoundedArrowLeft01,
                                  size: 24, color: AppColors.inkPrimary),
                            ),
                          ),
                        ),
                      ),
                    // ── Right scroll button
                    if (_canScrollRight)
                      Positioned(
                        right: 0, top: 0, bottom: 0,
                        child: GestureDetector(
                          onTap: () => _scrollCtrl.animateTo(
                            (_scrollCtrl.offset + 120).clamp(0, _scrollCtrl.position.maxScrollExtent),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          ),
                          child: Container(
                            width: 48,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(AppRadius.pill)),
                              gradient: LinearGradient(
                                colors: [Color(0x00FFFFFF), Color(0xE6FFFFFF)],
                              ),
                            ),
                            child: const Align(
                              alignment: Alignment(0.2, 0),
                              child: Icon(HugeIcons.strokeRoundedArrowRight01,
                                  size: 24, color: AppColors.inkPrimary),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      ),
      ),
    );
  }
}
