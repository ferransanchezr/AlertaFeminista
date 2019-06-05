import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'database.dart';
import 'userProfile.dart';
import 'RealTimeLocation.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'userButton.dart';
import 'IncidenceActiveList.dart';

class LoginPage2 extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();

}

class _LoginPageState extends State<LoginPage2> {
      TextEditingController emailController = new TextEditingController();
    TextEditingController passController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final FirebaseAuth auth = FirebaseAuth.instance;

    SharedPreferences prefs;
    Future<FirebaseUser> _handleSignIn(String email, String password) async {
    
    FirebaseUser user ;
  
     user = await auth.signInWithEmailAndPassword(email: email, password: password);
  

    

    print('signInEmail succeeded: $user');

    Database.createUser(user.email, user.uid);
    
   // print("signed in " + user.displayName);
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("user",user.uid);
   
    
     Route route = MaterialPageRoute(builder: (context) => UserButton());
     Route route2 = MaterialPageRoute(builder: (context) => ActiveList());
     Database.getAdmin();
     if(prefs.containsKey("admin")){
       if(prefs.get("admin")=="true"){
          if(!route.isCurrent){
              Navigator.pushReplacement(
          context,
          route2,
          );
          }
       }
       else{
          if(!route.isCurrent){
                    Navigator.pushReplacement(
                context,
                route,
                );
              }
       }
     } 
     
     
  
          
  return user;
}
     _getPrefs()async{
      prefs = await SharedPreferences.getInstance();
       
    }
     clearPrefs() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      final FirebaseAuth auth = FirebaseAuth.instance;
      auth.signOut() ;

       print("prefs Cleared");
     
      
    }
    
   
    clearPrefs();
    final email = TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
   
   
  
   
 
 
    final password = TextFormField(
      controller: passController,
      autofocus: false,
  
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        
      ),
    );

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
        color: Colors.lightBlueAccent,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
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
            loginButton,
            forgotLabel
          ],
        ),
      ),
    );
  }
}