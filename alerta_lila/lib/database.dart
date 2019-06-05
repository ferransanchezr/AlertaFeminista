import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

class Database{
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
      'unique_id': uniqueId,
      'longitude' : "0.00",
      'latitude': "0.00",
      'name' : name,
      'created': fecha,
      'open': 'true',
       'id_admin' : '',
      'longitude_admin' : '',
      'latitude_admin': '',
      'name_admin' : 'Marta',
      'created_admin': ''

      
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
  static Future<String> createMessage( String string,String name) async {
  
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uniqueId = prefs.getString("incidenceId");
    var mensaje = <String, dynamic>{
      'id': 'chat',
      'name' : name,
      'created': '1/04/2019',
      'value': string
    };
   Uuid id = new Uuid();
String uid = id.v1();
    var reference = Firestore.instance.collection('Incidencias').document('$uniqueId').collection('Mensajes').document('$uid') ;

    reference.setData(mensaje);

 }
 static Future<String> createUser( String email,String uid) async {
   bool create = true;
    final DocumentReference reference = Firestore.instance.document("Usuarias/$uid") ;
    reference.snapshots().listen((datasnapshot){
      if(datasnapshot.exists){
        create = false;
      }
      else{
        var user = <String, dynamic>{
          'name': 'usuaria',
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
   
   

         
      
        
        
      
     }
        
     static Future<String> setOpen( String open ,String uid) async {
    
        
        var user = <String, dynamic>{
         'open' : open,
          
        };
        
        final DocumentReference reference = Firestore.instance.document('Incidencias/$open') ;
    
        reference.updateData(user);
      
     }
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
     
         var reference = await Firestore.instance.collection('Incidencias').document(uniqueId);
          await reference.get().then((DocumentSnapshot ds) {
           
            user =  ds['name'].toString();
            
       });
        prefs.setString("UserName", user);
        return user;   

     }
      static Future<String> getAdmin() async {
       SharedPreferences prefs = await SharedPreferences.getInstance();
       String uid = prefs.get("user");
       String user = 'carregant dades';
     
          var reference = await Firestore.instance.collection('Usuarias').document(uid);
          await reference.get().then((DocumentSnapshot ds) {
           
            user =  ds['admin'].toString();
            
       });
       
        prefs.setString("admin",user);   
     }
    static Future<String> getIncidenceOpen( String uid) async {
       SharedPreferences prefs = await SharedPreferences.getInstance();
        String uniqueId = prefs.getString("incidenceId");
    
      String user = 'carregant dades';
     
         var reference = await Firestore.instance.collection('Incidencias').document(uniqueId);
          await reference.get().then((DocumentSnapshot ds) {
           
            user =  ds['open'].toString();
            
       });
       
        return user;   
     }
     //Get Location de la Usuaria
     static Future getLocationData( String uid) async {
      
    
      var user = [2];
     
         var reference = await Firestore.instance.collection('Usuarias').document(uid);
          await reference.get().then((DocumentSnapshot ds) {
           
            user[0] =  ds['latitude'];
            user[1] = ds['longitude'];
            
       });
       //guardarlo en prefs
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("lat_from_user", user[0]);  
      prefs.setInt("lon_from_user",user[1]);  
     }
     //Get Location apartir de la Incicencia Usuaria
     static Future getIncidenceLocationAdmin( String uid) async {
      
    
      var user = [2];
     
         var reference = await Firestore.instance.collection('Usuarias').document(uid);
          await reference.get().then((DocumentSnapshot ds) {
           
            user[0] =  ds['latitude'];
            user[1] = ds['longitude'];
            
       });
       
        //guardarlo en prefs
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("lat_admin", user[0]);  
      prefs.setInt("lon_admin",user[1]);     
     }
     //Get Location apartir de la Incicencia Administradora
    static Future getIncidenceLocationUser( String uid) async {
      
    
      var user = [2];
     
         var reference = await Firestore.instance.collection('Usuarias').document(uid);
          await reference.get().then((DocumentSnapshot ds) {
           
            user[0] =  ds['latitude_admin'];
            user[1] = ds['longitude_admin'];
            
       });
       
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("lat_user", user[0]);  
      prefs.setInt("lon_user",user[1]);  
    }
     static Future<String> getIncidenceState() async {
       SharedPreferences prefs = await SharedPreferences.getInstance();
        String uniqueId = prefs.getString("incidenceId");
    
      String open = 'carregant dades';
     
         var reference = await Firestore.instance.collection('Incidencias').document(uniqueId);
          await reference.get().then((DocumentSnapshot ds) {
           
            open =  ds['open'].toString();
            
       });
       
        prefs.setString("state", open);  
     }
     //Get Incidence final Date
      static Future<String> getIncidenceDate() async {
       SharedPreferences prefs = await SharedPreferences.getInstance();
        String uniqueId = prefs.getString("incidenceId");
    
      String open = 'carregant dades';
     
         var reference = await Firestore.instance.collection('Incidencias').document(uniqueId);
          await reference.get().then((DocumentSnapshot ds) {
           
            open =  ds['created'].toString();
            
       });
       
        prefs.setString("IncidentDate", open);  
     }
    
      
    }
    
    class Boolean {
}