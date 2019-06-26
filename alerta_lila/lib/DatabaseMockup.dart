
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
class DatabaseMockup {
/* Function: getIncidenceState()
  Descripcion: Obtener el estado de la incidencia*/
   getIncidenceState() async {
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
        
        }
      ));
  
}
}