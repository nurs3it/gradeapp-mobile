import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _otp = TextEditingController();
  bool _needOtp = false;
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _otp.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    if (_email.text.trim().isEmpty || _password.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).login(_email.text, _password.text, otp: _needOtp ? _otp.text.trim() : null);
      final user = ref.read(authProvider).value;
      if (user != null && user.appRoles.isEmpty) {
        await ref.read(authProvider.notifier).logout();
        _error = l.loginNoRole;
      }
    } on OtpRequired {
      _needOtp = true;
    } on DioException catch (e) {
      unawaited(HapticFeedback.heavyImpact());
      final body = e.response?.data;
      _error = isOffline(e)
          ? l.errorMessage
          : (body is Map && body['otp'] != null)
          ? l.loginOtpInvalid
          : l.loginInvalid;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(GSpace.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: GradeAppMark(size: 72)),
                    const SizedBox(height: GSpace.md),
                    const Center(child: GradeAppWordmark(size: 28)),
                    const SizedBox(height: GSpace.xxl),
                    Text(l.loginTitle, style: context.t.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: GSpace.xs),
                    Text(
                      l.loginSubtitle,
                      style: context.t.bodyMedium!.copyWith(color: c.mutedForeground),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: GSpace.xl),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username, AutofillHints.email],
                      decoration: InputDecoration(labelText: l.email),
                    ),
                    const SizedBox(height: GSpace.md),
                    TextField(
                      controller: _password,
                      obscureText: _obscure,
                      textInputAction: _needOtp ? TextInputAction.next : TextInputAction.go,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l.password,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: GMotion.base,
                      curve: GMotion.easeOut,
                      child: _needOtp
                          ? Padding(
                              padding: const EdgeInsets.only(top: GSpace.md),
                              child: TextField(
                                controller: _otp,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                autofillHints: const [AutofillHints.oneTimeCode],
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                onSubmitted: (_) => _submit(),
                                decoration: InputDecoration(labelText: l.otpCode, hintText: l.otpHint),
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: GSpace.md),
                      Text(
                        _error!,
                        style: context.t.bodyMedium!.copyWith(color: c.destructiveText),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: GSpace.xl),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(l.signIn),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
