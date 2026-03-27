import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/features/auth/data/repositories/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            displayName: _displayNameController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso. ¡Bienvenido a Bazas!'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        // Supabase inicia sesión automáticamente tras el registro si el mail no requiere confirmación
        context.go('/'); 
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
      appBar: AppBar(title: const Text('NUEVO JUGADOR')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ÚNETE A LA COMPETENCIA',
                    style: AppTextStyles.headlineMedium,
                  ).animate().fadeIn(),
                  const SizedBox(height: 8),
                  Text(
                    'COMPLETA TU REGISTRO PARA EMPEZAR A JUGAR',
                    style: AppTextStyles.neonLabel,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 40),

                  // DISPLAY NAME
                  TextFormField(
                    controller: _displayNameController,
                    autofillHints: const [AutofillHints.name],
                    decoration: const InputDecoration(
                      labelText: 'NOMBRE PÚBLICO / JUGADOR',
                      prefixIcon: const HugeIcon(icon: HugeIcons.strokeRoundedUser, color: Colors.white, size: 20),
                      hintText: 'Ej: Jugador_01',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ).animate().slideX(begin: -0.1),
                  const SizedBox(height: 16),

                  // EMAIL
                  TextFormField(
                    controller: _emailController,
                    autofillHints: const [AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'EMAIL',
                      prefixIcon: const HugeIcon(icon: HugeIcons.strokeRoundedMail01, color: Colors.white, size: 20),
                    ),
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Email inválido' : null,
                  ).animate().slideX(begin: 0.1),
                  const SizedBox(height: 16),

                  // PASSWORD
                  TextFormField(
                    controller: _passwordController,
                    autofillHints: const [AutofillHints.newPassword],
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'PASSWORD',
                      prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedLock, color: Colors.white, size: 20),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        icon: HugeIcon(
                          icon: _obscurePassword
                              ? HugeIcons.strokeRoundedView
                              : HugeIcons.strokeRoundedViewOff,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                  ).animate().slideX(begin: -0.1),
                  const SizedBox(height: 32),

                  // BOTÓN
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('REGISTRARSE'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
