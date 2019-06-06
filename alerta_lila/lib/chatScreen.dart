import 'package:flutter/material.dart';
import 'chatMessage.dart';
import 'database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
   String uniqueId;
   String name;
   String path_message = 'Incidencias/temp';
   _getPreferences() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      uniqueId = prefs.getString("incidenceId");
      path_message = 'Incidencias/' + uniqueId + '/Mensajes';
    }
    _getUserName() async{
  
    name = await Database.getUserData(uniqueId);
  }
  @override
  initState() {
    _getPreferences();
   
  }
  
  
  void _handleSubmit(String text) {
    _chatController.clear();
      ChatMessage message = new ChatMessage(
        text: text
    );
    //Future.wait(_getUserName());

        Database.createMessage(text,name);
  
   
    setState(() {
       _messages.insert(0, message);
    });
}

  Widget _chatEnvironment (){
    return IconTheme(
      data: new IconThemeData(color: Colors.blue),
          child: new Container(
        margin: const EdgeInsets.symmetric(horizontal:8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                decoration: new InputDecoration.collapsed(hintText: "Start typing ..."),
                controller: _chatController,
                onSubmitted: _handleSubmit,
              ),
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                
                onPressed: ()=> _handleSubmit(_chatController.text),
                 
              ),
            )
          ],
        ),

      ),
    );
  }
 


  @override
  Widget build(BuildContext context) {
    
    
    return new Column(
        children: <Widget>[
          new Flexible(
            child: StreamBuilder(
                stream: Firestore.instance.collection(path_message).snapshots() ,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData) return new Text('No hi ha Missatges');
                  return new ListView(
                    children: snapshot.data.documents.map((DocumentSnapshot document) {
                      return new ListTile(
                        leading: new Icon(Icons.verified_user),
                        title: new Text('mensaje'),
                        subtitle: new Text(document['value']),
                      );
                    }).toList(),
                  );
                },
              ),
          ),
          new Divider(
            height: 1.0,
          ),
          new Container(decoration: new BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: _chatEnvironment(),)
        ],
      );
  }
}