import 'package:achat_ticketbus/features/auth/data/models/trajet_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TicketRepository {
  final _supabase = Supabase.instance.client;

  Future<List<TicketModel>> getUserTickets() async {
    final userId = _supabase.auth.currentUser!.id;

    // Jointure avec la table trajets pour avoir les détails (départ, prix, etc.)
    final response = await _supabase
        .from('tickets')
        .select('*, trajets(*)')
        .eq('profil_id', userId)
        .order('date_achat', ascending: false);

    return (response as List).map((e) => TicketModel.fromJson(e)).toList();
  }
}
