import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/lock_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/pin_pad.dart';

class AppLockPage extends StatelessWidget {
  const AppLockPage({
    super.key,
    required this.lockService,
    required this.onUnlocked,
  });

  final LockService lockService;
  final VoidCallback onUnlocked;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // لا يمكن الرجوع بدون إدخال PIN
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: PinPadDialog(
              title: 'التطبيق محمي',
              subtitle: 'أدخل الـ PIN للمتابعة',
              onVerify: (pin) {
                if (lockService.verifyAppPin(pin)) {
                  onUnlocked();
                  return true;
                }
                return false;
              },
              onForgot: () => _showForgotDialog(context),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('نسيت الـ PIN؟', textAlign: TextAlign.end),
        content: const Text(
          'لا يمكن استعادة الـ PIN. يجب إعادة تثبيت التطبيق لإزالة القفل.',
          textAlign: TextAlign.end,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: const Text('حسناً'),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop(); // أغلق التطبيق
            },
            child: const Text('إغلاق التطبيق',
                style: TextStyle(color: AppColors.importantColor)),
          ),
        ],
      ),
    );
  }
}
