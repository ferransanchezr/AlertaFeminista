import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AdminUserProfile.dart';
import 'IncidenceAdminList.dart';
import 'RealTimeLocationAdmin.dart';
import 'UserList.dart';
import 'database.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'localizationDelegate.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

void main() => runApp(ActiveList());

class ActiveList extends StatelessWidget {

void initState(){

}

/* Widget: build()
Descripcion: Widget principal*/
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       supportedLocales: [  
        const Locale('es', 'ES'),  
        const Locale('en', 'US')  
            ],  
        localizationsDelegates: [  
              const DemoLocalizationsDelegate(),  
        GlobalMaterialLocalizations.delegate,  
        GlobalWidgetsLocalizations.delegate  
        ],  
        localeResolutionCallback: (Locale locale, Iterable<Locale> supportedLocales) {  
              for (Locale supportedLocale in supportedLocales) {  
                if (supportedLocale.languageCode == locale.languageCode || supportedLocale.countryCode == locale.countryCode) {  
                  return supportedLocale;  
        }  
              }  
        
              return supportedLocales.first;  
        },  
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title:'' ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  IncidenceList createState() => IncidenceList();
}

class IncidenceList extends State<MyHomePage> {
  var userName = "";
  @override   
  initState() {
    super.initState();
    _getIncidenceId();
  }

/* Function: _getIcidenceId()
Descripcion: obtener el id de la incidencia activa, guardado en el dispositivo*/
_getIncidenceId() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    userName = prefs.get("user");
  }); 

}
/* Function: build()
Descripcion: Widget principal amb la consulta a la bd*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          title: Text("Casos actius"),
         gradient: LinearGradient(colors:[Colors.purple,Colors.purpleAccent]),
        ),
        body:  StreamBuilder(
                stream: Firestore.instance.collection('Incidencias').where("open",isEqualTo: "true").snapshots() ,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData) return new Center(child: CircularProgressIndicator(), ) ;
                  return new ListView(
                    padding: EdgeInsets.all(8.0),
                    
                    children: snapshot.data.documents.map((DocumentSnapshot document) {
                      
                      return new 
                      Card(
                        color:Color(0xffee98fb),
                        
                        child:ListTile(
                        leading: new Icon(Icons.location_on,color:Color(0xff883997),size: 50,),
                        contentPadding: EdgeInsets.all(8.0),
                        title: new Text('Incidència'),        
                        subtitle: new Text(document['name'] + ' | ' + document['created']),
                        onLongPress: ()=>_assignIncidence(document['unique_id']),
                      ),
                      );
                      
                    }).toList(),
                  );
                },
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(icon: Icon(Icons.restore), title: Text('Historial')),
                  BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('Actives')),
                  BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Perfil')),
                  BottomNavigationBarItem(icon: Icon(Icons.people), title: Text('Usuaries')),
                ],
                currentIndex: 1,
                fixedColor: Color(0xff883997),
                onTap: _onItemTapped,
              ),
      );
  }
  
/* Function: _onItemTapped()
Descripcion: Menu de cambio de pantalla*/
void _onItemTapped(int index) {
  setState(() {
    switch(index){
      case 0: {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => AdminList()),);
      }
      break;
      case 1: {
        //do nothing
      }
      break;
      case 2: {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => AdminUserProfile()),);
      }
      break;
      case 3: {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => UserList()),);
      }
    }
  });
}

/* Function: _assignIncidence()
Descripcion: añade los datos de la administradora a la incidencia*/
  _assignIncidence(String unique_id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id_admin = prefs.get("user");
    double latitude_admin = 0.00;
    double longitude_admin = 0.00;
    var now = new DateTime.now();
    String fecha_admin = DateFormat('dd-MM-yyyy - kk:mm').format(now);
    String name_admin = prefs.get("userName");
    prefs.setString("incidenceId",unique_id);
    String phone = prefs.get("phone");
    Database.selectIncidence(id_admin, fecha_admin, latitude_admin.toString(), longitude_admin.toString(), name_admin, unique_id,phone);
    Navigator.push(context,MaterialPageRoute(builder: (context) => RealTimeLocationAdmin()),);
  }

}//end Class
