import 'package:achat_ticketbus/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TicketsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    return FutureBuilder(
      future: Supabase.instance.client
          .from('tickets')
          .select('*, trajets(*)')
          .eq('profil_id', userId)
          .order('date_achat', ascending: false),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator(color: Colors.white));

        if (!snapshot.hasData || (snapshot.data as List).isEmpty)
          return Center(
            child: Text(
              "Aucun billet trouvé",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          );

        final tickets = snapshot.data as List;

        return Column(
          children: [
            SizedBox(height: 20),
            Text(
              'SAFARI',
              style: GoogleFonts.monoton(
                fontSize: 40,
                color: Colors.white,
                letterSpacing: 5,
              ),
            ),
            Expanded(
              child: PageView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final trajet = ticket['trajets'];
                  return _buildTicketCard(ticket, trajet);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Swipez pour voir vos billets",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTicketCard(dynamic ticket, dynamic trajet) {
    final String qrData =
        "TICKET_ID: ${ticket['id']}\n"
        "PASSAGER: ${ticket['nom']}\n"
        "TRAJET: ${trajet['depart']} -> ${trajet['arrivee']}\n"
        "HEURE: ${trajet['heure_depart']}\n"
        "PRIX: ${trajet['prix']} \$";

    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _cityInfo(trajet['depart'], "Depart"),
                Icon(
                  Icons.arrow_forward,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                _cityInfo(trajet['arrivee'], "Arrivée"),
              ],
            ),
          ),
          Divider(color: AppTheme.primaryPurple.withOpacity(0.3), thickness: 1),
          _ticketDetail("Ticket N°", "000${ticket['id']}"),
          _ticketDetail("Passager", ticket['nom']),
          _ticketDetail("Heure de départ", trajet['heure_depart']),
          _ticketDetail("Total payé", "${trajet['prix']} \$"),

          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "VALIDE",
              style: GoogleFonts.poppins(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          Spacer(),
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 150.0,
            gapless: false,
            foregroundColor: AppTheme.primaryPurple,
          ),
          SizedBox(height: 10),
          Text(
            "Présentez ce code à l'embarquement",
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _cityInfo(String city, String label) {
    return Column(
      children: [
        Text(
          city,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryPurple,
          ),
        ),
        Text(label, style: GoogleFonts.poppins(color: Colors.grey)),
      ],
    );
  }

  Widget _ticketDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
