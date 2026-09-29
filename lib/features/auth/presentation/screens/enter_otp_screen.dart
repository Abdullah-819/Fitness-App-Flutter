import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/utils/app_toast.dart';
import '../../data/auth_service.dart';
import 'create_new_password_screen.dart';

/// Pixel-accurate Enter OTP Code screen matching design 20_Light_enter OTP code.png.
class EnterOtpScreen extends StatefulWidget {
  final String email;

  const EnterOtpScreen({super.key, required this.email});

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  // 4 individual digit controllers & focus nodes
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _secondsRemaining = 56;
  Timer? _countdownTimer;
  bool _canResend = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _secondsRemaining = 56;
      _canResend = false;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _secondsRemaining = 0;
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      // If user pasted multi-digit code
      if (value.length > 1) {
        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
        for (int i = 0; i < 4 && i < digits.length; i++) {
          _controllers[i].text = digits[i];
        }
        if (digits.length >= 4) {
          _focusNodes[3].unfocus();
          _verifyOtp();
        } else {
          _focusNodes[digits.length.clamp(0, 3)].requestFocus();
        }
        return;
      }

      // Single digit entered, move to next box
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        // All 4 digits entered, auto-verify
        _verifyOtp();
      }
    }
  }

  void _onKeyDown(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _currentOtp;
    if (otp.length < 4) {
      AppToast.error('Please enter the complete 4-digit code');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final isValid = AuthService.instance.verifyOtp(
      email: widget.email,
      otp: otp,
    );

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    if (isValid) {
      AppToast.success('OTP verified successfully!');
      Navigator.of(context).pushReplacement(
        AppPageRoute(page: CreateNewPasswordScreen(email: widget.email)),
      );
    } else {
      AppToast.error('Invalid OTP code. Please enter 1234');
      // Clear fields and focus first box
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  void _handleResend() {
    if (!_canResend) return;
    _startCountdown();
    AppToast.success('New OTP code sent! Use code: 1234');
  }

  void _fillDemoOtp() {
    _controllers[0].text = '1';
    _controllers[1].text = '2';
    _controllers[2].text = '3';
    _controllers[3].text = '4';
    _focusNodes[3].unfocus();
    _verifyOtp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.password_rounded,
              color: AppColors.primaryPurple,
            ),
            tooltip: 'Auto-fill Demo Code (1234)',
            onPressed: _fillDemoOtp,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Title matching 20_Light_enter OTP code.png: "Enter OTP Code 🔐"
              const Text(
                'Enter OTP Code \u{1F510}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'Check your email inbox for a one-time passcode (OTP) '
                'from TrackFit. Enter the code below to continue.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 36),

              // 4 Individual OTP Input Boxes matching design
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final isFocused = _focusNodes[index].hasFocus;

                  return Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: isFocused
                          ? const Color(0xFFF7F2FF)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isFocused
                            ? AppColors.primaryPurple
                            : const Color(0xFFE5E7EB),
                        width: isFocused ? 2.0 : 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) => _onKeyDown(index, event),
                      child: TextField(
                        key: Key('otp_box_$index'),
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                        onChanged: (val) {
                          setState(() {});
                          _onDigitChanged(index, val);
                        },
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 36),

              // Resend code timer text
              Center(
                child: Text(
                  _canResend
                      ? "Didn't receive the code?"
                      : 'You can resend the code in $_secondsRemaining seconds',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Resend code button
              Center(
                child: TextButton(
                  key: const Key('resend_otp_button'),
                  onPressed: _canResend ? _handleResend : null,
                  child: Text(
                    'Resend code',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _canResend
                          ? AppColors.primaryPurple
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  key: const Key('verify_otp_button'),
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
