import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authUser.dart';
import 'localization.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'localizationDelegate.dart';
import 'package:permission/permission.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';

import 'database.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

void initState(){
   
     //clearPrefs();

  }
    clearPrefs() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
    
       print("prefs Cleared");
     
      
    }

  /*Widget: Locale/Idioma
    Descripción: Este widget es el encargado de cargar los datos para que sea possible una traducción/localización*/ 
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
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  /*Función: Inicializa las variables, carga los datos neccesarios y seguidamente redirecciona 
  hacia la pantalla de autentiación*/
   _update(String token) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token",token);
    prefs.setString("phone",'695745155');
    }
  @override
  initState(){
    _getPermission();
    firebaseMessaging.configure(
      onLaunch: (Map<String,dynamic> msg){
        print("onlaunch called");
      },
      onResume: (Map<String, dynamic> msg){
        print("onresume called");
      },
      onMessage: (Map<String, dynamic> msg){
        print(" onmessage called2");
      }
    );
     firebaseMessaging.getToken().then((token){
        _update(token);
      });
      _crash();
   

    


    Permission.openSettings;
    WidgetsBinding.instance
        .addPostFrameCallback((_) =>Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> LoginPage())) );
       
  }
  _getPermission()async {
    var permissions = await Permission.getPermissionsStatus([PermissionName.Internet, PermissionName.Location]);

    var permissionNames = await Permission.requestPermissions([PermissionName.Internet, PermissionName.Location]);  

    
  }
  _crash() async{
    bool isInDebugMode = false;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Crashlytics.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  await FlutterCrashlytics().initialize();

  runZoned<Future<Null>>(() async {
    runApp(MyApp());
  }, onError: (error, stackTrace) async {
    // Whenever an error occurs, call the `reportCrash` function. This will send
    // Dart errors to our dev console or Crashlytics depending on the environment.
    await FlutterCrashlytics().reportCrash(error, stackTrace, forceCrash: false);
  });
  }
 
    /*Widget: Carga
    Descripción: Este widget muestra un spinner de carga*/ 
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
        backgroundColor: Colors.purpleAccent,
      ),
    body:  new Center(child: CircularProgressIndicator(), )
  );
    
  }
}
