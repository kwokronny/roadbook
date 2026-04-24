// lib/features/travel/presentation/widgets/join_travel_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/glass_drawer.dart';
import '../../data/invite_code_cache.dart';
import '../../domain/travel_list_provider.dart';
import 'qr_scanner_screen.dart';

class JoinTravelSheet extends ConsumerStatefulWidget {
  const JoinTravelSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showGlassDrawer<void>(
      context: context,
      title: '加入旅程',
      builder: (_) => const JoinTravelSheet(),
    );
  }

  @override
  ConsumerState<JoinTravelSheet> createState() => _JoinTravelSheetState();
}

class _JoinTravelSheetState extends ConsumerState<JoinTravelSheet> {
  final _codeCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitByCode() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length != 4) {
      AppToast.error(context, '请输入 4 位邀请码');
      return;
    }
    final jwt = InviteCodeCache.lookup(code);
    if (jwt == null) {
      AppToast.error(context, '邀请码无效，请扫码加入');
      return;
    }
    await _accept(jwt);
  }

  Future<void> _scan() async {
    final raw = await QrScannerScreen.show(context);
    if (raw == null || !mounted) return;
    await _accept(raw);
  }

  Future<void> _accept(String jwt) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final travelId =
          await ref.read(travelRepositoryProvider).accept(jwt);
      if (!mounted) return;
      final router = GoRouter.of(context);
      ref.invalidate(travelListProvider);
      AppToast.success(context, '已加入旅程');
      Navigator.of(context).pop();
      router.go('/travel/$travelId');
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, 0, AppSpacing.pageHorizontal, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Input card
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('邀请码',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkSecondary,
                    )),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeCtrl,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 4,
                  enabled: !_submitting,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9]')),
                    _UpperCaseTextFormatter(),
                  ],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkPrimary,
                    letterSpacing: 10,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'A3K9',
                    hintStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkPrimary.withValues(alpha: 0.18),
                      letterSpacing: 10,
                    ),
                    filled: true,
                    fillColor: GlassSpec.inputOnGlassBg,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.cover),
                      borderSide: const BorderSide(
                          color: GlassSpec.inputOnGlassBorder, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.cover),
                      borderSide: const BorderSide(
                          color: GlassSpec.inputOnGlassBorder, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.cover),
                      borderSide: const BorderSide(
                          color: GlassSpec.inputFocusBorder, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                            height: 0.5, color: AppColors.separator)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('或',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkTertiary)),
                    ),
                    Expanded(
                        child: Container(
                            height: 0.5, color: AppColors.separator)),
                  ],
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _submitting ? null : _scan,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                          color: AppColors.inkPrimary.withValues(alpha: 0.15),
                          width: 1),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner,
                            size: 18, color: AppColors.inkSecondary),
                        SizedBox(width: 6),
                        Text('扫描二维码',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.inkSecondary,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ── CTA
          GestureDetector(
            onTap: _submitting ? null : _submitByCode,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.darkPill,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_submitting)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  else
                    const Text('加入旅程 →',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
