
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'localizationDelegate.dart';
import 'AdminuserProfile.dart';
import 'IncidenceActiveList.dart';
import 'RealTimeLocationAdmin.dart';

void main() => runApp(AdminList());

class AdminList extends StatelessWidget {

void initState(){
   
      

  }
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title:'' ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

 
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  
  
  @override
  IncidenceActiveList createState() => IncidenceActiveList();
}

class IncidenceActiveList extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  void _createIncident(){

     // Database.createIncidence();
  }
int _selectedIndex = 1;
  @override
  Widget build(BuildContext context) {
     int _selectedIndex = 1;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          title: Text("Historial d'Incidencias"),
        ),
        body:  StreamBuilder(
                stream: Firestore.instance.collection('Incidencias').where("open",isEqualTo: "false").snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData) return new Text('Loading...');
                  return new ListView(
                    children: snapshot.data.documents.map((DocumentSnapshot document) {
                      
                        return new ListTile(
                        leading: new Icon(Icons.error),
                        title: new Text('Incidencia'),
                        subtitle: new Text(document['name'] + ' | ' + document['created']),
                        
                      );
                      
                      
                    }).toList(),
                  );
                },
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(icon: Icon(Icons.restore), title: Text('Historial')),
                  BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('Actives')),
                  BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Perfil')),
                ],
                currentIndex: 0,
                fixedColor: Colors.deepPurple,
                onTap: _onItemTapped,
              ),
        
      );
    
  }

    void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch(index){
         
        case 0: {
           
        }
        break;
        case 1: {
          Navigator.push(context,MaterialPageRoute(builder: (context) => ActiveList()),);
        }
        break;
        case 2: {
          Navigator.push(context,MaterialPageRoute(builder: (context) => AdminUserProfile()),);
        }
        break;
      }
      
    });
  }
  getUserId() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = "";
      uid = prefs.getString("user");
      return uid ;
  }
  _assignIncidence(String unique_id) async{
   SharedPreferences prefs = await SharedPreferences.getInstance();
    String id_admin = prefs.get("user");
    double latitude_admin = 0.00;
    double longitude_admin = 0.00;
    var now = new DateTime.now();
    String fecha_admin = DateFormat('dd-MM-yyyy - kk:mm').format(now);
    String name_admin = prefs.get("userName");
    Database.selectIncidence(id_admin, fecha_admin, latitude_admin.toString(), longitude_admin.toString(), name_admin, unique_id);
    Navigator.push(context,MaterialPageRoute(builder: (context) => RealTimeLocationAdmin()),);

  }
}
