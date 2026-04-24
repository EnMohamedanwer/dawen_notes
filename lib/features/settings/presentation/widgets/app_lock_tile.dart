import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/lock_service.dart';
import '../../../lock/presentation/widgets/pin_pad.dart';

/// أضف هذا الـ Widget في SettingsPage ضمن قسم "إعدادات التطبيق"
/// مثال: AppLockTile(lockService: di.sl<LockService>())
class AppLockTile extends StatefulWidget {
  const AppLockTile({super.key, required this.lockService});
  final LockService lockService;

  @override
  State<AppLockTile> createState() => _AppLockTileState();
}

class _AppLockTileState extends State<AppLockTile> {
  bool get _enabled => widget.lockService.isAppLockEnabled;

  Future<void> _toggle() async {
    if (_enabled) {
      final ok = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PinPadDialog(
          title: 'تعطيل القفل',
          subtitle: 'أدخل الـ PIN الحالي للتأكيد',
          onVerify: (pin) => widget.lockService.verifyAppPin(pin),
        ),
      );
      if (ok == true) {
        await widget.lockService.disableAppLock();
        if (mounted) setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم تعطيل قفل التطبيق'),
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    } else {
      final pin = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PinPadDialog(
          title: 'قفل التطبيق',
          subtitle: 'أدخل PIN من 4 أرقام',
          onVerify: (_) => true,
          confirmMode: true,
        ),
      );
      if (pin != null && pin.length == 4) {
        await widget.lockService.enableAppLock(pin);
        if (mounted) setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('✅ تم تفعيل قفل التطبيق'),
            backgroundColor: AppColors.personalColor,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: ext.cardBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Row(children: [
        Switch(
          value: _enabled,
          onChanged: (_) => _toggle(),
          activeColor: AppColors.primaryStart,
        ),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('قفل التطبيق',
              style: TextStyle(fontSize: 15, color: ext.textPrimary)),
          Text(
            _enabled ? 'مفعّل — PIN مطلوب عند الفتح' : 'معطّل',
            style: TextStyle(fontSize: 12, color: ext.textHint),
          ),
        ]),
        const SizedBox(width: 12),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _enabled
                ? AppColors.primaryStart.withValues(alpha: 0.15)
                : ext.inputBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _enabled ? Icons.lock_rounded : Icons.lock_open_rounded,
            color: _enabled ? AppColors.primaryStart : ext.textHint,
            size: 20,
          ),
        ),
      ]),
    );
  }
}
