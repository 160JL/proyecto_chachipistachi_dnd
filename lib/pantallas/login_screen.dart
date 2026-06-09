import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_chachipistachi_dnd/l10n/app_localizations.dart';
import 'package:proyecto_chachipistachi_dnd/service/auth_service.dart';

/// Pantalla de acceso a la aplicación.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _keepLoggedIn = false; // Estado del tick "Mantener sesión"

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    
    if (email.isEmpty || pass.isEmpty) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      if (_isLogin) {
        await authService.signInWithEmail(email, pass);
      } else {
        await authService.signUpWithEmail(email, pass);
      }
      // Si el inicio de sesión tiene éxito, guardamos la persistencia
      await authService.setPersistence(_keepLoggedIn);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppLocalizations.of(context)!.loginError}: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = Provider.of<AuthService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? l10n.login : l10n.signUp),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_moon, size: 80, color: Colors.brown),
              const SizedBox(height: 40),
              
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),

              // Checkbox "Mantener sesión iniciada"
              Row(
                children: [
                  Checkbox(
                    value: _keepLoggedIn,
                    onChanged: (val) => setState(() => _keepLoggedIn = val ?? false),
                  ),
                  Text(l10n.keepLoggedIn, style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 20),
              
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isLogin ? l10n.signIn : l10n.signUp),
                  ),
                ),
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      try {
                        await authService.signInWithGoogle();
                        if (mounted) {
                          await authService.setPersistence(_keepLoggedIn);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${l10n.loginError}: $e")),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                    icon: const Icon(Icons.g_mobiledata, size: 30),
                    label: Text(l10n.signInWithGoogle),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Botón "Acceder como invitado"
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => authService.signInAsGuest(),
                    icon: const Icon(Icons.person_outline),
                    label: Text(l10n.signInAsGuest),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? l10n.noAccount : l10n.haveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
