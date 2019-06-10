import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threading/threading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat.dart';
  
void main() => runApp(RealTimeLocationOff());


class RealTimeLocationOff extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
        home: Scaffold(
          body: FireMap()
      )
    );
  }
}

class FireMap extends StatefulWidget {
  @override
  State createState() => FireMapState();
  
}


class FireMapState extends State<FireMap> {
  GoogleMapController mapController;
  final LocalStorage storage = new LocalStorage('uid');
  var latitude_admin = 0.00;
  var longitude_admin = 0.00;
  var latitude_user = 0.00;
  var longitude_user = 0.00;
  Location location = new Location();
  Timer timer;
  bool incidenceSwitch = false;
  String nombreUser = "";
  String nombreAdmin = "";
  String close = "";
  var finalDate;
  String incidenceId = "";
  SharedPreferences prefs ;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId markerId = new MarkerId("prueba");
  MarkerId markerId2 = new MarkerId("prueba2");
  List<Polyline> polygons = <Polyline>[];
  PolylineId polylineId = new PolylineId("polyline");
  var markerIcon;
  final Database _database = Database();
  
  @override   
  initState() {
    super.initState();
    _getinidenceId();
    _syncState();
  }//End init State
_getinidenceId() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    incidenceId = prefs.get("incidenceId");
  }); 
  return prefs.get("incidenceId");
}
_getState() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.get("state");
}
_setPolygons(){
 
  List<LatLng> polylinePoints = <LatLng>[
    new LatLng(latitude_admin, longitude_admin), new LatLng(latitude_user, longitude_user)
  ];
  polygons = <Polyline>[
    new Polyline(
      color: Colors.purpleAccent,
      polylineId: polylineId,
      points: polylinePoints
    ),
  ];
}
  
     //obtener el user
  getUserId() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var uid = prefs.getString("user");
  return uid ;
  }
  //Crear el pin en googleMaps
  setMarker(){
     markers[markerId] = new Marker(

                      
                      markerId: markerId,
                      
                      position: LatLng(
                        latitude_user,longitude_user
                      ),
                      infoWindow: InfoWindow(title: nombreUser, snippet: "posició de l'usuarià al tancar l'incidencia"),
                      onTap: ()=>{},
                     
                      
                    );
    markers[markerId2] =  new Marker(

                      
                      markerId: markerId2,
                      
                      position: LatLng(
                        latitude_admin,longitude_admin
                      ),
                      infoWindow: InfoWindow(title: nombreAdmin, snippet: "posició de la Administradora al tancar l'incidencia"),
                      onTap: ()=>{},
                     
                      
                    );
  }

  //Obtener la fecha de la incidencia
  getIncidenceDate(){
   Database.getIncidenceDate();
  }
  

//sincornizacion con la incidencia para conseguir todos los datos
_syncState() async {
   var id = await _getinidenceId();
    id = id.toString();
    incidenceId = id;
    var state = await _getState();
    state = state.toString();
 
    
    DocumentReference reference = Firestore.instance.collection('Incidencias').document(id);
    
    reference.snapshots().listen((querySnapshot) {
      
        // Do something with change
        print("this was changed, " + querySnapshot.data['open'] );
      
        
        // Do something with change
        //getUserLocation();
        //getAdminLocation();
        latitude_admin = double.parse(querySnapshot.data['latitude_admin']);
        longitude_admin = double.parse(querySnapshot.data['longitude_admin']);
        latitude_user = double.parse(querySnapshot.data['latitude']);
        longitude_user = double.parse(querySnapshot.data['longitude']);
        nombreAdmin = querySnapshot.data['name_admin'];
        nombreUser = querySnapshot.data['name'];
       if(latitude_admin!=0.00 && longitude_admin!=0.00){
        setMarker();
        _setPolygons();
       }
        
        
      
    });
}

 
Widget _buildListItem(BuildContext context,DocumentSnapshot document){
         return Row(
            
             children: [
                       new Expanded(child: Column(
                          children: <Widget>[
                                  Expanded(
                                    child: GoogleMap(
                                  
                                    initialCameraPosition: CameraPosition(target: LatLng( double.parse(document['latitude']) ,double.parse(document['longitude'])), zoom: 15),
                                    compassEnabled: true,
                                    
                                    myLocationEnabled: false, // Add little blue dot for device location, requires permission from user
                                    mapType: MapType.normal, 
                                    
                                    markers:  Set<Marker>.of(markers.values),
                                ),
                              ),
                             new Container(
                               padding:  EdgeInsets.all(8.0),
                                child: 
                                Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                new Text("Administradora",style:TextStyle(color: Color(0xff883997),fontWeight: FontWeight.bold )),
                                 new Text("Data de Creació",style: TextStyle(color: Color(0xff883997),fontWeight: FontWeight.bold ),),
                                 
                                  ],
                                 ),
                                ),
                                new Container(
                               padding:  EdgeInsets.all(8.0),
                                child: 
                                Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                               new Text(document['name_admin']),
                                 new Text(document['created'])
                                  ],
                                 ),
                                ),
                                  new Container(
                               padding:  EdgeInsets.all(15.0),
                                child: 
                                Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                  telefon,chat
                                  ],
                                 ),
                                ),      
                                  ],
                                  ),
                                  ),
                       ],
                       
                     );

}
  //Generacion de la interface, UI
  @override
  Widget build(context) {
   // getCounter();
   return Scaffold(
        appBar: AppBar(
          title: Text("Incidencia"),
           backgroundColor: Colors.purple[300],
            actions:  <Widget>[
             Switch(
                value: incidenceSwitch,
                
                onChanged: (value) {
                  setState(() {
                    incidenceSwitch = value;
                    Database.incidenceSwitch(value);
                  });
                },
                activeTrackColor: Color(0xffee98fb), 
                activeColor: Colors.purple[300],
              ),
           ] 
        ),
        body: StreamBuilder( 
                stream: Firestore.instance.collection('Incidencias').where("unique_id",isEqualTo: incidenceId).snapshots() ,
                 builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){  
                    if (!snapshot.hasData) return new Center(child: CircularProgressIndicator(), ) ;
                    return new ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemExtent: 600.00,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context,index) => _buildListItem(context,snapshot.data.documents[index]),
                      );
                 }),
                    );

        
        
  }
final leftSection = new Container(
  
  child: new Text("Usuaria")
  );
final middleSection = new Container(
 
  child: new Text("Duracion de la atención")
  );
  final nomAdministradora = new Container(
  
  child: new Text('nombreAdmin')
  );
final duradaAtencio = new Container(
 
  child: new Text("00:00:00")
  );
final telefon = new 
   
   IconButton(icon:Icon(Icons.phone),color: Color(0xff883997),iconSize: 60.0, onPressed:()=> launch("tel://695745855"),);
  
  final chat = 
 
   IconButton(icon:Icon(Icons.chat),color: Color(0xff883997),iconSize: 60.0,onPressed: (){ }
  );
  void _onMapCreated(GoogleMapController controller) {
    
    setState(() {
      mapController = controller;
      mapController.animateCamera( CameraUpdate.newCameraPosition( CameraPosition(
        target : LatLng(latitude_user, longitude_user),zoom:15,
        

      ))
      
      );
      
    });
  }
 
 
 
}