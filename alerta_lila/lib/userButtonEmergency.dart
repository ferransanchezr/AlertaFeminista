import 'dart:async';

import 'package:alerta_lila/userButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threading/threading.dart';
import 'localizationDelegate.dart';
import 'IncidenceList.dart';
import 'authUser.dart';
import 'Database.dart';
import 'RealTimeLocation.dart';
import 'userProfile.dart';

void main() => runApp(UserButtonEmergency());


class UserButtonEmergency extends StatefulWidget {
  UserButtonEmergency({Key key}) : super(key: key);

  @override
  _Button createState() => _Button();
}

class _Button extends State<UserButtonEmergency> {
  int _selectedIndex = 1;
  String id = "";
  Timer timer;
  bool activeButton = false;
  

  final _widgetOptions = [
    Text('Index 0: Home'),
     Text('Index 1: School'),
    Text('Index 2: School'),
  ];
   @override
  initState() {
    super.initState();
    getUserId();
   _activeEmergencia();

  
     var thread = new Thread(() async{
          startTimer();
    });
   thread.start();
    
  }
  

 
  @override
  Widget build(BuildContext context) {
    
     
    return Scaffold(
      appBar: AppBar(
        title: Text('Botó alerta'),
        backgroundColor: Colors.purple[300],
      ),
      body:  Center(
        child:new Container( 
              width: 200.0,
              height: 200.0,
              child: new FloatingActionButton( 
                backgroundColor: _buttonColor(),
                
                child: Icon(Icons.add_alert,size:100.0),
                

                onPressed: ()=> _createIncident("false"),
              ),
            ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.restore), title: Text('Historial')),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active), title: Text('Alerta')),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Perfil')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Color(0xff883997),
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
  _buttonColor(){
    if(activeButton==true){
      return Colors.purple[300];
    }else{
      return Colors.grey;
    }
    
  }
  
_getinidenceId() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.get("incidenceId");
}
_getState() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.get("state");
}

 
   //Empezar Contador
  startTimer() async{
      if (timer!=null){
        timer.cancel();
      }
      const refreshTime = const Duration(seconds: 2);
      timer = new Timer.periodic(
        refreshTime,(timer){
         _activeIncidence();
         setState(() {
           activeButton = true;
         });
         
          
        }
      );
  }
 Future<Null>  _activeIncidence() async{
   
     await Database.getIncidenceState();
     var id = await _getinidenceId();
     id = id.toString();
     var state = await _getState();
     state = state.toString();
     if(id!="null" && state!="null"){
      if(state=="true"){
        timer.cancel();
        var route = ModalRoute.of(context);

      if(route!=null){
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> RealTimeLocation()));
      }
      else{
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> UserButton()));
      }
      }
     }
 }
  _getEmergency() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String emergencia = "";
      emergencia = prefs.getString("emergencia");
      return emergencia ;
  }
 Future<Null>  _activeEmergencia() async{
       var emergency = await _getEmergency();
       var id = await getUserId();
       emergency = emergency.toString();
      if(emergency=="true"){
         Database.emergencySwitch(false,id);
        _createIncident("true");
      }
              
 }
  void _onItemTapped(int index) {
    
    setState(() {
      switch(index){
        case 0: {
           timer.cancel();
           Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => List()),);
        }
        break;
        case 1: {
        
        }
        break;
        case 2: {
          timer.cancel();
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => UserProfile()),);
        }
        break;
      }
      
    });
    
  }
   void _createIncident(String emergency) async{
   if((activeButton==true)||(emergency == "true")){
    String id = await getUserId();
    var now = new DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("incidence_data", now.toString());
    String fecha = DateFormat('dd-MM-yyyy - kk:mm').format(now);
    String name = await  Database.getUserData(id);
    String phone = prefs.get("phone");
    await Database.createIncidence(id, fecha, name,phone);
    timer.cancel();
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> RealTimeLocation()));
   }

  }
}