import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'IncidenceActiveList.dart';
import 'localizationDelegate.dart';
import 'IncidenceList.dart';
import 'authUser.dart';
import 'Database.dart';
import 'RealTimeLocation.dart';
import 'userProfile.dart';
import 'userButton.dart';

void main() => runApp(LoadUserButton());


class LoadUserButton extends StatefulWidget {
  LoadUserButton({Key key}) : super(key: key);

  @override
  _Button createState() => _Button();
}

class _Button extends State<LoadUserButton> {
  int _selectedIndex = 1;
  String id = "";
 

  final _widgetOptions = [
    Text('Index 0: Home'),
     Text('Index 1: School'),
    Text('Index 2: School'),
  ];
   @override
  initState() {
    super.initState();
    getUserId();
    Database.getAdmin();
    
    _activeIncidence();
    
  }
 
  @override
  Widget build(BuildContext context) {
    
     
    return Scaffold(
      appBar: AppBar(
        title: Text('Botó Alerta'),
      ),
      body:  Center(
        child: CircularProgressIndicator(),
         
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.restore), title: Text('Home')),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active), title: Text('alerta')),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('School')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
  getUserId() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = "";
      uid = prefs.getString("user");
      return uid ;
  }
 

 Future<Null>  _activeIncidence() async{
   
     String uid = "";
     String state = "";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("state","false");
     Route route2 = MaterialPageRoute(builder: (context) => ActiveList());
     
    
       if(prefs.get("admin")=="true"){
         
              Navigator.pushReplacement(
          context,
          route2,
          );
          
       }
       else{
          
          
          await Database.getIncidenceOpen(uid).then((option) {
          Database.getIncidenceState();
          state = prefs.get("state");
          if(state == "true"){
            //check if incendenceID exists 
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> RealTimeLocation()));
          }else if (state == "false"){
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> UserButton()));//que vaya a una de carga standard
          }
          });
       }
             
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
          Navigator.push(context,MaterialPageRoute(builder: (context) => UserProfile()),);
        }
        break;
      }
      
    });
  }
   void _createIncident() async{
    String id = await getUserId();
    var now = new DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("incidence_data", now.toString());
    String fecha = DateFormat('dd-MM-yyyy - kk:mm').format(now);
    String name = await  Database.getUserData(id);

    Database.createIncidence(id, fecha, name);
    Navigator.push(context,MaterialPageRoute(builder: (context)=> RealTimeLocation()));


  }
}