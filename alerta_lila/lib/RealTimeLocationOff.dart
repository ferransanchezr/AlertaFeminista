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
import 'package:gradient_app_bar/gradient_app_bar.dart';
  
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

  
  @override   
  initState() {
    super.initState();
    _getinidenceId();
    _syncState();
  }//End init State

  /*Función: _getIncidenceId()
Descripcion: Obtiene el valor Id de las preferencias*/
_getinidenceId() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    incidenceId = prefs.get("incidenceId");
  }); 
  return prefs.get("incidenceId");
}

/*Función: _getState()
Descripcion: Obtiene el valor del estado de las preferencias*/
_getState() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.get("state");
}

/*Función: _setPolygons()
Descripcion: Crea una línia que une a la Usuària con la Administradora*/
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
  

 /*Función: _setMarker()
  Descripcion: Crea un Pin donde en la localización de la administradora*/
  _setMarker(){
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
  

/*Función: _setMarker()
  Descripcion: Crea un Pin donde en la localización de la administradora*/
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
  
        latitude_admin = double.parse(querySnapshot.data['latitude_admin']);
        longitude_admin = double.parse(querySnapshot.data['longitude_admin']);
        latitude_user = double.parse(querySnapshot.data['latitude']);
        longitude_user = double.parse(querySnapshot.data['longitude']);
        nombreAdmin = querySnapshot.data['name_admin'];
        nombreUser = querySnapshot.data['name'];
       if(latitude_admin!=0.00 && longitude_admin!=0.00){
        _setMarker();
        _setPolygons();
       }  
    });
}
Widget _buildListItem(BuildContext context,DocumentSnapshot document){
return Stack(
  children: [
GoogleMap(
  initialCameraPosition: CameraPosition(target: LatLng( double.parse(document['latitude_admin']) ,double.parse(document['longitude_admin'])), zoom: 15),
  compassEnabled: false,
  onMapCreated: _onMapCreated,
  myLocationEnabled: true, // Add little blue dot for device location, requires permission from user
  mapType: MapType.normal, 

  markers:  Set<Marker>.of(markers.values),
  polylines: Set<Polyline>.of(polygons),
  ),
new Container(
    child: new Center(
    child:new Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[ Card(
    elevation: 8.0,
    margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
    child: Container(
      decoration: BoxDecoration(color: Colors.white),
      child: 
        ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
        leading: Container(
        padding: EdgeInsets.only(right: 12.0),
        decoration: new BoxDecoration(
        border: new Border(
        right: new BorderSide(width: 1.0, color: Colors.black26))),
        child: 
        IconButton(icon: Icon(Icons.directions), color:  Colors.blue, iconSize: 40.0, onPressed:(){

        _launchMapsUrl(double.tryParse(document['latitude']), double.tryParse(document['longitude']));

        }),

        ),
        title: Text(
        document['name'],
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
// subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

subtitle: Row(
children: <Widget>[
Icon(Icons.query_builder, color: Colors.purple[300]),
Text('  '+document['created'], style: TextStyle(color: Colors.grey))
],
),
trailing:
Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0)),
                        
              ),
              ),
              ],
            ),
            ),
          ),
        ], 
      );

}
/*Función: _launchMapUrl()
  Descripcion: Abre Google Maps con las coordenadas de la administradora*/
void _launchMapsUrl(double lat, double lon) async {
  final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

  @override
  Widget build(context) {
   return Scaffold(
     floatingActionButton:
      FloatingActionButton(
        child: Icon(Icons.chat),
        backgroundColor: Color(0xff883997),
        foregroundColor: Colors.white,
        onPressed: (){
          Navigator.push(this.context,MaterialPageRoute(builder: (context) => chatPage()),);
        },
      ),
        appBar: GradientAppBar(
          title: Text("Incidencia"),
           gradient: LinearGradient(colors:[Colors.purple,Colors.purpleAccent]),
            actions:  <Widget>[
             
           ] 
        ),
        body: StreamBuilder(
          stream: Firestore.instance.collection('Incidencias').where("unique_id",isEqualTo: incidenceId).snapshots() ,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData) return new Center(child: CircularProgressIndicator(), ) ;
              return _buildListItem(context,snapshot.data.documents[0]);
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
final telefon = new IconButton(icon:Icon(Icons.phone),color: Color(0xff883997),iconSize: 60.0, onPressed:()=> launch("tel://695745855"),);
final chat = IconButton(icon:Icon(Icons.chat),color: Color(0xff883997),iconSize: 60.0,onPressed: () {});

  /*Función: _onMapCreated()
Descripcion: Actualizacion del mapa*/  
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