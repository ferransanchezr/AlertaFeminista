import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:localstorage/localstorage.dart';
import 'database.dart';  
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'usuaria.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'userButton.dart';
import 'IncidenceActiveList.dart';
import 'IncidenceAdminList.dart';
import 'IncidenceList.dart';


void main() => runApp(new AdminUserProfile());
String _userData = "carregant dades";


class AdminUserProfile extends StatelessWidget {
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
 int _selectedIndex = 1;
  String _imageUrl = "";
  Usuaria profile = Usuaria("","","","");
   getUserId() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var uid = prefs.getString("user");
      return uid ;
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
  
  @override
  initState() {
    super.initState();
    getUserDbData();
    loadImage();
  }
   
  @override
  Widget build(BuildContext context) {
   
  
   
   
  final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    
    
    
    

    return new Stack(children: <Widget>[
      new Container(color: Colors.blue,),
      new Image.network( profile.imageUrl, fit: BoxFit.fill,),
      new BackdropFilter(
      filter: new ui.ImageFilter.blur(
      sigmaX: 6.0,
      sigmaY: 6.0,
      ),
      child: new Container(
      decoration: BoxDecoration(
      color:  Colors.blue.withOpacity(0.9),
      borderRadius: BorderRadius.all(Radius.circular(50.0)),
      ),)),
      new Scaffold(
          appBar: new AppBar(
            title: new Text(widget.title),
            centerTitle: false,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
          ),
          drawer: new Drawer(child: new Container(),),
          backgroundColor: Colors.transparent,
          body: new Center(
            child: new Column(
              children: <Widget>[
                new SizedBox(height: _height/12,),
                new CircleAvatar(radius:_width<_height? _width/4:_height/4,backgroundImage: NetworkImage(profile.imageUrl), ),
                new SizedBox(height: _height/25.0,),
                
                new Text(profile.email, style: new TextStyle(fontWeight: FontWeight.bold, fontSize: _width/15, color: Colors.white),),
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
                  BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('alerta')),
                  BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('School')),
                ],
                currentIndex: 2,
                fixedColor: Colors.deepPurple,
                onTap: _onItemTapped,
              ),
      )
    ],);
  }
void _onItemTapped(int index) {
  
    setState(() {
       _selectedIndex = index;
      switch(index){
        case 0: {
           Navigator.push(context,MaterialPageRoute(builder: (context) => AdminList()),);
        }
        break;
        case 1: {
          Navigator.push(context,MaterialPageRoute(builder: (context) => ActiveList()),);
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
