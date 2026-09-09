import 'dart:async';

import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/app/session_controller.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';
import 'package:innocence_flutter/features/auth/presentation/widgets/auth_experience.dart';

enum AuthMode {
  passwordLogin,
  codeLogin,
  register,
  passwordReset,
}

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    required this.sessionController,
    required this.appLanguage,
    required this.visualTheme,
    required this.onThemeChanged,
  });

  final SessionController sessionController;
  final AppLanguage appLanguage;
  final AppVisualTheme visualTheme;
  final ValueChanged<AppVisualTheme> onThemeChanged;

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
  bool get _needsPassword =>
      _mode == AuthMode.passwordLogin ||
      _mode == AuthMode.register ||
      _mode == AuthMode.passwordReset;
  bool get _needsCode =>
      _mode == AuthMode.codeLogin ||
      _mode == AuthMode.register ||
      _mode == AuthMode.passwordReset;

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

    switch (_mode) {
      case AuthMode.passwordLogin:
        return widget.sessionController.loginWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      case AuthMode.codeLogin:
        return widget.sessionController.loginWithCode(
          email: _emailController.text.trim(),
          emailCode: _codeController.text.trim(),
        );
      case AuthMode.register:
        return widget.sessionController.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          emailCode: _codeController.text.trim(),
        );
      case AuthMode.passwordReset:
        final succeeded = await widget.sessionController.resetPassword(
          email: _emailController.text.trim(),
          emailCode: _codeController.text.trim(),
          newPassword: _passwordController.text,
        );
        if (succeeded && mounted) {
          _codeController.clear();
          setState(() => _mode = AuthMode.passwordLogin);
        }
    }
  }

  Future<void> _enterOfflineMode() async {
    FocusScope.of(context).unfocus();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_language.isChinese ? '使用离线模式' : 'Use offline mode'),
          content: Text(
            _language.isChinese
                ? '计划、专注与备忘录会保存在此设备。好友、团队、通知、云端资料等联网功能暂不可用；登录后会先展示待导入摘要，只有你确认后才会上传。'
                : 'Plans, focus sessions, and memos stay on this device. Friends, teams, notifications, and cloud profile features are unavailable. After sign-in, you will review an import summary before anything uploads.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_language.isChinese ? '取消' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_language.isChinese ? '进入离线模式' : 'Continue offline'),
            ),
          ],
        );
      },
    );
    if (confirmed == true && mounted) {
      await widget.sessionController.enterOfflineMode();
    }
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
      if ((_mode == AuthMode.register || _mode == AuthMode.passwordReset) &&
          password.length < 6) {
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
    setState(() => _sendingCode = true);
    try {
      if (_mode == AuthMode.register) {
        await widget.sessionController.sendRegisterCode(email);
      } else if (_mode == AuthMode.passwordReset) {
        await widget.sessionController.sendResetPasswordCode(email);
      } else {
        await widget.sessionController.sendLoginCode(email);
      }
      if (!mounted) {
        return;
      }
      _startCountdown();
      _showMessage(_language.verificationCodeSentPrompt);
    } on ApiException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(_language.verificationCodeFailedPrompt);
      }
    } finally {
      if (mounted) {
        setState(() => _sendingCode = false);
      }
    }
  }

  void _startCountdown() {
    _codeTimer?.cancel();
    setState(() => _cooldownSeconds = 60);
    _codeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds -= 1);
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _switchMode(AuthMode mode) {
    if (_mode == mode) {
      return;
    }
    widget.sessionController.clearBanner();
    setState(() => _mode = mode);
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  String get _modeTitle => switch (_mode) {
        AuthMode.passwordLogin => _language.authPasswordLoginTitle,
        AuthMode.codeLogin => _language.authCodeLoginTitle,
        AuthMode.register => _language.authRegisterTitle,
        AuthMode.passwordReset =>
          _language.isChinese ? '重置密码' : 'Reset password',
      };

  String get _modeDescription => switch (_mode) {
        AuthMode.passwordLogin => _language.isChinese
            ? '欢迎回来。从一个清晰的选择开始今天。'
            : 'Welcome back. Begin today with one clear choice.',
        AuthMode.codeLogin => _language.isChinese
            ? '不用记住密码，使用邮箱验证码进入。'
            : 'Enter with a one-time email code, no password needed.',
        AuthMode.register => _language.isChinese
            ? '创建一个安静的学习空间，它会记住你的节奏。'
            : 'Create a quiet study space that remembers your rhythm.',
        AuthMode.passwordReset => _language.isChinese
            ? '验证邮箱后，为账户设置新密码。'
            : 'Verify your email, then choose a new password.',
      };

  String get _submitLabel => switch (_mode) {
        AuthMode.passwordLogin => _language.enterInnocenceLabel,
        AuthMode.codeLogin => _language.authCodeSubmitLabel,
        AuthMode.register => _language.authRegisterSubmitLabel,
        AuthMode.passwordReset =>
          _language.isChinese ? '确认重置密码' : 'Reset password',
      };

  String get _codeButtonLabel {
    if (_cooldownSeconds > 0) {
      return _language.cooldownLabel(_cooldownSeconds);
    }
    if (_mode == AuthMode.register) {
      return _language.sendRegisterCodeLabel;
    }
    if (_mode == AuthMode.passwordReset) {
      return _language.isChinese ? '发送重置验证码' : 'Send reset code';
    }
    return _language.sendLoginCodeLabel;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppVisualTokens.of(widget.visualTheme);
    return AuthExperience(
      language: _language,
      visualTheme: widget.visualTheme,
      onThemeChanged: widget.onThemeChanged,
      stageNumber: '02',
      title: _modeTitle,
      description: _modeDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_mode != AuthMode.passwordReset)
            _ModeRail(
              mode: _mode,
              language: _language,
              tokens: tokens,
              onChanged: _switchMode,
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _switchMode(AuthMode.passwordLogin),
                icon: const Icon(Icons.arrow_back_rounded, size: 17),
                label: Text(_language.isChinese ? '返回登录' : 'Back to sign in'),
                style: TextButton.styleFrom(foregroundColor: tokens.ink),
              ),
            ),
          const SizedBox(height: 22),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) => widget.sessionController.clearBanner(),
            decoration: InputDecoration(
              labelText: _language.isChinese ? '邮箱' : 'Email',
              hintText: 'name@example.com',
              prefixIcon: const Icon(Icons.alternate_email_rounded, size: 19),
            ),
          ),
          if (_needsPassword) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: _mode == AuthMode.passwordLogin
                  ? const [AutofillHints.password]
                  : const [AutofillHints.newPassword],
              onChanged: (_) => widget.sessionController.clearBanner(),
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: _mode == AuthMode.passwordReset
                    ? (_language.isChinese ? '新密码' : 'New password')
                    : (_language.isChinese ? '密码' : 'Password'),
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 19),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? (_language.isChinese ? '显示密码' : 'Show password')
                      : (_language.isChinese ? '隐藏密码' : 'Hide password'),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 19,
                  ),
                ),
              ),
            ),
          ],
          if (_needsCode) ...[
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final codeField = TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => widget.sessionController.clearBanner(),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText:
                        _language.isChinese ? '验证码' : 'Verification code',
                    prefixIcon: const Icon(Icons.password_rounded, size: 19),
                  ),
                );
                final sendButton = OutlinedButton(
                  onPressed:
                      _sendingCode || _cooldownSeconds > 0 ? null : _sendCode,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(132, 54),
                    foregroundColor: tokens.ink,
                    side: BorderSide(color: tokens.line),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: _sendingCode
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: tokens.accent,
                          ),
                        )
                      : Text(_codeButtonLabel),
                );
                if (constraints.maxWidth < 420) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      codeField,
                      const SizedBox(height: 10),
                      sendButton
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: codeField),
                    const SizedBox(width: 10),
                    sendButton,
                  ],
                );
              },
            ),
          ],
          if (_mode == AuthMode.passwordLogin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _switchMode(AuthMode.passwordReset),
                style: TextButton.styleFrom(foregroundColor: tokens.muted),
                child: Text(_language.isChinese ? '忘记密码？' : 'Forgot password?'),
              ),
            )
          else
            const SizedBox(height: 18),
          if (widget.sessionController.bannerMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              color: tokens.softPanel,
              child: Text(
                widget.sessionController.bannerMessage!,
                style: TextStyle(color: tokens.ink, fontSize: 13),
              ),
            ),
            const SizedBox(height: 14),
          ],
          ElevatedButton(
            onPressed: widget.sessionController.isBusy ? null : _submit,
            child: widget.sessionController.isBusy
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tokens.onAccent,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_submitLabel),
                      const Icon(Icons.arrow_forward_rounded, size: 19),
                    ],
                  ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed:
                widget.sessionController.isBusy ? null : _enterOfflineMode,
            icon: const Icon(Icons.offline_bolt_outlined, size: 18),
            label: Text(
              _language.isChinese ? '离线使用' : 'Continue offline',
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _language.isChinese
                ? '登录即表示你同意将学习数据安全保存在 Innocence。'
                : 'By continuing, your study data stays safely with Innocence.',
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.muted, fontSize: 11.5, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _ModeRail extends StatelessWidget {
  const _ModeRail({
    required this.mode,
    required this.language,
    required this.tokens,
    required this.onChanged,
  });

  final AuthMode mode;
  final AppLanguage language;
  final AppVisualTokens tokens;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <(AuthMode, String)>[
      (AuthMode.passwordLogin, language.isChinese ? '密码' : 'Password'),
      (AuthMode.codeLogin, language.isChinese ? '验证码' : 'Code'),
      (AuthMode.register, language.isChinese ? '注册' : 'Register'),
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.line)),
      ),
      child: Row(
        children: items.map((item) {
          final selected = item.$1 == mode;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(item.$1),
              child: Container(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? tokens.accent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  item.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? tokens.ink : tokens.muted,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
