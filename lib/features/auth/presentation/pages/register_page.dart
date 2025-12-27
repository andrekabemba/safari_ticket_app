import 'dart:io';

import 'package:achat_ticketbus/core/theme.dart';
import 'package:achat_ticketbus/core/widgets/gradient_scaffold.dart';
import 'package:achat_ticketbus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();
  final _confirmMotDePasseController = TextEditingController();
  final authRepo = AuthRepositoryImpl(Supabase.instance.client);
  bool isLoading = false;

  Future<void> register() async {
    if (_emailController.text.isEmpty || _motDePasseController.text.isEmpty) {
      _showError("Veuillez remplir tous les champs");
      return;
    }

    if (_motDePasseController.text != _confirmMotDePasseController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Les mot de passe ne correspondent pas')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _motDePasseController.text.trim(),
      );

      if (res.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie ! Connectez-vous.'),
            ),
          );
          Navigator.pop(context);
        }
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("Une erreur inattendue est survenue");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> updateUserSettings(String nom, String adresse) async {
    final user = Supabase.instance.client.auth.currentUser;

    await Supabase.instance.client
        .from('profils')
        .update({'nom': nom, 'adresse': adresse})
        .eq('id', user!.id);
  }

  Future<void> uploadAvatar(File imageFile) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final fileName = '$userId-avatar.png';

    await Supabase.instance.client.storage
        .from('avatars')
        .upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );

    final String publicUrl = Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(fileName);

    await Supabase.instance.client
        .from('profils')
        .update({'photo_url': publicUrl})
        .eq('id', userId);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SAFARI',
              style: GoogleFonts.monoton(
                fontSize: 32,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Veuillez créer votre Compte',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40),

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email, color: AppTheme.primaryPurple),
                hintText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: _motDePasseController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email, color: AppTheme.primaryPurple),
                hintText: 'Mot de Passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: _confirmMotDePasseController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email, color: AppTheme.primaryPurple),
                hintText: 'Confirmez le mot de passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : register,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'S\'Inscrire',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Déjà un Compte ? Connectez-vous',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
