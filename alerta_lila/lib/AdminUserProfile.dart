import 'dart:io';
import 'package:alerta_lila/EditUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'IncidenceActiveList.dart';
import 'IncidenceAdminList.dart';
import 'UserList.dart';
import 'database.dart';  
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new AdminUserProfile());

class AdminUserProfile extends StatelessWidget {

  /*Widget: Perfil de la Administradora
  Descripción: Widget principal del perfil*/
  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      title: 'Perfil usuària',
      theme: new ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: new MyHomePage(title: 'Perfil usuària'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  File image;
  String user = "";
  String email = "";
  String imageUrl = "";
  int selectedIndex;
  bool emergency;
  var userEmail = "";

  /*Nombre: _getUserId()
  Función: Obtiene el id de la usuaria autenticada*/
  getUserId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString("user");
    return uid ;
  }

  /*Nombre: _getEmail()
  Función: Obtiene el email de la usuaria autenticada*/
  getEmail() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString("email");
    });
    
    if(prefs.getString("emergencia") == "true"){
      emergency = true;
    }else{
      emergency = false;
    }
  }
  

  /*Nombre: _signOut()
  Función: Cierra la session de la usuaria y redirigue hacia la pantalla de carga*/
  _signOut() async{
     final FirebaseAuth auth = FirebaseAuth.instance;
     auth.signOut();
     SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.clear().then((onValue){
      Navigator.pop(context);
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => MyApp()),);
     });
  }

  /*Nombre: _getImage()
  Función: Abre una ventana para seleccionar una foto de la galeria, y la sube al storage*/
  Future getImage() async {
    String id = await getUserId();
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    image = image;
    Database.uploadImage(image,id);
    imageUrl = await Database.downloadImage(id);  
  }

  @override
  initState() {
    super.initState();
    getEmail();
    
  }

  /*Nombre: _buildListItem()
  Función: UI, del perfil*/
  Widget _buildListItem(DocumentSnapshot document){
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    
    return new Stack(children: <Widget>[
      new Container(color: Color(0xffee98fb),),
      new Image.network( document['profile_path'], fit: BoxFit.fill,),
      new BackdropFilter(
      filter: new ui.ImageFilter.blur(
      sigmaX: 6.0,
      sigmaY: 6.0,
      ),
      child: new Container(
      decoration: BoxDecoration(
      color:  Colors.purple[300].withOpacity(0.9),
      ),)),
      new Scaffold(
          appBar: new AppBar(
            title: new Text(widget.title),
            centerTitle: false,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            actions: <Widget>[
            IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: () {
                _signOut();
              },
            ),
            ],
          ),
          backgroundColor: Colors.transparent,
          body: new Center(
            child: new Column(
              children: <Widget>[
                new SizedBox(height: _height/12,),
                new Stack(
                children: <Widget>[     
                new Container( 
                child: new CircleAvatar(radius:_width<_height? _width/4:_height/4,backgroundImage: NetworkImage(document['profile_path'])), 
                ),
                new Positioned(
                  left: _width/3.0, 
                  top: _height/8.5,
                  child:
                    new FloatingActionButton(
                    heroTag: "1",
                    child: Icon(Icons.add_a_photo,color: Colors.white,),
                    backgroundColor: Color(0xff883997),
                    onPressed: getImage,
                  ),
                ),
                ]
                ),
          
                new SizedBox(height: _height/25.0,),
                new Text(document['name'], style: new TextStyle(fontWeight: FontWeight.bold, fontSize: _width/15, color: Colors.white),),
                new Padding(padding: new EdgeInsets.only(top: _height/30, left: _width/8, right: _width/8),),
                new Padding(padding: new EdgeInsets.only(top: _height/500, left: _width/8, right: _width/8),),
                new Icon(Icons.phone,size: 30.0,color:Colors.white), 
                new Row(
                   mainAxisAlignment: MainAxisAlignment.center,   
                   children: <Widget>[
                       new  Text(" "+document['phone'], style: new TextStyle( fontSize: _width/15, color: Colors.white),)
                   ],
                 ),
               
              new Padding(padding: new EdgeInsets.only(top: _height/30, left: _width/8, right: _width/8),),
              new Text('Activa el Mode Usuària',style: TextStyle(color: Colors.white),),
              Transform.scale(
                scale: 1.25,
                child:
                  Switch(
                value: emergency,
                onChanged: (value) {
                },
                activeTrackColor: Colors.grey, 
                activeColor: Colors.grey[300],
              ),
              ),
              
              ],
            ),
          ),

        floatingActionButton: FloatingActionButton(
         heroTag: "2",
        backgroundColor: Color(0xff883997),
        onPressed: (){
          Navigator.push(this.context,MaterialPageRoute(builder: (context) => EditUser()),);
        },
        tooltip: 'Pick Image',
        child: Icon(Icons.edit),
         ),
         bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(icon: Icon(Icons.restore), title: Text('Historial')),
                  BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('Actives')),
                  BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Perfil')),
                  BottomNavigationBarItem(icon: Icon(Icons.people), title: Text('Usuaries')),
                ],
                currentIndex: 2,
                fixedColor: Color(0xff883997),
                onTap: _onItemTapped,
        ),
      )
    ],
   );
  }


  /*Nombre: _build
  Función: a partir de una query, crea  un widget con los datos necessarios del perfil*/
  @override
  Widget build(BuildContext context) {

    return StreamBuilder(stream:  Firestore.instance.collection('Usuarias').where("email",isEqualTo: userEmail).snapshots() ,
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
      if (!snapshot.hasData) return new Center(child: CircularProgressIndicator(), ) ;
        if(snapshot.data.documents.isNotEmpty){
                         return AnimatedOpacity(duration: Duration(seconds:1),
                              opacity: true ? 1.0 : 0.0,
                              child: _buildListItem(snapshot.data.documents[0]));
                    } else{
                        return new Center(child: CircularProgressIndicator());                  
                    }
    }
    );
  }

 
/*Nombre: _onItemTapped
Función: navegación de la botonera principal*/ 
void _onItemTapped(int index) {
    selectedIndex = index;
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
      
        }
        break;
         case 3: {
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => UserList()),);
        }
         
      }
      
    });
  }
}
