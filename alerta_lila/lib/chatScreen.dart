import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'chatMessage.dart';
import 'database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:image/image.dart' as Image;

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
   String uniqueId;
   String name;
   String _imageUrl = "";
   File _image;
   String path_message = 'Incidencias/temp';
   ScrollController _scrollController = new ScrollController();
   _getPreferences() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      uniqueId = prefs.getString("incidenceId");
     
     setState(() {
       path_message = 'Incidencias/' + uniqueId + '/Mensajes';
     }); 
    }
    _getUserName() async{
  
    name = await Database.getUserData(uniqueId);
  }
  @override
  initState() {
    _getPreferences();
    
   
  }
  getUserId() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var uid = prefs.getString("user");
      return uid ;
    }
    Future getImage() async {

    String id = await getUserId();
    var image = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 200,maxHeight: 200);
    _image = image;
    Database.uploadChatImage(_image,id);
  }
  
  void _handleSubmit(String text) {
    if (_chatController.text.isNotEmpty){

      _chatController.clear();
        ChatMessage message = new ChatMessage(
          text: text
      );
      //Future.wait(_getUserName());
      
          Database.createMessage(text,name);
    
    
      setState(() {
        _messages.insert(0, message);
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent+10.0,            curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
            );
      });
    }
}

  Widget _chatEnvironment (){
    return IconTheme(
      data: new IconThemeData(color: Colors.purple[200]),
          child: new Container(
        margin: const EdgeInsets.symmetric(horizontal:8.0),
        child: new Row(
          children: <Widget>[
            IconButton(
              color: Color(0xff883997),
              onPressed: getImage,
              tooltip: 'Pick Image',
              icon: Icon(Icons.add_a_photo)
              
              ),
              new Container(margin:EdgeInsets.symmetric(vertical:8.0) ),
            new Flexible(
              child: new TextField(
                decoration: new InputDecoration.collapsed(hintText: "Escriu Aquí..."),
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
                stream: Firestore.instance.collection(path_message).orderBy('created').snapshots() ,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData) return new Text('No hi ha Missatges');
                  return new ListView(
                    controller: _scrollController,
                    children: snapshot.data.documents.map((DocumentSnapshot document) {
                      if(document['type'] == "image") {
                          return Stack(
                          
                          children: <Widget>[
                            Container(margin: new EdgeInsets.symmetric(vertical: 25.0,horizontal: 25.0),child: CircularProgressIndicator()),
                            Container(
                              margin: new EdgeInsets.symmetric(horizontal: 10.0),
                              child:Text(document['created'], style: TextStyle(color:Colors.grey),),
                            ),
                            
                            Card(
                              
                               margin: new EdgeInsets.symmetric(vertical: 20.0,horizontal: 10),
                              color:Color(0xffee98fb),
                              
                              child:
                              FadeInImage.memoryNetwork(
                                
                                placeholder: kTransparentImage,
                                image: document['path'],
                                width: 200.0,
                                height: 150.0,
                              ),
                            
                            ),
                            
                           
                          ],
                        );
                      }
                     else if(document['admin']== "true"){
                          return Container(color: Colors.purple[200],
                          child: ListTile(
                          leading: new Icon(Icons.pan_tool),
                          title: new Text(document['value']),
                          subtitle: new Text(document['name']),
                      ),
                       );
                      }else{
                      return Container(color: Colors.white,
                          child: ListTile(
                          leading: new Icon(Icons.person),
                          title: new Text(document['value']),
                          subtitle: new Text(document['name']),
                      ),
                       );
                      }
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