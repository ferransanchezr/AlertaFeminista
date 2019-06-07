import 'package:flutter/material.dart';
import 'chatScreen.dart';
import 'RealTimeLocation.dart';

void main() => runApp(chatPage());

class chatPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   
     return new Scaffold(
      
      appBar: new AppBar(
        title: new Text("Chat d'Emergencia"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: new ChatScreen()
      
    );


   
  }
}
scafoold(){
  return new Scaffold(
        
      appBar: new AppBar(
        title: new Text("Chat de Emergencia"),
      ),
      body: new ChatScreen()
      
    );
}
