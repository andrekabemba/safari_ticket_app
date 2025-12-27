import 'package:achat_ticketbus/core/widgets/gradient_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> trajet;
  final String nomPassager;

  PaymentPage({required this.trajet, required this.nomPassager});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _supabase = Supabase.instance.client;
  final _phoneController = TextEditingController(text: "");
  bool _isProcessing = false;

  Future<void> _confirmPayment() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez entrer un numéro de compte/téléphone"),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final userId = _supabase.auth.currentUser!.id;

      await Future.delayed(Duration(seconds: 3));

      final ticket = await _supabase
          .from('tickets')
          .insert({
            'profil_id': userId,
            'trajet_id': widget.trajet['id'],
            'nom': widget.nomPassager,
          })
          .select()
          .single();

      await _supabase.from('paiements').insert({
        'ticket_id': ticket['id'],
        'montant': widget.trajet['prix'],
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la réservation : $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Text(
            'SAFARI',
            style: GoogleFonts.monoton(
              fontSize: 40,
              color: Colors.white,
              letterSpacing: 5,
            ),
          ),
          SizedBox(height: 40),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Mode de paiement',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Numéro",
                      style: GoogleFonts.poppins(color: Color(0xFF44388C)),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Color(0xFF44388C)),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Montant facturé: ",
                        style: GoogleFonts.poppins(fontSize: 18),
                      ),
                      Text(
                        "${widget.trajet['prix']} \$",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  if (_isProcessing)
                    CircularProgressIndicator(color: Color(0xFF44388C))
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF44388C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _confirmPayment,
                        child: Text(
                          "EFFECTUER PAIEMENT",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
