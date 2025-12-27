import 'package:achat_ticketbus/features/auth/data/models/trajet_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationRepository {
  final _supabase = Supabase.instance.client;

  Future<List<TrajetModel>> getTrajets() async {
    final response = await _supabase.from('trajets').select();
    return (response as List).map((e) => TrajetModel.fromJson(e)).toList();
  }

  Future<void> effectuerReservation({
    required TrajetModel trajet,
    required String nomPassager,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    await Future.delayed(const Duration(seconds: 3));

    final ticketResponse = await _supabase
        .from('tickets')
        .insert({
          'profil_id': userId,
          'trajet_id': trajet.id,
          'nom': nomPassager,
        })
        .select()
        .single();

    await _supabase.from('paiements').insert({
      'ticket_id': ticketResponse['id'],
      'montant': trajet.prix,
    });
  }
}
