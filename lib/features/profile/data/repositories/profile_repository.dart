import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getProfile() async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase.from('profils').select().eq('id', userId).single();
  }

  Future<void> updateProfile(String nom, String adresse) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('profils')
        .update({'nom': nom, 'adresse': adresse})
        .eq('id', userId);
  }

  Future<String> uploadAvatar(File imageFile) async {
    final userId = _supabase.auth.currentUser!.id;
    final path = 'public/$userId.png';

    await _supabase.storage
        .from('avatars')
        .upload(path, imageFile, fileOptions: const FileOptions(upsert: true));

    final String publicUrl = _supabase.storage
        .from('avatars')
        .getPublicUrl(path);

    await _supabase
        .from('profils')
        .update({'photo_url': publicUrl})
        .eq('id', userId);

    return publicUrl;
  }
}
