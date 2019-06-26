import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final _email = GlobalKey<FormState>();
  final _pass = GlobalKey<FormState>();
  final _name = GlobalKey<FormState>();
  final _phone = GlobalKey<FormState>();
  final  validCharacters = RegExp(r'^[a-zA-Z0-9@.]+$');
  final  validNumberCharacters = RegExp(r'^[0-9]+$');
  String errorCode = "pass";

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

 testWidgets('Test de Validación de los formularios', (WidgetTester tester) async {

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Column(
            children: <Widget>[
              new Form(
                key: _email,
              child: 
               new TextFormField(
              autovalidate: true,
              validator: (String value) {
               errorCode = "pass";
                 if((value.isEmpty==true) || (value.length >=30) || (_emailValidator(value)==false)){
                   errorCode= "error";
                 }
              }
            ),
            ),
            new Form(
               key: _pass,
              child: 
            new TextFormField(
              autovalidate: true,
              validator: (String value) { 
                 if((value.isEmpty) || (validCharacters.hasMatch(value)==false) || (value.length>=15)){
                   errorCode= "error";
                 }
                 },
            ),
            ),
            new Form(
               key: _name,
              child: 
            new TextFormField(
              autovalidate: true,
              validator: (String value) { 
                errorCode = "pass";
                 if((value.isEmpty) || (!validCharacters.hasMatch(value)) || (value.length>=30)){
                   errorCode= "error";
                 }

                 },
            ),
            ),
               new Form(
               key: _phone,
              child: 
            new TextFormField(
              autovalidate: true,
              validator: (String value) { 
                 if((value.isEmpty) || (!validNumberCharacters.hasMatch(value)) || (value.length!=9)){
                   errorCode= "error";
                 }  
                 },
            ),
            ),
            ],
          ),
        ),
      ),
    );


    //Caso: email i password vacios
    await tester.showKeyboard(find.byKey(_email));
    await tester.showKeyboard(find.byKey(_pass));
    await tester.enterText(find.byKey(_pass), '');
    await tester.enterText(find.byKey(_email), '');
    await tester.pump();
    expect(errorCode,"error");

    //Caso: email i password númericos
    await tester.showKeyboard(find.byKey(_email));
    await tester.showKeyboard(find.byKey(_pass));
    await tester.enterText(find.byKey(_email), '12323');
    await tester.enterText(find.byKey(_pass), '1231');
    await tester.pump();
    expect(errorCode,"error");

    //Caso: email mal 
    await tester.showKeyboard(find.byKey(_email));
    await tester.showKeyboard(find.byKey(_pass));
    await tester.enterText(find.byKey(_email), 'usuaria');
    await tester.enterText(find.byKey(_pass), '1231');
    await tester.pump();
    expect(errorCode,"error");

    //Caso: email i password correctos 
    await tester.showKeyboard(find.byKey(_email));
    await tester.showKeyboard(find.byKey(_pass));
    await tester.enterText(find.byKey(_email), 'usuaria@admin.com');
    await tester.enterText(find.byKey(_pass), '1231');
    await tester.pump();
    expect(errorCode,"pass");

    //Caso: email i password injección de javascript
    await tester.showKeyboard(find.byKey(_email));
    await tester.showKeyboard(find.byKey(_pass));
    await tester.enterText(find.byKey(_email), "alert('ferry')");
    await tester.enterText(find.byKey(_pass), '123456');
    await tester.pump();
    expect(errorCode,"error");

    //Caso: email i password que sobre pasa el máximo de carácteres permitidos
    
    await tester.showKeyboard(find.byKey(_email));
    await tester.showKeyboard(find.byKey(_pass));
    await tester.enterText(find.byKey(_email), "012345678901234567890123456789");
    await tester.enterText(find.byKey(_pass), '012345678901234567890123456789');
    await tester.pump();
    expect(errorCode,"error");

    //Caso: email i password caracteres especiales
    
    await tester.showKeyboard(find.byKey(_email));
    await tester.showKeyboard(find.byKey(_pass));
    await tester.enterText(find.byKey(_email), "alert//¿]");
    await tester.enterText(find.byKey(_pass), '1*+?23456');
    await tester.pump();
    expect(errorCode,"error");
    
     //Caso: telefono y nombre vacios
    await tester.showKeyboard(find.byKey(_name));
    await tester.showKeyboard(find.byKey(_phone));
    await tester.enterText(find.byKey(_name), "");
    await tester.enterText(find.byKey(_phone), '');
    await tester.pump();
    expect(errorCode,"error");

    //Caso: telefono y nombre con mas caracteres de los permitidos 
    await tester.showKeyboard(find.byKey(_name));
    await tester.showKeyboard(find.byKey(_phone));
    await tester.enterText(find.byKey(_name), "01234567890123989182]");
    await tester.enterText(find.byKey(_phone), '01234567890123989182');
    await tester.pump();
    expect(errorCode,"error");

    //Caso: telefono y nombre correctos
    await tester.showKeyboard(find.byKey(_name));
    await tester.showKeyboard(find.byKey(_phone));
    await tester.enterText(find.byKey(_name), "Andrea");
    await tester.enterText(find.byKey(_phone), '678455188');
    await tester.pump();
    expect(errorCode,"pass");


  });
}


