import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:async';

class Database{

 static Future<String> createIncidence() async {
  

    var incidencia = <String, dynamic>{
      'id': 'asSA2sd2438jfh',
      'name' : 'incidencia de prova 1',
      'created': '1/04/2019',
    };

    final DocumentReference reference = Firestore.instance.document("myApp/Incidencias") ;

    reference.setData(incidencia);

 }
  static Future<String> createMessage( String string) async {
  

    var mensaje = <String, dynamic>{
      'id': 'chat',
      'name' : 'Mensaje',
      'created': '1/04/2019',
      'value': string
    };
    var uuid = new Uuid();
     String id = uuid.v1();
    final DocumentReference reference = Firestore.instance.document("myApp/Incidencias/Mensajes/$id") ;

    reference.setData(mensaje);

 }
 static Future<String> createUser( String email,String uid) async {
  

    var user = <String, dynamic>{
      'name': 'usuaria',
      'email' : email
    };
    
    final DocumentReference reference = Firestore.instance.document("Usuarias/$uid") ;

    reference.setData(user);

 }
}