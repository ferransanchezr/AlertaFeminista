import 'package:flutter/material.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'localizationDelegate.dart';
import 'IncidenceList.dart';
import 'authUser.dart';

void main() => runApp(UserButton());


class UserButton extends StatefulWidget {
  UserButton({Key key}) : super(key: key);

  @override
  _Button createState() => _Button();
}

class _Button extends State<UserButton> {
  int _selectedIndex = 1;
  final _widgetOptions = [
    Text('Index 0: Home'),
    Text('Index 1: Business'),
    Text('Index 2: School'),
  ];

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('BottomNavigationBar Sample'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.restore), title: Text('Home')),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active), title: Text('notifications_active')),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('School')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      switch(index){
        case 0: {
           Navigator.push(context,MaterialPageRoute(builder: (context) => List()),);
        }
        break;
        case 1: {
          Navigator.push(context,MaterialPageRoute(builder: (context) => UserButton()),);
        }
        break;
        case 2: {
          Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage()),);
        }
        break;
      }
      
    });
  }
}