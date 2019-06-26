import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoaduserButton.dart';


class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {

    TextEditingController emailController = new TextEditingController();
    TextEditingController passController = new TextEditingController();
    final FirebaseAuth auth = FirebaseAuth.instance;
    SharedPreferences prefs;
    String errorCode = "";
    bool loadAuth = false;
    final _email = GlobalKey<FormState>();
    final _pass = GlobalKey<FormState>();
    final  validCharacters = RegExp(r'^[a-zA-Z0-9@.]+$');
    final  validNumberCharacters = RegExp(r'^[0-9]+$');

    @override 
    initState() {
      _autoLogIn();
    }

/* Function: HandleSignIn
  Descripcion: inicio de session a través de firebase*/   
Future<FirebaseUser> _handleSignIn(String email, String password) async {
    final FirebaseUser currentUser = await auth.currentUser();
    FirebaseUser user ;
    
    if(currentUser!=null){
         user = currentUser;
    }else{
     user = await auth.signInWithEmailAndPassword(email: email, password: password).catchError((onError){
      
        setState(() {
         errorCode =  "Error e-mail o password no valids";
      
        });
     });
    }
    assert(user != null);
    assert(await user.getIdToken() != null);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("user",user.uid);
    prefs.setString("email",user.email);
    DocumentReference reference = Firestore.instance.collection('Usuarias').document(user.uid);
    reference.snapshots().listen((querySnapshot) {
       prefs.setString("userName", querySnapshot.data['name']);
       prefs.setString("phone", querySnapshot.data['phone']);
       prefs.setString("admin",querySnapshot.data['admin']);
       prefs.setString("emergencia",querySnapshot.data['modeEmergencia']);
    });
    var token = prefs.get("token");
    Database.updateToken(user.uid, token);
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> LoadUserButton()) );
    return user;
}

/*Nombre: _getPrefs()
  Función: Obtiene las preferencias guardadas en el dispositivo*/
_getPrefs()async{
  prefs = await SharedPreferences.getInstance(); 
}

/*Nombre: _autoLogin
  Función: si hay datos de usuario, automaticamente ejecuta el Log In*/ 
_autoLogIn() {
  _getPrefs().then((p){
  if(prefs.getString("user")!=null){ 
    _handleSignIn("", "");
    }else{
        setState(() {
          loadAuth = true;  
        });
    }
  });
}

 /*Widget: build()
  Descripción: Widget principal del la pantalla de inicio de sesión*/
  @override
  Widget build(BuildContext context) {
     SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    final email = 
    new Form(
    key: _email,
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
    TextFormField(
      
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      validator: (value) {

         if((value.isEmpty==true) || (value.length >=30) || (_emailValidator(value)==false)){
            return 'Introdueix un E-mail o Password valids';
          } 
          return null;
        
      },
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        
      ),
    ),]
    ),
    );


    final password =  
    new Form(
      key: _pass,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
        controller: passController,
        
        autofocus: false,
        validator: (value) {
      
          if((value.isEmpty) || (validCharacters.hasMatch(value)==false) || (value.length>=15)){
            return 'Introdueix un E-mail o Password valids';
          }
          return null;
      },
      obscureText: true,
      decoration: InputDecoration(
      hintText: 'Password',
      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)), 
      ),
      
        ),]
      ),
    );

    final errorLabel = Text(errorCode,style: TextStyle(fontWeight: FontWeight.bold,color:Colors.red),);
   
    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          if (!_email.currentState.validate()) {
              errorCode= 'Error al processar les dades';
          }
          else if (!_pass.currentState.validate()) {
              errorCode= 'Error al processar les dades';
          }
          else  {

            _handleSignIn(emailController.text,passController.text)
            .then((FirebaseUser user) => print(user))
            .catchError((e) => print(e));
          }  
         
        },
        padding: EdgeInsets.all(12),
        color: Colors.purple[300],
        child: Text('Accedir-hi', style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Has oblidat la Contrasenya?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {/*redirección hacia la pàgina web*/},
    );

    return Scaffold(
      
      backgroundColor: Colors.white,
      
      body: Center(
        child: _loginView(email, password, errorLabel, loginButton, forgotLabel)
      ),
    );
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

/*Nombre: _loginView
  Función: muestra un circulo da carga mientras ejecuta _handleSignIn()*/ 
_loginView(email, password, errorLabel,loginButton,forgotLabel){
  if (loadAuth == true){
        return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        children: <Widget>[                
                                  Image.asset(
              'resources/images/icon_auth.png', width: 350 ,height: 350,
            ),
          SizedBox(height: 48.0),
          email,
          SizedBox(height: 8.0),
          password,
          SizedBox(height: 24.0),
          errorLabel,
          loginButton,
          forgotLabel
        ],
      );
  }else{
      return  CircularProgressIndicator();
  }
}
}