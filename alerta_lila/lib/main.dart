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
import 'package:gradient_app_bar/gradient_app_bar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

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
       // primarySwatch: Colors.purple,
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

  /*Nombre: _update()
  Función: Inicializa las variables, carga el token y el teléfono
  Parametros: el token del smartphone actual*/
   _update(String token) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token",token);
    prefs.setString("phone",'695745155');
    }

/*Nombre: _initState()
  Función: Inicializa las variables, carga el token y el teléfono
  Parametros: el token del smartphone actual*/
  @override
  initState(){

    
    _getPermission();

    
    /*Función: Lectura de notificaciones, con los tres estados posibles*/
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

  /*Nombre: _getPermission
  Función: Lanza una petición para pedir los permisos, no hace nada en el caso de que ya esten concedidos*/
  _getPermission()async {
    var permissions = await Permission.getPermissionsStatus([PermissionName.Internet, PermissionName.Location]);

    var permissionNames = await Permission.requestPermissions([PermissionName.Internet, PermissionName.Location]);  
    /*
    fetchCurrentLocation() async {
    await _locationService.changeSettings(
        accuracy: locationPackage.LocationAccuracy.HIGH, interval: 1000);

    locationPackage.LocationData location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      print("Service status: $serviceStatus");
      if (serviceStatus) {
        _permission = await _locationService.requestPermission();
        print("Permission: $_permission");
        if (_permission) {
          location = await _locationService.getLocation();

          print("Location: ${location.latitude}");
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        print("Service status activated after request: $serviceStatusResult");
        if (serviceStatusResult) {
          fetchCurrentLocation();
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        //error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        //error = e.message;
      }
      location = null;
    }
  }*/ 
  }

  /*Nombre: _crash()
    Función: En el caso de que haya un error en la notificación, lanza un error*/
  _crash() async{
    bool isInDebugMode = false;

    FlutterError.onError = (FlutterErrorDetails details) {
      if (isInDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      } else {
        Zone.current.handleUncaughtError(details.exception, details.stack);
      }
    };

    await FlutterCrashlytics().initialize();
    runZoned<Future<Null>>(() async {
      runApp(MyApp());
    }, onError: (error, stackTrace) async {
      await FlutterCrashlytics().reportCrash(error, stackTrace, forceCrash: false);
    });
  }
 
  /*Widget: Carga
  Descripción: Este widget muestra un spinner de carga*/ 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
        
        title: Text(DemoLocalizations.of(context).trans('title')),
        gradient: LinearGradient(colors:[Colors.purple,Colors.purpleAccent]),
        
      ),
    body:  new Center(child: CircularProgressIndicator(), )
  );
    
  }
}
