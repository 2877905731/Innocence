import 'dart:async';

import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/session_controller.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';
import 'package:innocence_flutter/core/widgets/desktop_drag_region.dart';

enum AuthMode {
  passwordLogin,
  codeLogin,
  register,
}

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    required this.sessionController,
    required this.appLanguage,
  });

  final SessionController sessionController;
  final AppLanguage appLanguage;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  Timer? _codeTimer;
  AuthMode _mode = AuthMode.passwordLogin;
  bool _obscurePassword = true;
  bool _sendingCode = false;
  int _cooldownSeconds = 0;

  AppLanguage get _language => widget.appLanguage;
  bool get _needsPassword => _mode != AuthMode.codeLogin;
  bool get _needsCode => _mode != AuthMode.passwordLogin;

  @override
  void initState() {
    super.initState();
    unawaited(DesktopWidgetBridge.setWindowMode('auth'));
  }

  @override
  void dispose() {
    _codeTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final validationMessage = _validateInputs();
    if (validationMessage != null) {
      _showMessage(validationMessage);
      return;
    }

    FocusScope.of(context).unfocus();
    widget.sessionController.clearBanner();

    if (_mode == AuthMode.passwordLogin) {
      await widget.sessionController.loginWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      return;
    }

    if (_mode == AuthMode.codeLogin) {
      await widget.sessionController.loginWithCode(
        email: _emailController.text.trim(),
        emailCode: _codeController.text.trim(),
      );
      return;
    }

    await widget.sessionController.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      emailCode: _codeController.text.trim(),
    );
  }

  String? _validateInputs() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      return _language.isChinese ? '请输入邮箱。' : 'Please enter your email.';
    }
    if (!_isValidEmail(email)) {
      return _language.isChinese ? '邮箱格式不正确。' : 'Invalid email format.';
    }

    if (_needsPassword) {
      final password = _passwordController.text;
      if (password.isEmpty) {
        return _language.isChinese ? '请输入密码。' : 'Please enter your password.';
      }
      if (_mode == AuthMode.register && password.length < 6) {
        return _language.isChinese
            ? '密码至少 6 位。'
            : 'Password must be at least 6 characters.';
      }
    }

    if (_needsCode && _codeController.text.trim().isEmpty) {
      return _language.isChinese
          ? '请输入验证码。'
          : 'Please enter the verification code.';
    }

    return null;
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      _showMessage(_language.invalidEmailPrompt);
      return;
    }

    setState(() {
      _sendingCode = true;
    });

    try {
      if (_mode == AuthMode.register) {
        await widget.sessionController.sendRegisterCode(email);
      } else {
        await widget.sessionController.sendLoginCode(email);
      }
      if (!mounted) {
        return;
      }
      _startCountdown();
      _showMessage(_language.verificationCodeSentPrompt);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage(_language.verificationCodeFailedPrompt);
    } finally {
      if (mounted) {
        setState(() {
          _sendingCode = false;
        });
      }
    }
  }

  void _startCountdown() {
    _codeTimer?.cancel();
    setState(() {
      _cooldownSeconds = 60;
    });
    _codeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _cooldownSeconds = 0;
        });
        return;
      }
      setState(() {
        _cooldownSeconds -= 1;
      });
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _switchMode(AuthMode mode) {
    if (_mode == mode) {
      return;
    }
    widget.sessionController.clearBanner();
    setState(() {
      _mode = mode;
    });
  }

  bool _isValidEmail(String value) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(value);
  }

  String get _modeTitle {
    switch (_mode) {
      case AuthMode.passwordLogin:
        return _language.authPasswordLoginTitle;
      case AuthMode.codeLogin:
        return _language.authCodeLoginTitle;
      case AuthMode.register:
        return _language.authRegisterTitle;
    }
  }

  String get _submitLabel {
    switch (_mode) {
      case AuthMode.passwordLogin:
        return _language.enterInnocenceLabel;
      case AuthMode.codeLogin:
        return _language.authCodeSubmitLabel;
      case AuthMode.register:
        return _language.authRegisterSubmitLabel;
    }
  }

  String get _codeButtonLabel {
    if (_cooldownSeconds > 0) {
      return _language.cooldownLabel(_cooldownSeconds);
    }
    if (_mode == AuthMode.register) {
      return _language.sendRegisterCodeLabel;
    }
    return _language.sendLoginCodeLabel;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppConfig.deviceType == 'windows';
    final sessionController = widget.sessionController;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = isDesktop ? 740.0 : constraints.maxWidth - 40;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 48 : 20,
                  isDesktop ? 28 : 18,
                  isDesktop ? 48 : 20,
                  26,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AuthHeader(
                        isDesktop: isDesktop,
                        isChinese: _language.isChinese,
                      ),
                      const SizedBox(height: 40),
                      _AuthFormSection(
                        mode: _mode,
                        modeTitle: _modeTitle,
                        submitLabel: _submitLabel,
                        codeButtonLabel: _codeButtonLabel,
                        isBusy: sessionController.isBusy,
                        sendingCode: _sendingCode,
                        cooldownSeconds: _cooldownSeconds,
                        bannerMessage: sessionController.bannerMessage,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        codeController: _codeController,
                        needsPassword: _needsPassword,
                        needsCode: _needsCode,
                        obscurePassword: _obscurePassword,
                        isChinese: _language.isChinese,
                        onModeChanged: _switchMode,
                        onTogglePasswordVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        onChanged: sessionController.clearBanner,
                        onSendCode: _sendCode,
                        onSubmit: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({
    required this.isDesktop,
    required this.isChinese,
  });

  final bool isDesktop;
  final bool isChinese;

  @override
  Widget build(BuildContext context) {
    final titleContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'INNOCENCE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: isDesktop ? 50 : 36,
            fontWeight: FontWeight.w800,
            letterSpacing: isDesktop ? 3.2 : 2.0,
            height: 1,
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Container(
            width: isDesktop ? 300 : 200,
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isChinese ? '专注陪伴与同步学习' : 'Focused study and synced progress',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF7A8090),
            fontSize: isDesktop ? 14 : 13,
          ),
        ),
      ],
    );

    if (!isDesktop) {
      return titleContent;
    }

    return SizedBox(
      height: 168,
      child: Stack(
        children: [
          const Positioned.fill(
            child: DesktopDragRegion(),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(child: titleContent),
            ),
          ),
          const Positioned(
            top: 2,
            right: 0,
            child: _UnifiedCloseButton(),
          ),
        ],
      ),
    );
  }
}

class _UnifiedCloseButton extends StatelessWidget {
  const _UnifiedCloseButton();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          await DesktopWidgetBridge.closeWindow();
        },
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4DAE3),
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.close_rounded,
            color: Color(0xFF111111),
            size: 19,
          ),
        ),
      ),
    );
  }
}

class _AuthFormSection extends StatelessWidget {
  const _AuthFormSection({
    required this.mode,
    required this.modeTitle,
    required this.submitLabel,
    required this.codeButtonLabel,
    required this.isBusy,
    required this.sendingCode,
    required this.cooldownSeconds,
    required this.bannerMessage,
    required this.emailController,
    required this.passwordController,
    required this.codeController,
    required this.needsPassword,
    required this.needsCode,
    required this.obscurePassword,
    required this.isChinese,
    required this.onModeChanged,
    required this.onTogglePasswordVisibility,
    required this.onChanged,
    required this.onSendCode,
    required this.onSubmit,
  });

  final AuthMode mode;
  final String modeTitle;
  final String submitLabel;
  final String codeButtonLabel;
  final bool isBusy;
  final bool sendingCode;
  final int cooldownSeconds;
  final String? bannerMessage;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController codeController;
  final bool needsPassword;
  final bool needsCode;
  final bool obscurePassword;
  final bool isChinese;
  final ValueChanged<AuthMode> onModeChanged;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onChanged;
  final Future<void> Function() onSendCode;
  final Future<void> Function() onSubmit;

  String get _passwordSegmentLabel => isChinese ? '密码登录' : 'Password';
  String get _codeSegmentLabel => isChinese ? '验证码' : 'Code';
  String get _registerSegmentLabel => isChinese ? '注册' : 'Register';
  String get _emailLabel => isChinese ? '邮箱' : 'Email';
  String get _emailHint => isChinese ? '请输入邮箱地址' : 'Enter your email';
  String get _passwordLabel => isChinese ? '密码' : 'Password';
  String get _passwordHint => isChinese ? '请输入密码' : 'Enter your password';
  String get _newPasswordHint => isChinese ? '至少 6 位密码' : 'At least 6 characters';
  String get _emailCodeLabel => isChinese ? '邮箱验证码' : 'Email code';
  String get _emailCodeHint => isChinese ? '请输入收到的验证码' : 'Enter the code';

  @override
  Widget build(BuildContext context) {
    final disableDesktopAutofill = AppConfig.deviceType == 'windows';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          modeTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: _AuthModeButton(
                label: _passwordSegmentLabel,
                selected: mode == AuthMode.passwordLogin,
                enabled: !isBusy,
                onTap: () => onModeChanged(AuthMode.passwordLogin),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _AuthModeButton(
                label: _codeSegmentLabel,
                selected: mode == AuthMode.codeLogin,
                enabled: !isBusy,
                onTap: () => onModeChanged(AuthMode.codeLogin),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _AuthModeButton(
                label: _registerSegmentLabel,
                selected: mode == AuthMode.register,
                enabled: !isBusy,
                onTap: () => onModeChanged(AuthMode.register),
              ),
            ),
          ],
        ),
        if (bannerMessage != null) ...[
          const SizedBox(height: 18),
          _AuthBanner(message: bannerMessage!),
        ],
        const SizedBox(height: 30),
        _LabeledTextField(
          label: _emailLabel,
          controller: emailController,
          hintText: _emailHint,
          keyboardType: TextInputType.emailAddress,
          obscureText: false,
          autofillHints:
              disableDesktopAutofill ? null : const [AutofillHints.email],
          onChanged: onChanged,
        ),
        if (needsPassword) ...[
          const SizedBox(height: 20),
          _LabeledTextField(
            label: _passwordLabel,
            controller: passwordController,
            hintText: mode == AuthMode.register ? _newPasswordHint : _passwordHint,
            keyboardType: TextInputType.text,
            obscureText: obscurePassword,
            autofillHints: disableDesktopAutofill
                ? null
                : mode == AuthMode.register
                    ? const [AutofillHints.newPassword]
                    : const [AutofillHints.password],
            trailing: IconButton(
              onPressed: onTogglePasswordVisibility,
              splashRadius: 18,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: const Color(0xFF7A869A),
              ),
            ),
            onChanged: onChanged,
          ),
        ],
        if (needsCode) ...[
          const SizedBox(height: 20),
          _LabeledTextField(
            label: _emailCodeLabel,
            controller: codeController,
            hintText: _emailCodeHint,
            keyboardType: TextInputType.number,
            obscureText: false,
            onChanged: onChanged,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: (isBusy || sendingCode || cooldownSeconds > 0)
                    ? null
                    : () async {
                        await onSendCode();
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF111111),
                  side: const BorderSide(color: Color(0xFFD2D8E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(codeButtonLabel),
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: isBusy
                ? null
                : () async {
                    await onSubmit();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111111),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isBusy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(submitLabel),
          ),
        ),
      ],
    );
  }
}

class _AuthBanner extends StatelessWidget {
  const _AuthBanner({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFD5D5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFB64646),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF5A2A2A),
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthModeButton extends StatelessWidget {
  const _AuthModeButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 64,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF111111) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? const Color(0xFF111111) : const Color(0xFFD2D8E1),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF111111),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledTextField extends StatefulWidget {
  const _LabeledTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    required this.obscureText,
    required this.onChanged,
    this.trailing,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final VoidCallback onChanged;
  final Widget? trailing;
  final Iterable<String>? autofillHints;

  @override
  State<_LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<_LabeledTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleTextChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final hasText = widget.controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isFocused
                  ? const Color(0xFF111111)
                  : const Color(0xFFD8DEE8),
              width: isFocused ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    if (!hasText)
                      IgnorePointer(
                        child: Text(
                          widget.hintText,
                          style: const TextStyle(
                            color: Color(0xFF8B94A3),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    EditableText(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      textDirection: Directionality.of(context),
                      keyboardType: widget.keyboardType,
                      obscureText: widget.obscureText,
                      autofillHints: widget.autofillHints,
                      autocorrect: false,
                      enableSuggestions: !widget.obscureText,
                      minLines: 1,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 15,
                      ),
                      cursorColor: const Color(0xFF111111),
                      backgroundCursorColor: const Color(0xFF111111),
                      selectionColor: const Color(0x33111111),
                      rendererIgnoresPointer: false,
                      cursorRadius: const Radius.circular(2),
                      cursorWidth: 1.8,
                      onChanged: (_) => widget.onChanged(),
                    ),
                  ],
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: 8),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
