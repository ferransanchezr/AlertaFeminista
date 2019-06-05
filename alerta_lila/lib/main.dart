import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authUser.dart';
import 'database.dart';
import 'localization.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'localizationDelegate.dart';
import 'IncidenceList.dart';
import 'RealTimeLocation.dart';
import 'chat.dart';
import 'userButton.dart';
import 'userProfile.dart';
import 'authUser.1.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

void initState(){
   
     //clearPrefs();

  }
    clearPrefs() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
    
       print("prefs Cleared");
     
      
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
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

      //Database.createIncidence();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(DemoLocalizations.of(context).trans('title')),
      ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications_active),
            tooltip: DemoLocalizations.of(context).trans('alert_button') ,
            onPressed: () {
              _createIncident();
            },
          ),
          RaisedButton(
            child: const Text('DEMO APP'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              // Perform some action
            },
          ),RaisedButton(
            child: const Text('Cerrar Sesion'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage2()),
                );
              // Perform some action
            },
          ),RaisedButton(
            child: const Text('Demo userButton'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserButton()),
                );
              // Perform some action
            },
          ),
          RaisedButton(
            child: const Text('Demo Location'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RealTimeLocation()),
                );
              // Perform some action
            },
          ),
               RaisedButton(
            child: const Text('Demo Chat'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => chatPage()),
                );
              // Perform some action
            },
          ),
          RaisedButton(
            child: const Text('Demo Profile'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfile()),
                );
              // Perform some action
            },
          ),
          Text(DemoLocalizations.of(context).trans('alert_button') )
        ],
      ),
    ),
  );
    
  }
}
