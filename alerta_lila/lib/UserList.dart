import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AdminUserProfile.dart';

import 'CreateUser.dart';
import 'IncidenceActiveList.dart';
import 'IncidenceAdminList.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'localizationDelegate.dart';

void main() => runApp(UserList());

class UserList extends StatelessWidget {

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
    _getIncidenceId();
  }

 /*Función: _getIncidence()
Descripcion: Obtener el id de la incidencia*/
_getIncidenceId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.get("user");
    });   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:  FloatingActionButton(
        child: Icon(Icons.add),
        
        backgroundColor: Color(0xff883997),
        foregroundColor: Colors.white,
        onPressed: (){
          Navigator.push(this.context,MaterialPageRoute(builder: (context) => CreateUser()),);
        },
      ),
        appBar: AppBar(
          title: Text("Usuàries"),
          backgroundColor: Colors.purple[300],
        ),
        
        body:  StreamBuilder(
                stream: Firestore.instance.collection('Usuarias').snapshots() ,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData) return new CircularProgressIndicator( backgroundColor: Colors.purple[300]);
                  return new ListView(
                    padding: EdgeInsets.all(8.0),
                    
                    children: snapshot.data.documents.map((DocumentSnapshot document) {
                      
                      return new 
                      Card(
                        color:Colors.white,
                        
                        child:ListTile(
                        leading: new Container(
                           width: 45.0,
                          height: 45.0,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(
                                      document['profile_path'])
                              )
                          ),
                          
                      
                        ),
                        contentPadding: EdgeInsets.all(8.0),
                        title: new Text(document['name']),        
                        subtitle: new Text(document['email'] + " | "+ document['phone']),
                        
                      ),
                      );
                      
                    }).toList(),
                  );
                },
              ),
              bottomNavigationBar: BottomNavigationBar(
               type: BottomNavigationBarType.fixed,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(icon: Icon(Icons.restore), title: Text('Historial') ),
                  BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('Actives')),
                  BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Perfil')),
                  BottomNavigationBarItem(icon: Icon(Icons.people), title: Text('Usuàries'))
                ],
                currentIndex: 3,
                fixedColor: Color(0xff883997),
                onTap: _onItemTapped,
              ),
              
        
      );
    
  }
/*Función: _onItemTapper()
Descripcion: navegación del menu */
    void _onItemTapped(int index) {
  setState(() {
    switch(index){
      case 0: {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => AdminList()),);
      }
      break;
      case 1: {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => ActiveList()),);
      }
      break;
      case 2: {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => AdminUserProfile()),);
      }
      break;
      case 2: {
        
      }
      break;
    }
    
  });
  }
}
