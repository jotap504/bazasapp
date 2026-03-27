import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart' show Session, AuthResponse, AuthState, User;
import 'package:bazas/core/router/app_router.dart';
import 'package:bazas/features/auth/data/repositories/auth_repository.dart';
import 'package:bazas/core/providers/supabase_client_provider.dart';
import 'package:bazas/core/utils/debug_logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      if (mounted) {
        ref.read(debugLoggerProvider.notifier).addLog('Navegando a Home (login exitoso)', level: LogLevel.info);
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neonGreenDim,
                          border: Border.all(color: AppColors.neonGreen, width: 2),
                        ),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedChampion,
                          color: AppColors.neonGreen,
                          size: 48,
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'BAZAS',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displaySmall,
                    ),
                    const SizedBox(height: 48),

                    TextFormField(
                      controller: _emailController,
                      autofillHints: const [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'EMAIL',
                        prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedMail01, color: Colors.white, size: 20),
                      ),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      autofillHints: const [AutofillHints.password],
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'PASSWORD',
                        prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedLock, color: Colors.white, size: 20),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: HugeIcon(
                            icon: _obscurePassword ? HugeIcons.strokeRoundedView : HugeIcons.strokeRoundedViewOff,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('ENGAGE ENGINE (LOGIN)'),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.register),
                      child: const Text('NO TENGO CUENTA (PIT STOP)'),
                    ),
                    
                    const Divider(height: 48, color: Colors.white10),
                    
                    // --- MODO DEBUG ---
                    Consumer(
                      builder: (context, ref, child) {
                        return Center(
                          child: Column(
                            children: [
                                Text(
                                  'API: ${dotenv.env['SUPABASE_URL']}',
                                  style: const TextStyle(fontSize: 9, color: Colors.white24),
                                ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  ref.read(debugLoggerProvider.notifier).addLog('Bypass login activado - Forzando navegación', level: LogLevel.warning);
                                  context.go(AppRoutes.home);
                                },
                                child: const Text('DEBUG: SALTAR LOGIN (GUEST)', 
                                  style: TextStyle(color: AppColors.neonCyan, fontSize: 10)),
                              ),
                            ],
                          ),
                        );
                      },
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
