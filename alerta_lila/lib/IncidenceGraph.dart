import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'AdminUserProfile.dart';

import 'IncidenceActiveList.dart';
import 'IncidenceAdminList.dart';
import 'IncidenceToPdf.dart';
class BarChartSample4 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BarChartSample4State();
}

class BarChartSample4State extends State<BarChartSample4> {
  final Color dark = const Color(0xff3b8c75);
  final Color normal = const Color(0xff64caad);
  final Color light = const Color(0xff73e8c9);
  
  List<BarChartGroupData> data = [];

  @override
  void initState() {
    super.initState();
    data = [
     
      BarChartGroupData(
        x: 2,
        barsSpace: 4,
        barRods: [

          BarChartRodData(
              y: 32,
              rodStackItem: [
                BarChartRodStackItem(0, 7, dark),
                BarChartRodStackItem(7, 24, normal),
                BarChartRodStackItem(24, 32, light),
              ],
              borderRadius: const BorderRadius.all(Radius.zero)),
     
   
        ],
      ),
        BarChartGroupData(
        x: 2,
        barsSpace: 4,
        barRods: [

          BarChartRodData(
              y: 32,
              rodStackItem: [
                BarChartRodStackItem(0, 7, dark),
                BarChartRodStackItem(7, 14, normal),
                BarChartRodStackItem(14, 24, light),
              ],
              borderRadius: const BorderRadius.all(Radius.zero)),
     
   
        ],
      ),
      
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          title: Text("Gràfic de casos"),
           gradient: LinearGradient(colors:[Colors.purple,Colors.purpleAccent]),
           actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => AdminList()),);
              },
            ),
           ],
        ),
        body: AspectRatio(
      aspectRatio: 1,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY: 35,
              barTouchData: const BarTouchData(
                enabled: false,
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: SideTitles(
                  showTitles: true,
                  textStyle: TextStyle(color: const Color(0xff939393), fontSize: 10),
                  margin: 10,
                  getTitles: (double value) {
                    switch (value.toInt()) {
                      case 0:
                        return 'Obertes';
                      case 1:
                        return 'Tancades';

                      default:
                        return '';
                    }
                  },
                ),
                leftTitles: SideTitles(
                  showTitles: true,
                  textStyle: TextStyle(
                      color: const Color(
                        0xff939393,
                      ),
                      fontSize: 10),
                  getTitles: (double value) {
                    return value.toInt().toString();
                  },
                  interval: 10,
                  margin: 0,
                ),
              ),
              gridData: FlGridData(
                show: true,
                checkToShowHorizontalLine: (value) => value % 10 == 0,
                getDrawingHorizontalLine: (value) => const FlLine(
                  color: Color(0xffe7e8ec),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              groupsSpace: 4,
              barGroups: data,
            ),
          ),
        ),
      ),
    ),
    );
  }
  /*Función: _onItemTapper()
Descripcion: navegación del menu */
    void _onItemTapped(int index) {
  setState(() {
    switch(index){
      case 0: {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => AdminList()),);
      }
      break;
      case 1: {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => ActiveList()),);
      }
      break;
      case 2: {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => AdminUserProfile()),);
      }
      break;
      case 4: {
        toPdf();
      }
      break;
    }
    
  });
  }
}