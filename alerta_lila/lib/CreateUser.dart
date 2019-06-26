import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'UserList.dart';
import 'database.dart';

void main() => runApp(CreateUser());

class CreateUser extends StatelessWidget {

  /* Widget: build
  Descripcion: app bar */ 
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

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}


class MyCustomFormState extends State<MyCustomForm> {

  final name = GlobalKey<FormState>();
  final email = GlobalKey<FormState>();
  final phone = GlobalKey<FormState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController nameController = new TextEditingController(); 
  final  validCharacters = RegExp(r'^[a-zA-Z0-9@.]+$');
  final  validNumberCharacters = RegExp(r'^[0-9]+$');
  

  @override
  Widget build(BuildContext context) {
    
    return Column(children: <Widget>[
       new Text("Nova Usuària",style: new TextStyle(color: Colors.purple[300],fontSize: 20.0,fontWeight: FontWeight.w500),),
       new Padding(
        padding: const EdgeInsets.all(8.0), 
        child:
        new Form(
              key: name,
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
          key: email,
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
                       if((value.isEmpty==true) || (value.length >=30) || (_emailValidator(value)==false)){
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
             key: phone,
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
                      if((value.isEmpty) || (validCharacters.hasMatch(value)==false) || (value.length>=15)){
                        return 'El camp no pot estar buit.';
                      }
                      return null;
                    },
                  ),
                ],)
        ),
        ),
        new  Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                if (!name.currentState.validate()) {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processant les dades')));
                }
                 else if (!email.currentState.validate()) {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processant les dades')));
                }
                else  if (!phone.currentState.validate()) {
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

/* Function: _signUp
  Descripcion: Crea el usuario en firebase*/
_signUp(String email, String password,String phone, String name) async{
   FirebaseAuth firebaseAuth =  FirebaseAuth.instance;
   FirebaseUser user = await  firebaseAuth.createUserWithEmailAndPassword(email: email,password: password);
   Database.createUserFromAdmin(email,user.uid,phone,name);
   Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> UserList()));
  }

/*Funcion: _emailValidator()
Descripción: devuelve true si el string pasado es un email*/
bool _emailValidator(String value){ 
  if (value.isEmpty == true){
    return false;
  } else{
    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    if(regExp.hasMatch(value)){
      return true;
    }
    else{
      return false;
    }
  }
}
}