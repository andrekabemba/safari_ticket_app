import 'package:achat_ticketbus/features/tickets/presentation/pages/tickets_view.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'payment_page.dart';

class ReservationView extends StatefulWidget {
  @override
  State<ReservationView> createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {
  final _supabase = Supabase.instance.client;
  final _passagerController = TextEditingController();
  List<Map<String, dynamic>> _trajets = [];
  Map<String, dynamic>? _selectedTrajet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrajetsFromDb();
  }

  Future<void> _fetchTrajetsFromDb() async {
    try {
      final data = await _supabase.from('trajets').select();
      setState(() {
        _trajets = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur de chargement : $e");
    }
  }

  void _showProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfilePage()),
                  );
                },
                child: Text(
                  "PROFIL",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF25E7A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  await _supabase.auth.signOut();
                  Navigator.pop(context);
                },
                child: Text(
                  "DECONNEXION",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "ANNULER",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return Center(child: CircularProgressIndicator(color: Colors.white));

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20, left: 20),
          child: Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: _showProfileBottomSheet,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.9),
                child: Icon(Icons.person, size: 35, color: Color(0xFFF25E7A)),
              ),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'SAFARI',
            style: GoogleFonts.monoton(
              fontSize: 40,
              color: Colors.white,
              letterSpacing: 5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Reservation",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCityDropdown('', true),
                      Column(
                        children: [
                          Icon(Icons.directions_bus, color: Color(0xFF44388C)),
                          Text(
                            ".......",
                            style: GoogleFonts.poppins(
                              color: Color(0xFF44388C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      _buildCityDropdown('', false),
                    ],
                  ),
                  SizedBox(height: 30),
                  _buildOutlineField(Icons.calendar_month, "Date"),
                  SizedBox(height: 15),
                  _buildStaticInfo(
                    "Heure de départ",
                    _selectedTrajet?['heure_depart'] ?? "",
                  ),
                  _buildStaticInfo(
                    "Montant à payer",
                    "${_selectedTrajet?['prix'] ?? 0} \$",
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _passagerController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Color(0xFF44388C)),
                      hintText: "Nom du passager",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Color(0xFF44388C)),
                      ),
                    ),
                  ),
                  SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF44388C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      onPressed: () async {
                        if (_selectedTrajet != null &&
                            _passagerController.text.isNotEmpty) {
                          final success = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentPage(
                                trajet: _selectedTrajet!,
                                nomPassager: _passagerController.text,
                              ),
                            ),
                          );

                          if (success == true && mounted) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.bottomSlide,
                              headerAnimationLoop: false,
                              title: 'Succès !',
                              desc:
                                  'Votre réservation pour ${_selectedTrajet?['depart']} - ${_selectedTrajet?['arrivee']} a été confirmée.',
                              showCloseIcon: true,
                              titleTextStyle: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF44388C),
                              ),
                              descTextStyle: GoogleFonts.poppins(fontSize: 14),
                              btnOkText: "Voir mes billets",
                              btnOkColor: Color(0xFF44388C),
                              btnOkOnPress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TicketsView(),
                                  ),
                                );
                              },
                            ).show();

                            setState(() {
                              _passagerController.clear();
                              _selectedTrajet = null;
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Veuillez remplir tous les champs"),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "RESERVEZ",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown(String placeholder, bool isDepart) {
    return Column(
      children: [
        Container(
          width: 100,
          padding: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFF44388C)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, dynamic>>(
              isExpanded: true,
              value: _selectedTrajet,
              hint: Text(placeholder, style: GoogleFonts.poppins(fontSize: 12)),
              items: _trajets
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        isDepart ? t['depart'] : t['arrivee'],
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedTrajet = val),
            ),
          ),
        ),
        Text(
          isDepart ? "Depart" : "Arrivée",
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildOutlineField(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF44388C)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF44388C)),
          SizedBox(width: 10),
          Text(text, style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStaticInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text("$label : ", style: TextStyle(fontSize: 15)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
