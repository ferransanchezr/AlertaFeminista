import 'dart:ui' as ui;
import 'package:alerta_lila/userProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AdminUserProfile.dart';
import 'database.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

void main() => runApp(EditUser());

class EditUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  
    return new MaterialApp(
      home:
      Scaffold(
          body: MyCustomForm()
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

  final _name = GlobalKey<FormState>();
  final _phone = GlobalKey<FormState>();
  final  validCharacters = RegExp(r'^[a-zA-Z0-9@.]+$');
  final  validNumberCharacters = RegExp(r'^[0-9]+$');
  TextEditingController phoneController = new TextEditingController();
  TextEditingController nameController = new TextEditingController(); 
  String userEmail = "";

  @override
  void initState() {
    getEmail();
  }

/* Function: getEmail()
Descripcion: Obtiene el email guardado en las dispositivo */
  getEmail() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString("email");
    }); 
  }

/* Widget: _buildListItem()
Descripcion: Crea una lista que contiene el formulario para editar Usuarias */
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
      ),
      ),
      ),
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
                      if((value.isEmpty) || (!validCharacters.hasMatch(value)) || (value.length>=30)){
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
                      if((value.isEmpty) || (!validNumberCharacters.hasMatch(value)) || (value.length!=9)){
                        return 'El camp no pot estar buit.';
                      }
                      return null;
                    },
                  ),
                ],)
        ),
        ),
    new Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: RaisedButton(
          onPressed: () {
            if (!_name.currentState.validate()) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('Error al Processar les dades')));
            }
            else  if (!_phone.currentState.validate()) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('Error al Processar les dades')));
            }
            else {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('Processant Credencials...')));
                _updateData(phoneController.text,nameController.text,document.documentID,document.data['admin']);
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

 /* Function: build()
Descripcion: Widget principal amb la consulta a la bd*/
@override
Widget build(BuildContext context) {
  return Scaffold(
      appBar: GradientAppBar(
        title: Text("Creació d'una nova usuària"),
         gradient: LinearGradient(colors:[Colors.purple,Colors.purpleAccent]),
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

/* Function: _updateData()
Descripcion: Actualiza los datos de la usuaria*/
_updateData(String phone, String name,String uid,String admin) async{
  Database.updatetUser( uid, phone, name);
  if(admin == "true"){
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> AdminUserProfile()));
  }else{
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> UserProfile()));
  }
}

/* Function: _passEmail()
Descripcion: Envia un email,de l'usuaria, per cambiar la contrsenya*/
  _passEmail(String email) async{
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    await _firebaseAuth.sendPasswordResetEmail(email: email);
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