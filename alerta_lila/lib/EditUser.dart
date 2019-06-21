import 'dart:ui' as ui;

import 'package:alerta_lila/userProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'UserList.dart';
import 'database.dart';

void main() => runApp(EditUser());

class EditUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = "Creació d'una nova usuària";

    return new MaterialApp(
      home:
      Scaffold(
          body: MyCustomForm()
      ),
    );
    }
  }
// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _name = GlobalKey<FormState>();
  
  final _phone = GlobalKey<FormState>();

  TextEditingController phoneController = new TextEditingController();
  TextEditingController nameController = new TextEditingController(); 
  String userEmail = "";
  @override
  void initState() {
    // TODO: implement initState
    //super.initState();
    getEmail();
  }
   getEmail() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userEmail = prefs.getString("email");
      });
      
      
    }
Widget  _buildListItem(BuildContext context,DocumentSnapshot document){
  nameController.text = document['name'];
      phoneController.text = document['phone'];
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
      color:  Colors.white.withOpacity(0.9),
     
      ),)),
     
    
  new  Column(
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: new Text("Editar Usuària",style: new TextStyle(color: Colors.purple[300],fontSize: 20.0,fontWeight: FontWeight.w500),), 
        ),
      
         new Padding(
        padding: const EdgeInsets.all(8.0), 
        child:
        new Form(
              key: _name,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                      hintText: "Introdueix el nom"
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'El camp no pot estar buit.';
                      }
                      return null;
                    },
                  ),
                ],)
        ),
    ),
         
      new Padding(
        padding: const EdgeInsets.all(8.0), 
        child: 
         new Form(
              key: _phone,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                      hintText: "Introdueix el telèfon"
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'El camp no pot estar buit.';
                      }
                      return null;
                    },
                  ),
                ],)
        ),
        ),

    
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false
                // otherwise.
                if (!_name.currentState.validate()) {
                  // If the form is valid, display a Snackbar.
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processant les dades')));
                }
                 
                else  if (!_phone.currentState.validate()) {
                  // If the form is valid, display a Snackbar.
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processant les dades')));
                }
                else {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processant Credencials...')));
                    _signUp(phoneController.text,nameController.text,document.documentID);
                }
                

              },
              
              child: Text('Guardar',style: new TextStyle(color: Colors.white)),
              color: Colors.purple,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0), 
            child:  new Text("Nova Contrasenya",style: new TextStyle(color: Colors.purple[300],fontSize: 20.0,fontWeight: FontWeight.w500),),
            ),
       Padding(
            padding: const EdgeInsets.all(8.0),
            
            child:  new Text("En aquest apartat podràs canviar la contrasenya del teu compte. Quan premis el botó s'enviarà un correu, a l'e-mail ${document["email"]}, amb el qual podràs escollir una nova contrasenya."),
            ),
            Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: (){
                _passEmail(document['email']);
                Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Enviant e-mail...')));
              },
              
              child: Text('Cambiar Contrasenya',style: new TextStyle(color: Colors.white)),
              color: Colors.purple,
            ),
          ),
        ],
      ),
      ]
      );
    
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Incidència"),
          backgroundColor: Colors.purple[300],
        ),
        body: 
   StreamBuilder(stream:  Firestore.instance.collection('Usuarias').where("email",isEqualTo: userEmail).snapshots() ,
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
      if (!snapshot.hasData) return new Center(child: CircularProgressIndicator(), ) ;
        if(snapshot.data.documents.isNotEmpty){
            return  _buildListItem(context,snapshot.data.documents[0]);
          } else{
                return new Center(child: CircularProgressIndicator());                  
              }             
    }
    ),
    
  
    );
  }
  /*
  
   StreamBuilder(stream:  Firestore.instance.collection('Usuarias').where("email",isEqualTo: userEmail).snapshots() ,
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
      if (!snapshot.hasData) return new Center(child: CircularProgressIndicator(), ) ;
        if(snapshot.data.documents.isNotEmpty){
            return  _prueba(context,snapshot.data.documents[0]);
          } else{
                return new Center(child: CircularProgressIndicator());                  
              }             
    }
    ),
  
  
  
  
  */ 
  _signUp(String phone, String name,String uid) async{
    Database.updatetUser( uid, phone, name);
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> UserProfile()));
  }
  _passEmail(String email)async{
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}