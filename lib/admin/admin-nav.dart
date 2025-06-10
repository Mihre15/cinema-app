import 'package:flutter/material.dart';
import 'admin_home.dart';
import 'admin_delete.dart';

void main() {
  runApp(MaterialApp(
    home: Nav(),
    debugShowCheckedModeBanner: false,
  ));
}

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
 _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {

int _selectedIndex=0;

static final List <Widget> _widgetOptions=<Widget>[
AddMoviePage(),
ManageMoviesPage(),
];

void _onItemTapped(int index){
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
     items:const <BottomNavigationBarItem> [
      BottomNavigationBarItem(
        icon: Icon(Icons.add,
        color: Color(0XffD59708),),
        label: 'Add'
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.delete,
        color:  Color(0XffD59708),),
        label: 'Delete'
        ),
      ]),
    );
  }
}