import 'package:achat_ticketbus/core/theme.dart';
import 'package:achat_ticketbus/core/widgets/gradient_scaffold.dart';
import 'package:achat_ticketbus/features/reservation/presentation/pages/reservation_view.dart';
import 'package:achat_ticketbus/features/tickets/presentation/pages/tickets_view.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [ReservationView(), TicketsView()];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Billets',
          ),
        ],
      ),
    );
  }
}
