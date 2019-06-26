import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';


class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = new TextEditingController();
   String uniqueId;
   String name;
   String userName;
   String _imageUrl = "";
   File _image;
   String path_message = 'Incidencias/temp';
   ScrollController _scrollController = new ScrollController();

   /* Function: _getPreferences
  Descripcion: obtencion de preferencias almacenadas en el dispositvo*/ 
   _getPreferences() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      uniqueId = prefs.getString("incidenceId");
      userName = prefs.getString("userName");
     
     setState(() {
       path_message = 'Incidencias/' + uniqueId + '/Mensajes';
     }); 
    }

  @override
  initState() {
    _getPreferences();
  }

   /* Function: _getUserId
  Descripcion: obtencion del Id*/ 
  getUserId() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var uid = prefs.getString("user");
      return uid ;
  }
   /* Function: _getImage
  Descripcion: obtención de la imagen del dispositivo y subida a la base de datos*/ 
  Future getImage() async {
    String id = await getUserId();
    var image = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 200,maxHeight: 200);
    _image = image;
    Database.uploadChatImage(_image,id);
  }
   /* Function: _isMePadding
  Descripcion: en funcion de si es emisor  o receptor del mensaje lo ordena en pantalla*/ 
   _isMePadding(name){
     if(name == userName){
       return EdgeInsets.only(top:15.0,bottom:15.0,left:50.0,right:5.0);
     }
     else{
        return EdgeInsets.only(top:15.0,bottom:15.0,left:5.0,right:50);
     }
   }
  /* Function: _isMePadding
  Descripcion: en funcion de si es emisor o receptor del mensaje cambia la forma,
  de la burbuja*/ 
  _isMeRadius(name){
     if(name == userName){
        return BorderRadius.only(
        topLeft: Radius.circular(15.0),
        bottomLeft: Radius.circular(15.0),
        bottomRight: Radius.circular(15.0),
        );
      }
      else{
          return BorderRadius.only(
          topRight: Radius.circular(15.0),
          bottomLeft: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        );
      }
  }

  /* Function: _handleSubmit
  Descripcion: cuando no esta vació guarda el mensaje en la base de datos*/ 
  void _handleSubmit(String text) {
    if (_chatController.text.isNotEmpty){
      Database.createMessage(text,name);
      setState(() {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent+10.0,            curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
            );
      });
    }
}

Widget _chatEnvironment(){
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
 

/* Widget: build
  Descripcion: creación entorno de chat*/ 
  @override
  Widget build(BuildContext context) {
    return new Column(
        children: <Widget>[
          new Flexible(
            child: StreamBuilder(
                stream: Firestore.instance.collection(path_message).orderBy('created').snapshots() ,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData) return new CircularProgressIndicator();
                  return new ListView(
                    controller: _scrollController,
                    children: snapshot.data.documents.map((DocumentSnapshot document) {
                      if(document['type'] == "image") {
                         return Padding(padding: _isMePadding(document['name']),
                            child:
                         Stack(
                          children: <Widget>[
                            Container(
                              child:Text(document['created'], style: TextStyle(color:Colors.grey),),
                            ),
                            Card(
                              margin: new EdgeInsets.symmetric(vertical: 20.0),
                              color:Colors.purple[300],
                              shape: RoundedRectangleBorder(borderRadius: _isMeRadius(document['name'])),
                              child:
                              FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: document['path'],
                                width: 150,
                                height: 150,
                              ),
                            ),
                          ],
                        ),
                        ); 
                      }
                     else if(document['admin']== "true"){
                          return 
                          Padding(padding: _isMePadding(document['name']),
                          child: 
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                          new Container(
                          decoration : BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: .5,
                                              spreadRadius: 1.0,
                                              color: Colors.black.withOpacity(.12))
                                        ],
                                        color: Colors.purple[200], 
                                        borderRadius: _isMeRadius(document['name']),
                                      ),
                          child: ListTile(
                          leading: new Icon(Icons.pan_tool),
                          title: new Text(document['value']),
                          subtitle: new Text(document['name']),
                      ),
                       ),
                       ],),
                       );
                      }else{
                        return 
                          Padding(padding:_isMePadding(document['name']),
                          child: 
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                          new Container(
                          decoration : BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: .5,
                                              spreadRadius: 1.0,
                                              color: Colors.black.withOpacity(.12))
                                        ],
                                        color: Colors.grey[100], 
                                        borderRadius: _isMeRadius(document['name']),
                                      ),
                          child: ListTile(
                          leading: new Icon(Icons.person),
                          title: new Text(document['value']),
                          subtitle: new Text(document['name']),
                          ),
                       ),
                       ],),
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