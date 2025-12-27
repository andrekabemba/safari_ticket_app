import 'dart:io';
import 'package:achat_ticketbus/core/theme.dart';
import 'package:achat_ticketbus/core/widgets/gradient_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _supabase = Supabase.instance.client;
  final _nomController = TextEditingController();
  final _adresseController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from('profils')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        _emailController.text = data['email'] ?? '';
        _nomController.text = data['nom'] ?? '';
        _adresseController.text = data['adresse'] ?? '';
        _photoUrl = data['photo_url'];
      });
    } catch (e) {
      _showSnackBar("Erreur de chargement : $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      await _supabase
          .from('profils')
          .update({
            'nom': _nomController.text.trim(),
            'adresse': _adresseController.text.trim(),
          })
          .eq('id', userId);

      _showSnackBar("Profil mis à jour !", Colors.green);
    } catch (e) {
      _showSnackBar("Erreur lors de la mise à jour", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      final file = File(image.path);
      final fileExtension = image.path.split('.').last;
      final path = '$userId/avatar.$fileExtension';

      await _supabase.storage
          .from('avatars')
          .upload(path, file, fileOptions: FileOptions(upsert: true));

      final String publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(path);

      await _supabase
          .from('profils')
          .update({'photo_url': publicUrl})
          .eq('id', userId);

      setState(() => _photoUrl = publicUrl);
      _showSnackBar("Photo de profil mise à jour !", Colors.green);
    } catch (e) {
      _showSnackBar("Erreur d'upload : $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          "Mon Profil",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white24,
                          backgroundImage: _photoUrl != null
                              ? NetworkImage(_photoUrl!)
                              : null,
                          child: _photoUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),

                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    style: GoogleFonts.poppins(color: Colors.white70),
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      labelStyle: GoogleFonts.poppins(color: Colors.white),
                      prefixIcon: Icon(
                        Icons.email,
                        color: AppTheme.primaryPurple,
                      ),
                      filled: true,
                      fillColor: Colors.white10,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _nomController,
                    decoration: InputDecoration(
                      labelText: "Nom complet",
                      labelStyle: GoogleFonts.poppins(color: Colors.white),
                      prefixIcon: Icon(
                        Icons.person,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _adresseController,
                    decoration: InputDecoration(
                      labelText: "Adresse",
                      labelStyle: GoogleFonts.poppins(color: Colors.white),
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "ENREGISTRER LES MODIFICATIONS",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
