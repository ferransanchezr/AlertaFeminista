// ignore_for_file: omit_local_variable_types

import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'database.dart';

Future toPdf() async{
  final Document pdf = Document();
  pdf.addPage(MultiPage(
      pageFormat:
          PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      crossAxisAlignment: CrossAxisAlignment.start,
      header: (Context context) {
        if (context.pageNumber == 1) {
          return null;
        }
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            decoration: const BoxDecoration(
                border:
                    BoxBorder(bottom: true, width: 0.5, color: PdfColors.grey)),
            child: Text('Portable Document Format',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      footer: (Context context) {
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      
      build:  
      (Context context) =>
      
    
       <Widget>[
         
          
            Header(
                level: 0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Informe de Casos', textScaleFactor: 2),
                      PdfLogo()
                    ])),
            Paragraph(
                text:
                    'En aquest apartat podem veure un informe dels casos tancats en el punt lila'),
            Table.fromTextArray(context: context, data: const <List<String>>[
              <String>['01/03/2020', 'Nom1', 'Longitud: 784d.323, Longitud: 213.244'],
              <String>['02/03/2020', 'Nom2', 'Longitud: 784d.323, Longitud: 213.244'],
              <String>['03/03/2020', 'Nom3', 'Longitud: 784d.323, Longitud: 213.244'],
              
            ]),
            Padding(padding: const EdgeInsets.all(10)),
            Paragraph(
                text:
                    "Aquest formulari s'ha generat automaticament.")
          ]));
  Directory tempDir = await getTemporaryDirectory();
String tempPath = tempDir.path;

  final File file = File('${tempPath}/example.pdf');
  file.writeAsBytesSync(pdf.save());
  OpenFile.open('${tempPath}/example.pdf');
  print('${tempPath}/example.pdf');
  Database.getIncidentList();
  
}
