import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'LoaduserButton.dart';

/* class: Database
  Descripcion: Esta clase funciona como intermediario entre firebase cloud store y la app*/
class Database {

/* Function: getIncidenceState()
  Descripcion: Obtener el estado de la incidencia*/
  static getIncidenceState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uniqueId = prefs.getString("incidenceId");
     String open = 'not';
     Firestore.instance
    .collection('Incidencias')
    .where("unique_id",isEqualTo: uniqueId)
    .snapshots()
    .listen((data) =>
        data.documents.forEach((doc) {

          
           open = doc['open'];
          prefs.setString("state", doc['open']);
        return open.toString();
        }
      ));
}
       
/* Function: uploadChatImage()
  Descripcion: Subir una imagen al Storage i el path a la base de datos*/ 
  static void uploadChatImage(File img, String uid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uniqueId = prefs.getString("incidenceId");
  String nombre = prefs.getString("userName");
  String admin = prefs.getString("admin");
  var now = new DateTime.now();
  Uuid id = new Uuid();
  String uid = id.v1();
  StorageReference reference = FirebaseStorage.instance.ref().child('$id/Incidence/$uniqueId/$uid');
  StorageUploadTask uploadTask = reference.putFile(img);
  StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  var url = await taskSnapshot.ref.getDownloadURL();
  var mensaje = <String, dynamic>{
    'id': 'chat',
    'name' : nombre,
    'created': now.toString(),
    'value': " ",
    'admin': admin,
    'type': "image",
    'path': url
  };
  var reference2 = Firestore.instance.collection('Incidencias').document('$uniqueId').collection('Mensajes').document('$uid') ;
  reference2.setData(mensaje);
}    

/* Function: uploadImage()
  Descripcion: Sube una imagen al Storage y la guarda en el path de usuaria de la base de datos*/
static void uploadImage(File img, String uid) async {
  StorageReference reference = FirebaseStorage.instance.ref().child('$uid/profile');
  StorageUploadTask uploadTask = reference.putFile(img);
  StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  var url = await taskSnapshot.ref.getDownloadURL();
  var user = <String, dynamic>{
      'profile_path':url
  };
  final DocumentReference reference2 = Firestore.instance.document("Usuarias/$uid") ;
  reference2.updateData(user);
}

/* Function: downloadImage()
  Descripcion: Obtiene el enlace de internet para visualizar la imagen*/
static Future<String> downloadImage(String uid) async {
  var reference =( await FirebaseStorage.instance.ref().child('$uid/profile').getDownloadURL());
  String downloadUrl = reference.toString();
  return downloadUrl;
}

/* Function: createIncidence()
  Descripcion: creación de una incidencia sin administrador*/
 static  createIncidence(String uid,String fecha ,String name,String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
       'id_admin' : 'no disponile',
      'longitude_admin' : '0.00',
      'latitude_admin': '0.00',
      'name_admin' : 'Administradora no Disponible',
      'created_admin': '',
      'phone' : phone,
      'unique_id': uniqueId
    };
    final DocumentReference reference = Firestore.instance.document('Incidencias/$uniqueId') ;
    reference.setData(incidencia);
  }

/* Function: uploadImage()
  Descripcion: se añade un administrador a una incidencia previamente creada.*/
 static Future<String> selectIncidence(String uid_admin,String fecha_admin,String latitude_admin,String longitude_admin,String name_admin,String unique_id, String phone) async {
    String uniqueId = unique_id;
    var name;
    name = name_admin;
    if(name==null){
      name = "no disponible";
    }
    var incidencia = <String, dynamic>{
      'id_admin' : uid_admin,
      'longitude_admin' : longitude_admin,
      'latitude_admin': latitude_admin,
      'name_admin' : name,
      'created_admin': fecha_admin,
      'phone_admin': phone
      
    };
    final DocumentReference reference = Firestore.instance.document('Incidencias/$uniqueId') ;
    reference.updateData(incidencia);
 }

 
/* Function: createMessage()
  Descripcion: crea un mensaje dentro de la incidencia activa*/
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
      'admin': admin,
      'type': 'text',
      'path' : ' '
    };
    Uuid id = new Uuid();
    String uid = id.v1();
    var reference = Firestore.instance.collection('Incidencias').document('$uniqueId').collection('Mensajes').document('$uid') ;
    reference.setData(mensaje);
 }

/* Function: createUser()
  Descripcion: Comprueba que exista un usuario con ese uid y email, si no existe en la base de datos entonces ,
  crea otro.*/
 static createUser( String email,String uid, context,token) {
   bool create = true;
    final DocumentReference reference = Firestore.instance.document("Usuarias/$uid") ;
     reference.snapshots().listen((datasnapshot){
       if(token==null){
        token = " ";
      }
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
          'longitude': '0.00',
          'phone': '695745155',
          'profile_path' : ' ',
          'modeEmergencia': "false",
          'token': token,
        };
        if(create){
          reference.setData(user); 
        }
      }
    });
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> LoadUserButton()));
  }

 /* Function: createUserFromAdmin()
  Descripcion: Crea un usuario en la base de datos*/    
 static createUserFromAdmin( String email,String uid,String phone,String name) {
   bool create = true;
    final DocumentReference reference = Firestore.instance.document("Usuarias/$uid") ;
     reference.snapshots().listen((datasnapshot){
       String token = " ";
      if(datasnapshot.exists){
        create = false;
      }
      else{
        var user = <String, dynamic>{
          'name': name,
          'email' : email,
          'admin' : 'false',
          'latitude' : '0.00',
          'longitude': '0.00',
          'phone': phone,
          'profile_path' : ' ',
          'modeEmergencia': "false",
          'token': token,
        };
        if(create){
          reference.setData(user);
        }
      }
    });
  }

/* Function: updateUser()
  Descripcion: Actualiza los datos de usuario*/  
  static updatetUser( String uid,String phone,String name) {
    bool create = true;
    final DocumentReference reference = Firestore.instance.document("Usuarias/$uid") ;    
        var user = <String, dynamic>{
          'name': name,
          'phone': phone,
        };
        reference.updateData(user);
    }

/* Function: updateToken()
  Descripcion: Actualitza el token(id de dispositiu) de cada usuari*/  
  static updateToken( String uid,String token) {
   
    final DocumentReference reference = Firestore.instance.document("Usuarias/$uid") ; 
      var user = <String, dynamic>{
        'token': token,
      };
      reference.updateData(user);
  }

  /* Function: setLocation()
  Descripcion: guarda la locaziación de la usuaria*/  
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

   /* Function: incidenceSwitch()
  Descripcion: Cambia el estado de la incidencia a partir del estado del swtich*/  
  static incidenceSwitch(state) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uniqueId = prefs.getString("incidenceId");
    var user = <String, dynamic>{
      'open' : state.toString()
    };
    final DocumentReference reference = Firestore.instance.document("Incidencias/$uniqueId") ;
    reference.updateData(user);
  }
 
 /* Function: setIncidenceLocationAdmin()
  Descripcion: guarda los datos de localizacion del admin, en la incidencia*/  
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

  /* Function: setIncidenceLocationUser()
  Descripcion: guarda los datos de localizacion del user, en la incidencia*/  
static  setIncidenceLocationUser( double lat, double long,String uid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uniqueId = prefs.getString("incidenceId");
  var latitude = lat.toString();
  var longitude = long.toString();
  var user = <String, dynamic>{
    'latitude' : latitude,
    'longitude': longitude
  };
  final DocumentReference reference = Firestore.instance.document("Incidencias/$uniqueId") ;
  reference.updateData(user);
}

   /* Function: getUserData()
  Descripcion: Obtiene el nombre del usuario*/ 
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

/* Function: getUserPhone()
Descripcion: Obtener el teléfono del usuario*/   
static Future<String> getUserPhone( String uid) async {
    
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String user = 'carregant dades';
  
      var reference =  Firestore.instance.collection('Usuarias').document(uid);
      await reference.get().then((DocumentSnapshot ds) {
        
        user =  ds['phone'].toString();
        
    });
    prefs.setString("phone",user);
    return user;   
}

/* Function: getAdminName()
Descripcion: Obtiene el nombre del admin*/
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

/* Function: getUserName()
  Descripcion: Obtiene el nombre del usuario*/
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
/* Function: getUserName()
  Descripcion: Obtiene el nombre del usuario*/
 static getIncidentList() async {
  List<List<String>> lista = List<List<String>>() ;
   Firestore.instance
    .collection('Incidencias')
    .where("open",isEqualTo: "false")
    .snapshots()
    .listen((data) =>
        data.documents.forEach((doc) {
          
          lista.add(<String>[doc['created'],doc['name'], doc['longitude']]);
              
        }
      ));
      
   return lista;
}


/* Function: getAdmin()
Descripcion: Obtiene si el usuario autenticado es un administrador */
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


/* Function: getIncidenceLocationAdmin()
Descripcion: Obtiene la localizacion del administrador guardada en la incidencia */
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
  prefs.setString("lat_admin", latitude);   
  prefs.setString("lon_admin",longitude);     
}

/* Function: getIncidenceLocationUser()
Descripcion: Obtiene la localizacion de la usuaria guardada en la incidencia */
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
  return lat_user;
}
    
/* Function: getIncidenceDate()
Descripcion: Obtiene la fecha de la creación de la incidencia */
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


/* Function: emergencySwitch()
Descripcion: Cambia el estado de el modo de emergencia */
static emergencySwitch(state,id) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var user = <String, dynamic>{
    'modeEmergencia' : state.toString()
  };
  final DocumentReference reference = Firestore.instance.document("Usuarias/$id") ;
  reference.updateData(user);
  prefs.setString("emergencia",state.toString());
}

}//end Class
    
   