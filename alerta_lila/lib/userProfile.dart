import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:localstorage/localstorage.dart';
import 'database.dart';  
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'usuaria.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'userButton.dart';
import 'IncidenceList.dart';


void main() => runApp(new UserProfile());
String _userData = "carregant dades";


class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      title: 'Perfil usuària',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
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
  var userEmail = "";
 int _selectedIndex = 1;
  String _imageUrl = "";
  Usuaria profile = Usuaria("","","","");
   getUserId() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var uid = prefs.getString("user");
      return uid ;
    }
    getEmail() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userEmail = prefs.getString("email");
    }
     Future getUserDbData()  async {
      String user = await getUserId();
      String email = await Database.getUserData(user); 
      setState(() {
       profile.email = email; 
      });
     
   }
   Future loadImage() async {
    String user = await getUserId();
    String url =  await Database.downloadImage(user);

    setState((){
      profile.imageUrl = url;
     
   });
   }
   Future getImage() async {

    String id = await getUserId();
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

      _image = image;
      Database.uploadImage(_image,id);
      profile.imageUrl = await Database.downloadImage(id);
    
  }
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
    getUserDbData();
    getEmail();
    //loadImage();

  }
  Widget _buildListItem(BuildContext context,DocumentSnapshot document){
     final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
  return new Stack(children: <Widget>[
      new Container(color: Colors.blue,),
      new Image.network( document['profile_path'], fit: BoxFit.fill,),
      new BackdropFilter(
      filter: new ui.ImageFilter.blur(
      sigmaX: 6.0,
      sigmaY: 6.0,
      ),
      child: new Container(
      decoration: BoxDecoration(
      color:  Colors.purpleAccent.withOpacity(0.9),
      borderRadius: BorderRadius.all(Radius.circular(50.0)),
      ),)),
      new Scaffold(
          appBar: new AppBar(
            title: new Text(widget.title),
            centerTitle: false,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
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
                new CircleAvatar(radius:_width<_height? _width/4:_height/4,backgroundImage: NetworkImage(document['profile_path']), ),
                new SizedBox(height: _height/25.0,),
                
                new Text(document['name'], style: new TextStyle(fontWeight: FontWeight.bold, fontSize: _width/15, color: Colors.white),),
                new Padding(padding: new EdgeInsets.only(top: _height/30, left: _width/8, right: _width/8),
                  
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
         bottomNavigationBar: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(icon: Icon(Icons.restore), title: Text('Home')),
                  BottomNavigationBarItem(icon: Icon(Icons.notifications_active), title: Text('alerta')),
                  BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Perfil')),
                ],
                currentIndex: 2,
                fixedColor: Colors.deepPurple,
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
      if (!snapshot.hasData) return new Text('Loading...');
      return _buildListItem(context,snapshot.data.documents[0]);
      
                      
    }
    );
    
   
  }
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
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => UserProfile()),);
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
