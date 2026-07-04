import 'dart:async';

import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/session_controller.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/core/theme/app_colors.dart';
import 'package:innocence_flutter/core/widgets/aurora_background.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/status_banner.dart';

enum AuthMode {
  passwordLogin,
  codeLogin,
  register,
}

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    required this.sessionController,
  });

  final SessionController sessionController;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  Timer? _codeTimer;
  AuthMode _mode = AuthMode.passwordLogin;
  bool _obscurePassword = true;
  bool _sendingCode = false;
  int _cooldownSeconds = 0;

  bool get _needsPassword => _mode != AuthMode.codeLogin;
  bool get _needsCode => _mode != AuthMode.passwordLogin;

  @override
  void dispose() {
    _codeTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
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

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      _showMessage('Please enter a valid email first.');
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
      _showMessage('Verification code sent. Please check your inbox.');
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Failed to send the verification code.');
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

  String get _deviceLabel {
    if (AppConfig.deviceType == 'android') {
      return 'Android';
    }
    return 'Windows';
  }

  String get _modeTitle {
    switch (_mode) {
      case AuthMode.passwordLogin:
        return 'Password login';
      case AuthMode.codeLogin:
        return 'Code login';
      case AuthMode.register:
        return 'Email register';
    }
  }

  String get _modeDescription {
    switch (_mode) {
      case AuthMode.passwordLogin:
        return 'Use email and password for your usual sign-in flow.';
      case AuthMode.codeLogin:
        return 'Receive a code by email for quick access on this device.';
      case AuthMode.register:
        return 'Create a new account and sign in right away.';
    }
  }

  String get _submitLabel {
    switch (_mode) {
      case AuthMode.passwordLogin:
        return 'Enter Innocence';
      case AuthMode.codeLogin:
        return 'Sign in with code';
      case AuthMode.register:
        return 'Register and sign in';
    }
  }

  String get _codeButtonLabel {
    if (_cooldownSeconds > 0) {
      return 'Retry in $_cooldownSeconds s';
    }
    if (_mode == AuthMode.register) {
      return 'Send register code';
    }
    return 'Send login code';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sessionController = widget.sessionController;

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;
              final formCard = ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: GlassPanel(
                  child: _FormCard(
                    formKey: _formKey,
                    mode: _mode,
                    modeTitle: _modeTitle,
                    modeDescription: _modeDescription,
                    submitLabel: _submitLabel,
                    codeButtonLabel: _codeButtonLabel,
                    deviceLabel: _deviceLabel,
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
                ),
              );

              final intro = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Innocence', style: textTheme.displaySmall),
                  const SizedBox(height: 14),
                  Text(
                    'Keep phone and desktop in the same learning rhythm. '
                    'This phase focuses on a stable account bridge first.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FeatureChip(label: 'Android + Windows'),
                      _FeatureChip(label: '1 phone + 1 desktop online'),
                      _FeatureChip(label: 'Profile visible to friends only'),
                      _FeatureChip(label: 'Study data visible to teammates'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const GlassPanel(
                    child: _IntroCard(),
                  ),
                ],
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: intro),
                              const SizedBox(width: 24),
                              formCard,
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              intro,
                              const SizedBox(height: 24),
                              formCard,
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.mode,
    required this.modeTitle,
    required this.modeDescription,
    required this.submitLabel,
    required this.codeButtonLabel,
    required this.deviceLabel,
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
    required this.onModeChanged,
    required this.onTogglePasswordVisibility,
    required this.onChanged,
    required this.onSendCode,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final AuthMode mode;
  final String modeTitle;
  final String modeDescription;
  final String submitLabel;
  final String codeButtonLabel;
  final String deviceLabel;
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
  final ValueChanged<AuthMode> onModeChanged;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onChanged;
  final Future<void> Function() onSendCode;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(modeTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(modeDescription, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        SegmentedButton<AuthMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: AuthMode.passwordLogin,
              label: Text('Password'),
            ),
            ButtonSegment(
              value: AuthMode.codeLogin,
              label: Text('Code'),
            ),
            ButtonSegment(
              value: AuthMode.register,
              label: Text('Register'),
            ),
          ],
          selected: {mode},
          onSelectionChanged: isBusy
              ? null
              : (selection) {
                  onModeChanged(selection.first);
                },
        ),
        if (bannerMessage != null) ...[
          const SizedBox(height: 18),
          StatusBanner(message: bannerMessage!),
        ],
        const SizedBox(height: 18),
        Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your registration email',
                ),
                onChanged: (_) => onChanged(),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Please enter your email.';
                  }
                  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!regex.hasMatch(text)) {
                    return 'Invalid email format.';
                  }
                  return null;
                },
              ),
              if (needsPassword) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  autofillHints: mode == AuthMode.register
                      ? const [AutofillHints.newPassword]
                      : const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: mode == AuthMode.register
                        ? 'At least 6 characters'
                        : 'Enter your password',
                    suffixIcon: IconButton(
                      onPressed: onTogglePasswordVisibility,
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                    ),
                  ),
                  onChanged: (_) => onChanged(),
                  validator: (value) {
                    final text = value ?? '';
                    if (text.isEmpty) {
                      return 'Please enter your password.';
                    }
                    if (mode == AuthMode.register && text.length < 6) {
                      return 'Password must be at least 6 characters.';
                    }
                    return null;
                  },
                ),
              ],
              if (needsCode) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Email code',
                    hintText: 'Enter the verification code',
                  ),
                  onChanged: (_) => onChanged(),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Please enter the verification code.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: (isBusy || sendingCode || cooldownSeconds > 0)
                        ? null
                        : () async {
                            await onSendCode();
                          },
                    child: Text(codeButtonLabel),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: isBusy
                    ? null
                    : () async {
                        await onSubmit();
                      },
                child: isBusy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(submitLabel),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.devices_rounded,
                    color: AppColors.mint,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Current device: $deviceLabel. '
                      'This app keeps one phone and one desktop online.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current scope', style: textTheme.titleMedium),
        const SizedBox(height: 14),
        const _IntroRow(
          icon: Icons.mark_email_read_rounded,
          text: 'Email + password login, email code login, and email register',
        ),
        const SizedBox(height: 10),
        const _IntroRow(
          icon: Icons.security_rounded,
          text: 'Session restore, local device id, and profile bootstrap',
        ),
        const SizedBox(height: 10),
        const _IntroRow(
          icon: Icons.auto_awesome_rounded,
          text: 'Glass UI direction remains for the desktop experience',
        ),
      ],
    );
  }
}

class _IntroRow extends StatelessWidget {
  const _IntroRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.mint, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
      ),
    );
  }
}
