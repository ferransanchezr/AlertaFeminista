
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chatScreen.dart';

void main() => runApp(chatPage());

class chatPage extends StatefulWidget {
  @override
  _Chat createState() => _Chat();
}

class _Chat extends State<chatPage> {
  String incidenceId = "";
  String userId="";

  void initState(){
    _getIncidenceId();
    _getUserId();
  }


  /* Function: _getIncidenceId
  Descripcion: obtencion de la incidencia activa*/ 
  _getIncidenceId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
     incidenceId = prefs.get("incidenceId");
    });
  }

  /* Function: _getIncidenceId
  Descripcion: obtencion del Id*/ 
  _getUserId()async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
     userId = prefs.get("user");
    });
  }

  /* Widget: build
  Descripcion: creación appBar*/ 
  @override
  Widget build(BuildContext context) {
   
     return new Scaffold(
      appBar:  PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: // StreamBuilder
        StreamBuilder(
                stream: Firestore.instance.collection('Incidencias').where("unique_id",isEqualTo: incidenceId).snapshots() ,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){     
                    if (!snapshot.hasData) return new Center(child: CircularProgressIndicator(), ) ;
                     if(snapshot.data.documents.isNotEmpty){
                       if(snapshot.data.documents[0]['id']==userId){
                          return _buildAppBarAdmin(context,snapshot.data.documents[0]);
                       }else{
                         return _buildAppBar(context,snapshot.data.documents[0]);
                       }
                      } else{
                        return new Center(child: CircularProgressIndicator());                  
                    } 
                 }), 
      ),
      body: new ChatScreen()
    );
  }


  /* Function: _buildAppBarAdmin
  Descripcion: appBar con funcionalidades de admin*/ 
_buildAppBarAdmin(BuildContext context,DocumentSnapshot document){
  return  new AppBar(
    title: new Text("Xat d'emergència"),
    backgroundColor: Colors.purpleAccent,
    actions:  <Widget>[
      IconButton(icon:Icon(Icons.phone),color: Colors.white,iconSize: 30.0,
      onPressed:()=>launch("tel://"+ document['phone_admin'] )
      ),
    ]
  );
}
 /* Function: _buildAppBarAdmin
  Descripcion: appBar con funcionalidades de usuaria*/
_buildAppBar(BuildContext context,DocumentSnapshot document){
  return  new AppBar(
    title: new Text("Xat d'emergència"),
    backgroundColor: Colors.purpleAccent,
    actions:  <Widget>[
      IconButton(icon:Icon(Icons.phone),color: Colors.white,iconSize: 30.0,
      onPressed:()=>launch("tel://"+ document['phone'] )
      ),
    ]
  );
}

}
