import 'dart:async';
import 'package:alerta_lila/userButtonEmergency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'IncidenceActiveList.dart';
import 'IncidenceList.dart';
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
    _screenId();
   _syncState();  
  }

  /* Function: _syncState()
Descripcion: Cuando hay un cambio en cualquier usuario de la base de datos...*/
 _syncState() async {
  var id = await _getUserId();
  id = id.toString(); 
  DocumentReference reference = Firestore.instance.collection('Usuarias').document(id);  
  sub  =  reference.snapshots().listen((querySnapshot) {
        print("this was changed, " );
        if(querySnapshot.data['admin']==null){
          //do something
        }else{
           admin = querySnapshot.data['admin'];
        }
        if(admin=="true"){
          _setAdmin(admin);
          _navigateActive(context);
       }
       else{
            _navigateButton(context);  
       }
    });
}

/* Function: _navigateButton()
Descripcion: Va a la pantalla de emergencia*/
_navigateButton(context){
  sub.cancel();
  Navigator.pushReplacement(this.context,MaterialPageRoute(builder: (context)=> UserButtonEmergency()));
}

/* Function: _navigateActive()
Descripcion: Va a la pantalla de administracion*/
_navigateActive(context){
  sub.cancel();
   Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> ActiveList()));      
}

/* Function: _setAdmin()
Descripcion: si es admin lo guarda en el dispositivo*/
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

/* Function: _getUserId()
Descripcion: Obtiene el user Id del dispositivo*/
  _getUserId() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = "";
      uid = prefs.getString("user");
      return uid ;
  }

/* Function: _screenId()
Descripcion: Actualiza la pantalla con el nuevo id y el estado de emergencia*/
_screenId() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        id = prefs.getString("user");
        emergency = prefs.getString("emergencia");
      });
  }

/* Function: _onItemTapped()
Descripcion: Menu de cambio de pantalla*/
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
}//end class