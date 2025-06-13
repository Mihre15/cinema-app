// Navigation.dart
import 'package:flutter/material.dart';
import 'Home.dart';
import 'booking.dart';
import 'bookedPage.dart';

class Navigation extends StatefulWidget {
  // final int? userID;
  const Navigation({super.key,});

  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Navigation> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // print('Navigation intialiazed with userId: ${widget.userID}');
    _widgetOptions = <Widget>[
      Home(),  
      BookedPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0XffD59708),
        unselectedItemColor: Colors.white70,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Color(0XffD59708)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online, color: Color(0XffD59708)),
            label: 'Bookings',
          ),
        ],
      ),
    );
  }
}