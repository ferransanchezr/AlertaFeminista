import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

import 'LoaduserButton.dart';

class Database {

  static getIncidenceState() async {
       SharedPreferences prefs = await SharedPreferences.getInstance();
        String uniqueId = prefs.getString("incidenceId");
    Firestore _firestore = Firestore.instance;
      String open = 'false';
      Firestore.instance
    .collection('Incidencias')
    .where("open", isEqualTo: "true")
    .where("unique_id",isEqualTo: uniqueId)
    .snapshots()
    .listen((data) =>
        data.documents.forEach((doc) => 
        prefs.setString("state", doc['open'])));
}
       
       


//Estos metodos tienen que servir para subir imagenes en general
// ahora solo suben las imagenes del perfil
static void uploadImage(File img, String uid) async {
  StorageReference reference = FirebaseStorage.instance.ref().child('$uid/profile');
  StorageUploadTask uploadTask = reference.putFile(img);
  StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  
}
static Future<String> downloadImage(String uid) async {
  var reference =( await FirebaseStorage.instance.ref().child('$uid/profile').getDownloadURL());
  String downloadUrl = reference.toString();
  return downloadUrl;
}

 static  createIncidence(String uid,String fecha ,String name) async {

   
    SharedPreferences prefs = await SharedPreferences.getInstance();
   
    //si la incidencia ya existe no creas otra
   // if(prefs.getString("incidenceId")==null){
      Uuid id = new Uuid();
      String uniqueId = id.v1();
      prefs.setString("incidenceId", uniqueId);
    
    
    
    var incidencia = <String, dynamic>{
      'id' : uid,
      'longitude' : "0.00",
      'latitude': "0.00",
      'name' : name,
      'created': fecha,
      'open': 'true',
       'id_admin' : '',
      'longitude_admin' : '',
      'latitude_admin': '',
      'name_admin' : '',
      'created_admin': '',
      'unique_id': uniqueId

      
    };

    final DocumentReference reference = Firestore.instance.document('Incidencias/$uniqueId') ;

    reference.setData(incidencia);
    }
 //}
 static Future<String> selectIncidence(String uid_admin,String fecha_admin,String latitude_admin,String longitude_admin,String name_admin,String unique_id) async {
    
    String uniqueId = unique_id;
    var incidencia = <String, dynamic>{
      'id_admin' : uid_admin,
      'longitude_admin' : longitude_admin,
      'latitude_admin': latitude_admin,
      'name_admin' : name_admin,
      'created_admin': fecha_admin,
      
    };

    final DocumentReference reference = Firestore.instance.document('Incidencias/$uniqueId') ;

    reference.updateData(incidencia);

 }
 //Crea un Mensaje dentro de la incidencia
  static createMessage( String string,String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uniqueId = prefs.getString("incidenceId");
    String nombre = prefs.getString("userName");
    String admin = prefs.getString("admin");
     var now = new DateTime.now();
    var mensaje = <String, dynamic>{
      'id': 'chat',
      'name' : nombre,
      'created': now.toString(),
      'value': string,
      'admin': admin
    };

    Uuid id = new Uuid();
    String uid = id.v1();
    var reference = Firestore.instance.collection('Incidencias').document('$uniqueId').collection('Mensajes').document('$uid') ;
    reference.setData(mensaje);
 }


 static createUser( String email,String uid, context) {
   bool create = true;
    final DocumentReference reference = Firestore.instance.document("Usuarias/$uid") ;
     reference.snapshots().listen((datasnapshot){
      if(datasnapshot.exists){
        create = false;
      }
      else{
        List<String> name = email.split('@');
        var user = <String, dynamic>{
          'name': name[0],
          'email' : email,
          'admin' : 'false',
          'latitude' : '0.00',
          'longitude': '0.00'
        };
        
       
        if(create){
          reference.setData(user);
          
        }
        
      }
      
    });
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> LoadUserButton()));
     }
        
     static Future<String> setOpen( String open ,String uid) async {
    
        
        var user = <String, dynamic>{
         'open' : open,
          
        };
        
        final DocumentReference reference = Firestore.instance.document('Incidencias/$open') ;
    
        reference.updateData(user);
      
     }
     //set Location at Users Profile
     static Future<String> setLocation( double lat, double long,String uid) async {
    
        var latitude = lat.toString();
        var longitude = long.toString();
        var user = <String, dynamic>{
         'latitude' : latitude,
          'longitude': longitude
        };
        final DocumentReference reference = Firestore.instance.document("Usuarias/$uid") ;
        reference.updateData(user);
     }
       //set Admin Location at Incidence 
     static  setIncidenceLocationAdmin( double lat, double long,String uid) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String uniqueId = prefs.getString("incidenceId");
        var latitude = lat.toString();
        var longitude = long.toString();
        var user = <String, dynamic>{
         'latitude_admin' : latitude,
          'longitude_admin': longitude
        };
        final DocumentReference reference = Firestore.instance.document("Incidencias/$uniqueId") ;
        reference.updateData(user);
     }
         //set Location at Incidence
     static  setIncidenceLocation( double lat, double long,String uid) async {
    
        var latitude = lat.toString();
        var longitude = long.toString();
        var user = <String, dynamic>{
         'latitude' : latitude,
          'longitude': longitude
        };
        final DocumentReference reference = Firestore.instance.document("Incidencias/$uid") ;
        reference.updateData(user);
     }
    static Future<String> getUserData( String uid) async {
      
     SharedPreferences prefs = await SharedPreferences.getInstance();
      String user = 'carregant dades';
     
         var reference =  Firestore.instance.collection('Usuarias').document(uid);
          await reference.get().then((DocumentSnapshot ds) {
           
            user =  ds['name'].toString();
            
       });
       prefs.setString("userName",user);
        return user;   
     }
     //Conseguir el nombre de el admin a partir de una incidencia
     static Future<String> getAdminName( String uid) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uniqueId = prefs.getString("incidenceId");
      String user = 'carregant dades';
      var reference = Firestore.instance.collection('Incidencias').document(uniqueId);
      await reference.get().then((DocumentSnapshot ds) {
            user =  ds['name_admin'].toString();      
       });
      prefs.setString("adminName", user);  
     }
     //Conseguir el nombre de usuario a partir de una incidencia
     static Future<String> getUserName( String uid) async {
       SharedPreferences prefs = await SharedPreferences.getInstance();
        String uniqueId = prefs.getString("incidenceId");
    
      String user = 'carregant dades';
     
         var reference =  Firestore.instance.collection('Incidencias').document(uniqueId);
          await reference.get().then((DocumentSnapshot ds) {
           
            user =  ds['name'].toString();
            
       });
        prefs.setString("UserName", user);
        return user;   

     }

      static  getAdmin() async  {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.get("user");
       String user = 'carregant dades';
     
          var reference = Firestore.instance.collection('Usuarias').document(uid);
          
          reference.get().then((DocumentSnapshot ds) {
            
           
            user =  ds['admin'].toString();
             
         
           
       });
        prefs.setString("admin",user); 
        
     }
    static Future<String> getIncidenceOpen(uid) async {
       SharedPreferences prefs = await SharedPreferences.getInstance();
       
     
      Firestore.instance
    .collection('Incidencias')
    .where("open", isEqualTo: "true")
    .snapshots()
    .listen((data) =>
        data.documents.forEach((doc) => 
        prefs.setString("incidenceId", doc['unique_id'])
        

        
        )); 

      
     }
     //Get Location de la Usuaria
     static Future getLocationData( ) async {
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString("incidenceId");
      String latitude;
      String longitude;
     
         var reference = await Firestore.instance.collection('Usuarias').document(uid);
          await reference.get().then((DocumentSnapshot ds) {
           
            latitude =  ds['latitude'];
            longitude = ds['longitude'];
            
       });
       //guardarlo en prefs
      
      prefs.setString("lat_from_user", latitude);  
      prefs.setString("lon_from_user", longitude);  
     }
     //Get Location apartir de la Incicencia Usuaria
     static Future getIncidenceLocationAdmin() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString("incidenceId");
    
      var latitude;
      var longitude;
     
         var reference = await Firestore.instance.collection('Incidencias').document(uid);
          await reference.get().then((DocumentSnapshot ds) {
           
            latitude =  ds['latitude_admin'];
            longitude = ds['longitude_admin'];
            
       });
       
        //guardarlo en prefs
     
      prefs.setString("lat_admin", latitude);  
      prefs.setString("lon_admin",longitude);     
     }
     //Get Location apartir de la Incicencia Administradora
    static  getIncidenceLocationUser() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uniqueId = prefs.getString("incidenceId");
      var lat_user ;
      var lon_user;
     
        var reference =  Firestore.instance.collection("Incidencias").document(uniqueId);
        await reference.get().then((DocumentSnapshot ds) {
           
            lat_user =  ds['latitude'].toString();
            lon_user = ds['longitude'].toString();
            
       });
       
     
      prefs.setString("lat_user", lat_user);  
      prefs.setString("lon_user", lon_user);  
    }
    
     //Get Incidence final Date
      static Future<String> getIncidenceDate() async {
       SharedPreferences prefs = await SharedPreferences.getInstance();
        String uniqueId = prefs.getString("incidenceId");
    
      String open = 'carregant dades';
     
         var reference =  Firestore.instance.collection('Incidencias').document(uniqueId);
          await reference.get().then((DocumentSnapshot ds) {
           
            open =  ds['created'].toString();
            
       });
       
        prefs.setString("IncidentDate", open);  
     }
    
      
    }
    
    class Boolean {
}