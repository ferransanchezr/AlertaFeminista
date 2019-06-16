import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chatScreen.dart';
import 'RealTimeLocation.dart';

void main() => runApp(chatPage());

class chatPage extends StatefulWidget {
  // This widget is the root of your application.


  @override
  _Chat createState() => _Chat();
}

class _Chat extends State<chatPage> {
  String incidenceId = "";
  void initState(){
    _getIncidenceId();
  }
  _getIncidenceId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
     incidenceId = prefs.get("incidenceId");
    });
    
  }
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
                       return _buildAppBar(context,snapshot.data.documents[0]);

                    } else{
                        return new Center(child: CircularProgressIndicator());                  
                    } 
                    
                    
                                    
                    
                 }), 
      ),

      body: new ChatScreen()
      
    );


   
  }

scafoold(){
  return new Scaffold(
        
      appBar: new AppBar(
        title: new Text("Chat de Emergencia"),
      ),
      body: new ChatScreen()
      
    );
}
  _buildAppBar(BuildContext context,DocumentSnapshot document){
  return  new AppBar(
                        title: new Text("Chat d'Emergencia"),
                        backgroundColor: Colors.purpleAccent,
                        actions:  <Widget>[
                          IconButton(icon:Icon(Icons.phone),color: Colors.white,iconSize: 30.0,
                          onPressed:()=> launch("tel://" + document['phone'] )
                          ),
                        ]
                      );
  }

}
