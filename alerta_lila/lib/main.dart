import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authUser.dart';
import 'localization.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'localizationDelegate.dart';
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
        primarySwatch: Colors.blue,
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
  
  /*Función: Inicializa las variables, carga los datos neccesarios y seguidamente redirecciona 
  hacia la pantalla de autentiación*/
  @override
  initState(){
    WidgetsBinding.instance
        .addPostFrameCallback((_) =>Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> LoginPage())) );
       
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
    body: new Text("Carregant Dades")
  );
    
  }
}
