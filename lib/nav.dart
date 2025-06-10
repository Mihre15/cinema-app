import 'package:flutter/material.dart';
import 'package:pra/models/user_state.dart';
import 'Home.dart';
import 'booking.dart';
class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Navigation> {
  int _selectedIndex =0;
 static final  List<Widget> _widgetOptions=<Widget>[
    Home(),
    Text('booking'),
  ];
  void _onItemTapped( int index){
    setState(() {
      _selectedIndex=index;
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
        selectedItemColor: const Color(0XffD59708), // Highlight color
        unselectedItemColor: Colors.white70,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
            color: Color(0XffD59708),
            ),
            label: 'Home',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.video_collection,color: Color(0XffD59708)),
          //   label: 'Movies',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.video_library_rounded,color: Color(0XffD59708)),
          //   label: 'ET-Movies',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online,color: Color(0XffD59708)),
            label: 'Bookings',
          ),
        ],
      ),
    );
  }
}
