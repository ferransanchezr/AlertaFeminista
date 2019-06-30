import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'RealTimeLocationOff.dart';
  
void main() => runApp(RealTimeLocationLoad());


class RealTimeLocationLoad extends StatelessWidget {

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
  var latitude = 50.453479;
  var longitude = -2.318524;
  var latitude_user = 50.453479;
  var longitude_user = -2.318524;
  Location location = new Location();
  Timer timer;
  String nombreUser = "";
  String nombreAdmin = "";
  String close = "";
  var finalDate;
  String incidenceId = "";
   List<Polyline> polygons = <Polyline>[];
  SharedPreferences prefs ;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId markerId = new MarkerId("prueba");
  MarkerId markerId2 = new MarkerId("prueba2");
  var markerIcon;
  
  @override   
  initState() {
    super.initState();
    _getUser();
    _getUserLocation() ;
     getAdminLocation();
  }//End init State

  /*Función: _getUser()
  Descripcion: Obtiene el nombre de usuario*/
  _getUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("user");
      Database.getUserName(id).then((user){
        nombreUser = prefs.getString("UserName");
      });
          
  }

/*Función: _setMarker()
Descripcion: Abre Google Maps con las coordenadas de la administradora*/
_setMarker(){
    markers[markerId] = new Marker(
    markerId: markerId,
    position: LatLng(
      latitude_user,longitude_user
    ),
    infoWindow: InfoWindow(title: nombreUser, snippet: "aquesta es la posició de la usuaria amb l'incidencia"),
    onTap: ()=>{},
  );
markers[markerId2] =  new Marker(
    markerId: markerId,
    position: LatLng(
      latitude,longitude
    ),
    infoWindow: InfoWindow(title: nombreUser, snippet: "aquesta va ser la meva posició"),
    onTap: ()=>{},
  );
  }

  

/*Función: _getUserLocation()
  Descripcion: Obtiene la localizacion de la administradora*/
_getUserLocation()  async {
   SharedPreferences prefs = await SharedPreferences.getInstance(); 
    Database.getIncidenceLocationAdmin().then((user){
         setState(() {
        latitude_user =  double.parse(prefs.get("lat_admin"));
        longitude_user = double.parse(prefs.get("lon_admin"));
        _setMarker();
    });
    });
  }
  getUserPrefLocation()async{  
}

/*Función: _getAdminLocation()
  Descripcion: Obtiene la localizacion de la administradora*/
  Future getAdminLocation()  async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
      await Database.getIncidenceLocationUser().then((option){
          setState(() {
      latitude =  double.parse(prefs.getString("lat_user"));
      longitude = double.parse(prefs.getString("lon_user"));
      //hace que se vea raro
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => RealTimeLocationOff()),);
         });
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
        appBar: AppBar(
          title: Text("Incidencia"),
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
final telefon = new Container(
  child: IconButton(icon:Icon(Icons.phone),color: Colors.purple,iconSize: 40.0, onPressed:()=> launch("tel://695745855"),)
  );
  final chat = new Container(
 
  child: IconButton(icon:Icon(Icons.chat),color: Colors.purple,iconSize: 40.0,onPressed: (){ }
  ,)
  );

  /*Función: _onMapCreated()
Descripcion: Actualizacion del mapa*/  
void _onMapCreated(GoogleMapController controller) {
  
  setState(() {
    mapController = controller;
    mapController.animateCamera( CameraUpdate.newCameraPosition( CameraPosition(
      target : LatLng(latitude, longitude),zoom:15,

    ))
    );
    
  });
}
 
 
 
}