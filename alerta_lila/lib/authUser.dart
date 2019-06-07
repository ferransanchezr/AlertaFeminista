import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'database.dart';
import 'userProfile.dart';
import 'RealTimeLocation.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoaduserButton.dart';
import 'IncidenceActiveList.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {

    TextEditingController emailController = new TextEditingController();
    TextEditingController passController = new TextEditingController();
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final FirebaseAuth auth = FirebaseAuth.instance;
    SharedPreferences prefs;
    String errorCode = "";

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
    print('signInEmail succeeded: $user');
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("user",user.uid);
    prefs.setString("email",user.email);
    Database.createUser(user.email, user.uid,context);
    
    
    
    
     return user;
}
    _getPrefs()async{
      prefs = await SharedPreferences.getInstance(); 
    }
    //log In if User Exists
    _autoLogIn() {
      _getPrefs().then((p){
        
      if(prefs.getString("user")!=null){
        //existe un Usuario logged  
        _handleSignIn("", "");
        }
        });
   }
  @override
  Widget build(BuildContext context) {
     ///
  /// Force the layout to Portrait mode
  /// 
     SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    final email = TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      validator: (value) {
      if (value.isEmpty) {
      return 'Introdueix un E-mail o Password valids';
        }
      },
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        
      ),
    );
   
   
  
   
 
 
    final password = TextFormField(
      controller: passController,
      
      autofocus: false,
      validator: (value) {
      if (value.isEmpty) {
      return 'Introdueix un E-mail o Password valids';
        }
      },
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        
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
         
              _handleSignIn(emailController.text,passController.text)
          .then((FirebaseUser user) => print(user))
          .catchError((e) => print(e));
         
        },
        padding: EdgeInsets.all(12),
        color: Colors.purpleAccent,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
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
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            errorLabel,
            loginButton,
            forgotLabel
          ],
        ),
      ),
    );
  }
}