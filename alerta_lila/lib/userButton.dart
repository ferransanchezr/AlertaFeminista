import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threading/threading.dart';
import 'IncidenceList.dart';
import 'Database.dart';
import 'RealTimeLocation.dart';
import 'userProfile.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

void main() => runApp(UserButton());


class UserButton extends StatefulWidget {
  UserButton({Key key}) : super(key: key);

  @override
  _Button createState() => _Button();
}

class _Button extends State<UserButton> {
  int _selectedIndex = 1;
  String id = "";
  Timer timer;
 
   @override
  initState() {
    super.initState();
    _getUserId();
   _activeIncidence();
     var thread = new Thread(() async{
        _startTimer();
    });
   thread.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text('Botó alerta'),
       gradient: LinearGradient(colors:[Colors.purple,Colors.purpleAccent]),
      ),
      body:  Center(
        child:new Container( 
              width: 200.0,
              height: 200.0,
              child: new FloatingActionButton( 
                backgroundColor: Colors.purple[300],
                child: Icon(Icons.add_alert,size:100.0),
                onPressed: _createIncident,
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
  
/*Función: _getUserId()
Descripcion: Obtiene el id de usuario*/  
  _getUserId() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = "";
      uid = prefs.getString("user");
      return uid ;
  }

/*Función: _getIncidenceId()
Descripcion: Obtiene el id de la incidencia*/
_getinidenceId() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.get("incidenceId");
}

 /*Función: _getState()
Descripcion: Obtiene el estado de la incidencia*/
_getState() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.get("state");
}

  /*Función: _startTimer()
Descripcion: Inicializa el Timer*/
_startTimer() async{
    if (timer!=null){
      timer.cancel();
    }
    const refreshTime = const Duration(seconds: 2);
    timer = new Timer.periodic(
      refreshTime,(timer){
        _activeIncidence();
        
      }
    );
  }

/*Función: _activeIncidence()
Descripcion: Comprueba si una incidencia esta activa*/
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
    }
   }
 }

 /*Función: _getEmergency()
Descripcion: Obterner el estado de la emergencia*/
_getEmergency() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String emergencia = "";
    emergencia = prefs.getString("emergencia");
    return emergencia ;
 }

/*Función: _onItemTapper()
Descripcion: navegación del menu */
void _onItemTapped(int index) {
  setState(() {
    switch(index){
      case 0: {
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => List()),);
      }
      break;
      case 1: {
      
      }
      break;
      case 2: {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => UserProfile()),);
      }
      break;
    }
    
  });
}
/*Función: _createIncident()
Descripcion: Crear una incidencia*/
  void _createIncident() async{
    String id = await _getUserId();
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