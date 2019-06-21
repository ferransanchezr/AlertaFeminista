import 'dart:ui' as prefix0;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'UserList.dart';
import 'database.dart';

void main() => runApp(CreateUser());

class CreateUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = "Creació d'una nova usuària";

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple[300],
          title: Text(appTitle),
        ),
        backgroundColor: Colors.purple[300],
        body: new Column( 
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children:<Widget>[

          
          new Card(
             elevation: 10.0,
            child: MyCustomForm(),
           ),
           
        ]
        ),
        
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
  final _email = GlobalKey<FormState>();
  final _phone = GlobalKey<FormState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController nameController = new TextEditingController(); 
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Column(children: <Widget>[
       new Text("Nova Usuària",style: new TextStyle(color: Colors.purple[300],fontSize: 20.0,fontWeight: FontWeight.w500),),
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
              
              key: _email,
              child: Column(
                
                
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                      hintText: "Introdueix l'e-mail"
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
                 else if (!_email.currentState.validate()) {
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
                    _signUp(emailController.text, '123456',phoneController.text,nameController.text);
                }
                

              },
              
              child: Text('Crear',style: new TextStyle(color: Colors.white)),
              color: Colors.purple,
            ),
          ),
        ],
      );
    
  }
  _signUp(String email, String password,String phone, String name) async{
    FirebaseAuth firebaseAuth =  FirebaseAuth.instance;
    FirebaseUser _newUser = await  firebaseAuth.createUserWithEmailAndPassword(email: email,password: password);
    Database.createFirstUser(email,_newUser.uid,phone,name);
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> UserList()));
    
    

  }
}