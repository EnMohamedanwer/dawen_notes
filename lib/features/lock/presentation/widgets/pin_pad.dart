import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/gradient_widgets.dart';

/// شاشة إدخال الـ PIN — قابلة للاستخدام للقفل العام وقفل النوتة
class PinPadDialog extends StatefulWidget {
  const PinPadDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onVerify,        // (pin) => bool
    this.onForgot,
    this.confirmMode = false,       // true لإنشاء PIN جديد
  });

  final String title;
  final String subtitle;
  final bool Function(String pin) onVerify;
  final VoidCallback? onForgot;
  final bool confirmMode;

  @override
  State<PinPadDialog> createState() => _PinPadDialogState();
}

class _PinPadDialogState extends State<PinPadDialog>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String _confirmPin = '';
  bool _confirming = false;
  bool _error = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween(begin: 0.0, end: 8.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _addDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += d;
      _error = false;
    });
    if (_pin.length == 4) _onPinComplete();
  }

  void _delete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _onPinComplete() {
    if (widget.confirmMode) {
      if (!_confirming) {
        setState(() {
          _confirmPin = _pin;
          _pin = '';
          _confirming = true;
        });
      } else {
        if (_pin == _confirmPin) {
          Navigator.pop(context, _pin);
        } else {
          _shake();
          setState(() {
            _pin = '';
            _confirming = false;
            _confirmPin = '';
            _error = true;
          });
        }
      }
    } else {
      if (widget.onVerify(_pin)) {
        Navigator.pop(context, true);
      } else {
        _shake();
        setState(() {
          _pin = '';
          _error = true;
        });
      }
    }
  }

  void _shake() {
    _shakeCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final dotActive = AppColors.primaryStart;
    final dotInactive = isDark ? Colors.white24 : Colors.black12;

    final title = widget.confirmMode && _confirming
        ? 'أكد الـ PIN'
        : widget.title;
    final subtitle = widget.confirmMode && _confirming
        ? 'أدخل الـ PIN مرة أخرى للتأكيد'
        : widget.subtitle;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة القفل
            GradientContainer(
              borderRadius: BorderRadius.circular(30),
              padding: const EdgeInsets.all(14),
              child: const Icon(Icons.lock_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: textColor.withValues(alpha: 0.6))),
            const SizedBox(height: 28),

            // ── نقاط الـ PIN ──
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(
                    _shakeCtrl.isAnimating
                        ? _shakeAnim.value *
                            (_shakeCtrl.value < 0.5 ? 1 : -1)
                        : 0,
                    0),
                child: child,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length ? dotActive : dotInactive,
                    ),
                  ),
                ),
              ),
            ),

            if (_error) ...[
              const SizedBox(height: 10),
              Text(
                widget.confirmMode
                    ? 'الـ PIN غير متطابق، حاول مجدداً'
                    : 'PIN خاطئ، حاول مجدداً',
                style: const TextStyle(
                    color: AppColors.importantColor, fontSize: 12),
              ),
            ],

            const SizedBox(height: 28),

            // ── لوحة الأرقام ──
            _buildPad(textColor, isDark),

            if (widget.onForgot != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onForgot,
                child: const Text('نسيت الـ PIN؟',
                    style: TextStyle(color: AppColors.primaryStart)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPad(Color textColor, bool isDark) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Column(
      children: keys.map((row) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: row.map((k) {
          if (k.isEmpty) return const SizedBox(width: 72, height: 72);
          return GestureDetector(
            onTap: () => k == '⌫' ? _delete() : _addDigit(k),
            child: Container(
              width: 72,
              height: 72,
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              child: Center(
                child: k == '⌫'
                    ? Icon(Icons.backspace_outlined,
                        color: textColor.withValues(alpha: 0.7), size: 22)
                    : Text(k,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: textColor)),
              ),
            ),
          );
        }).toList(),
      )).toList(),
    );
  }
}
