import 'dart:io';
import 'package:alerta_lila/EditUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'database.dart';  
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'userButton.dart';
import 'IncidenceList.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';


void main() => runApp(new UserProfile());
String _userData = "carregant dades";


class UserProfile extends StatelessWidget {
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
  
  File _image;
  String user = "";
  bool emergency;
  var userEmail = "";
  double _width = 50;
  double _height = 50;
  int _selectedIndex = 1;
  String _imageUrl = "";
  String email = "";
  String imageUrl = "";

/*Función: _getUserId()
Descripcion: Obtener el Id de Usuaria*/
   _getUserId() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var uid = prefs.getString("user");
      return uid ;
    }

/*Función: _getEmail()
Descripcion: Obtener el email guardado en las preferencias*/
_getEmail() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  userEmail = prefs.getString("email");
    if(prefs.getString("emergencia") == "true"){
      emergency = true;
    }else{
      emergency = false;
    }
}
  /*Función: _getUserDbData()
  Descripcion: Obtener datos de la base de datos*/
  Future _getUserDbData()  async {
    String user = await _getUserId();
    String email = await Database.getUserData(user); 
    setState(() {
      email = email; 
    });
   }

  /*Función: _getImage()
Descripcion: Obtener la url de la imagen de perfil */
Future _getImage() async {
String id = await _getUserId();
var image = await ImagePicker.pickImage(source: ImageSource.gallery);
_image = image;
Database.uploadImage(_image,id);
  imageUrl = await Database.downloadImage(id);

}

/*Función: _signOut()
Descripcion: Cerrar session de Usuario */
  _signOut() async{
    
     final FirebaseAuth auth = FirebaseAuth.instance;
     auth.signOut();
     SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.clear().then((onValue){
       Navigator.pop(context);
        
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => MyApp()),);
        
     });
  }

  @override
  initState() {
    super.initState();
    
    _getUserDbData();
    _getEmail();


  }

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
          appBar: new GradientAppBar(
            title: new Text(widget.title),
            centerTitle: false,
            elevation: 0.0,
            gradient: LinearGradient(colors:[Colors.purple,Colors.purpleAccent]),
            actions: <Widget>[
            // action button
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
                 
                child: new CircleAvatar(radius:_width<_height? _width/4:_height/4,backgroundImage: NetworkImage(document['profile_path']) 
               
                  ), ),
                new Positioned(
                  left: _width/3.0, 
                  top: _height/8.5,
                  child:
                    new FloatingActionButton(
                    heroTag: "1",
                  child: Icon(Icons.add_a_photo,color: Colors.white,),
                  backgroundColor: Color(0xff883997),
                  
                  onPressed: _getImage,
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
                new Text('Activa el Mode Emergència',style: TextStyle(color: Colors.white),),
              Transform.scale(
                scale: 1.25,
                child:
                  Switch(
                value: emergency,
                
                onChanged: (value) {
                  setState(() {
                    emergency = value;
                   Database.emergencySwitch(value,document.documentID);
                  
                  });
                },
                activeTrackColor: Color(0xffee98fb), 
                activeColor: Colors.purple[300],
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
                
                items: <BottomNavigationBarItem>[
                 BottomNavigationBarItem(icon: Icon(Icons.restore), title: Text('Historial')),
                  BottomNavigationBarItem(icon: Icon(Icons.notifications_active), title: Text('Alerta')),
                  BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Perfil')),
                ],
                currentIndex: 2,
                fixedColor: Color(0xff883997),
                onTap: _onItemTapped,
              ),
      )
    ],
   );
  }
   
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
  
  /*Función: _onItemTapper()
Descripcion: navegación del menu */
void _onItemTapped(int index) {
  _selectedIndex = index;
    setState(() {
      
      switch(index){
        case 0: {
           Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => List()),);
        }
        break;
        case 1: {
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => UserButton()),);
        }
        break;
        case 2: {
      
        }
        break;
         
      }
      
    });
  }
  
  Widget rowCell(int count, String type) => new Expanded(child: new Column(children: <Widget>[
    new Text('$count',style: new TextStyle(color: Colors.white),),
    new Text(type,style: new TextStyle(color: Colors.white, fontWeight: FontWeight.normal))
  ],));
}
