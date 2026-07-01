import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_routes.dart';
import '../../widgets/buttons/luxury_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authRepo = ref.read(authRepositoryProvider);
    final loading = ref.read(authLoadingProvider.notifier);

    loading.state = true;
    try {
      if (isSignUp) {
        await authRepo.signUpWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully! Welcome.')),
          );
        }
      } else {
        await authRepo.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.authGate);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed: ${e.toString()}')),
        );
      }
    } finally {
      loading.state = false;
    }
  }

  Future<void> _signInWithGoogle() async {
    final authRepo = ref.read(authRepositoryProvider);
    final loading = ref.read(authLoadingProvider.notifier);

    loading.state = true;
    try {
      final cred = await authRepo.signInWithGoogle();
      if (cred != null && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.authGate);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In was cancelled.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In failed: ${e.toString()}')),
        );
      }
    } finally {
      loading.state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSignUp ? 'Create Workspace Account' : 'Welcome Back',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isSignUp
                            ? 'Register credentials for workspace access.'
                            : 'Continue to your curated operations workspace.',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Business Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                          icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      if (!isSignUp)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading ? null : () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                            child: const Text('Forgot password?'),
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          child: LuxuryButton(
                            label: isSignUp ? 'Register & Enter' : 'Enter Workspace',
                            icon: isSignUp ? Icons.person_add_alt_1_rounded : Icons.login_rounded,
                            onPressed: _submit,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: LuxuryButton(
                            label: 'Sign In with Google',
                            icon: Icons.g_mobiledata_rounded,
                            outlined: true,
                            onPressed: _signInWithGoogle,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() => isSignUp = !isSignUp),
                            child: Text(
                              isSignUp
                                  ? 'Already have an account? Sign In'
                                  : 'Need workspace credentials? Sign Up',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
