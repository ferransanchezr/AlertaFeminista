// ignore_for_file: omit_local_variable_types

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'database.dart';
import 'package:flutter/widgets.dart';
import "package:printing/printing.dart";

Future toPdf() async{
  final Document pdf = Document();
  //poner el stream builder aki
 
// mirar el packqge printing 3.1.0
  pdf.addPage(
    MultiPage( build: (Context context) {
      StreamBuilder(
                stream: Firestore.instance.collection('Incidencias').where("open",isEqualTo: "false").where("id",isEqualTo: userName).snapshots() ,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  
                  return new ListView(
                    padding: EdgeInsets.all(8.0),
                    children: snapshot.data.documents.map((DocumentSnapshot document) {
                      return Center (child: 
                      Text(document['name']),
                      );
                    }
                  )
                  );
      }
      );
      }

    )



  );
  Directory tempDir = await getTemporaryDirectory();
String tempPath = tempDir.path;

  final File file = File('${tempPath}/example.pdf');
  file.writeAsBytesSync(pdf.save());
  OpenFile.open('${tempPath}/example.pdf');
  print('${tempPath}/example.pdf');
  Database.getIncidentList();
  
}
