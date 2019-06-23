import 'dart:async';

import 'package:alerta_lila/userButtonEmergency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'IncidenceActiveList.dart';
import 'localizationDelegate.dart';
import 'IncidenceList.dart';
import 'authUser.dart';
import 'database.dart';
import 'RealTimeLocation.dart';
import 'userProfile.dart';
import 'userButton.dart';
import 'userButtonEmergency.dart';

void main() => runApp(LoadUserButton());


class LoadUserButton extends StatefulWidget {
  LoadUserButton({Key key}) : super(key: key);

  @override
  _Button createState() => _Button();
}

class _Button extends State<LoadUserButton> {
  int _selectedIndex = 1;
  String id = "";
  String admin = "";
  String emergency = "";
    StreamSubscription sub ;
 

  final _widgetOptions = [
    Text('Index 0: Home'),
     Text('Index 1: School'),
    Text('Index 2: School'),
  ];
   @override
  initState() {
    super.initState();
    getUserId();
   _syncState();  
  //  _activeIncidence();
    
  }
 _syncState() async {
   var id = await _getUserId();
    id = id.toString();
    var state = await _getState();
    state = state.toString();
   
 
    
    DocumentReference reference = Firestore.instance.collection('Usuarias').document(id);
    
    sub  =  reference.snapshots().listen((querySnapshot) {
      
        // Do something with change
        print("this was changed, " );
        if(querySnapshot.data['admin']==null){
          
        }else{
           admin = querySnapshot.data['admin'];
        }
       
        
       
        
        if(admin=="true"){
         _setAdmin(admin);
        _navigateActive(context);
       }
       else{
        
                _navigateButton(context);
                
              
            }//que vaya a una de carga standard
          
       
    });
}
_navigateButton(context){

  sub.cancel();
  Navigator.pushReplacement(this.context,MaterialPageRoute(builder: (context)=> UserButtonEmergency()));
}
_navigateActive(context){
  sub.cancel();
   Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> ActiveList()));
          
}
_setAdmin(String state)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("admin", state);
}

  @override
  Widget build(BuildContext context) {
    
     
    return Scaffold(
      
      body:  Center(
        child: CircularProgressIndicator(),
         
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.restore), title: Text('Historial')),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active), title: Text('Alerta')),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('School')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
  _getUserId() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = "";
      uid = prefs.getString("user");
      return uid ;
  }
 
 _getState() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = "";
      uid = prefs.getString("user");
      return uid ;
  }
  getUserId() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        id = prefs.getString("user");
        emergency = prefs.getString("emergencia");
      });
  }


 Future<Null>  _activeIncidence() async{
   
     String uid = "";
     String state = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("state","false");
    
     Route route2 = MaterialPageRoute(builder: (context) => ActiveList());
     
    
       if(admin=="true"){
         prefs.setString("admin",admin);
              Navigator.pushReplacement(
          context,
          route2,
          );
          
       }
       else{
          
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> UserButtonEmergency()));//que vaya a una de carga standard
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
   void _createIncident(id) async{
    
    var now = new DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("incidence_data", now.toString());
    String fecha = DateFormat('dd-MM-yyyy - kk:mm').format(now);
    String name = await  Database.getUserData(id);
    String phone = prefs.get("phone");
    Database.createIncidence(id, fecha, name,phone);
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> RealTimeLocation()));


  }
}