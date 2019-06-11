import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'authUser.dart';
import 'database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threading/threading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat.dart';
  
void main() => runApp(RealTimeLocation());


class RealTimeLocation extends StatelessWidget {

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
  String nombreUser = "";
  String nombreAdmin = "";
  String close = "";
  var finalDate;
  String incidenceId = "";
  SharedPreferences prefs ;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  List<Polyline> polygons = <Polyline>[];
  MarkerId markerId = new MarkerId("prueba");
  PolylineId polylineId = new PolylineId("polyline");
  
  var markerIcon;
  final Database _database = Database();
  final myController = TextEditingController();
  
  @override   
  initState()  {
    super.initState();
    //carga las prefs
    //getUser();
    getLocation();
   _syncState();
  // _syncLocation();
   
   //getUserLocation() ;
   // getUserPrefLocation();
  
 
    var thread = new Thread(() async{
        prefs = await SharedPreferences.getInstance();
        var open = prefs.get("state");
        if(open == "true"){
          startTimer();
        }else{
          finalDate = prefs.get("IncidentDate");
        }
      
        
    });
   //thread.start();
    
  }//End init State

_getinidenceId() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
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
_setState(String state) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("state", state);
}
_syncState() async {
   var id = await _getinidenceId();
    id = id.toString();
    var state = await _getState();
    state = state.toString();
 
    
    DocumentReference reference = Firestore.instance.collection('Incidencias').document(id);
    
    reference.snapshots().listen((querySnapshot) {
      
        // Do something with change
        print("this was changed, " + querySnapshot.data['open'] );
        if(state!=querySnapshot.data['open'] ){
          _setState(querySnapshot.data['open']);
          Navigator.pushReplacement(this.context,MaterialPageRoute(builder: (context) => LoginPage()),);
        }
        
        // Do something with change
        //getUserLocation();
        //getAdminLocation();
        latitude_admin = double.parse(querySnapshot.data['latitude_admin']);
        longitude_admin = double.parse(querySnapshot.data['longitude_admin']);
        latitude_user = double.parse(querySnapshot.data['latitude']);
        longitude_user = double.parse(querySnapshot.data['longitude']);
        nombreAdmin = querySnapshot.data['name_admin'];
       if(latitude_admin!=0.00 && longitude_admin!=0.00){
        setMarker();
        _setPolygons();
       }
        
        
      
    });
}
_syncLocation() async {
     var id = await _getinidenceId();
    id = id.toString();
   var lat_user = await _getUserLatitude();
    lat_user = lat_user.toString();
    var lon_user = await _getUserLongitude();
    lon_user = lon_user.toString();
    var lat_admin = await _getAdminLatitude();
    lat_admin = lat_admin.toString();
    var lon_admin = await _getAdminLongitude();
    lon_admin = lon_admin.toString();
    
    
    DocumentReference reference = Firestore.instance.collection('Incidencias').document(id);
    
    reference.snapshots().listen((querySnapshot) {
      
    });
}
  //Empezar Contador
  startTimer() async{
      if (timer!=null){
        timer.cancel();
      }
      const refreshTime = const Duration(seconds: 2);
      timer = new Timer.periodic(
        refreshTime,(timer){
          getLocation();
          
          
        }
      );
  }
     //obtener el user
  getUserId() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var uid = prefs.getString("user");
  return uid ;
  }
  //obtener nombre de la Usuaria
  getUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("user");
      Database.getUserName(id).then((user){
        nombreUser = prefs.getString("adminName");
      });
          
  }
  _getUserLatitude() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("lat_user");
  }
  _getUserLongitude() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("lon_user");
  }
  _getAdminLatitude()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("lat_admin");
  }
  _getAdminLongitude() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("lon_admin");
  }

  //Obtener la Duración de la incidencia
  getCounter() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String incidenceData = prefs.getString("IncidentData");
    
    var date = DateTime.parse(incidenceData);
    var now = new DateTime.now();
  
    setState(() {
      finalDate = now.difference(date).inSeconds;
    });
  }
 
  //Crear el pin en googleMaps
  setMarker(){
     markers[markerId] = new Marker(

                      
                      markerId: markerId,
                      
                      position: LatLng(
                        latitude_admin,longitude_admin
                      ),
                      infoWindow: InfoWindow(title: nombreAdmin, snippet: "aquesta es la posició de la responsable del punt lila"),
                      onTap: ()=>{},
                     
                      
                    );
  }
  

  //Obtener la fecha de la incidencia
  getIncidenceDate(){
   Database.getIncidenceDate();
  }
  //obtener localización actual, guardarla en la bd y mostrar el nuevo mapa
  Future getLocation() async{
    var l = await location.getLocation();

    //save location in database
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uid = prefs.get("user");
    setState(() {
      incidenceId = prefs.get("incidenceId");
      latitude_user = l.latitude;
      longitude_user = l.longitude;
      //Database.createMessage("Inici Sessió", "automatic");
    });
    Database.setLocation(l.latitude, l.longitude, uid); 
    Database.setIncidenceLocationUser(l.latitude,l.longitude,incidenceId);
    
   // getUserLocation(incidenceId);
    
    }//end GetLocation

//Obtener la localizacion desde la incidencia
getUserLocation()  async { 
 await  Database.getIncidenceLocationAdmin();  
}
    
//Obtener la localizacion del admin desde la incidencia
  Future getAdminLocation()  async {
    await Database.getLocationData(); 
  }
 
Widget _buildListItem(BuildContext context,DocumentSnapshot document){
         return Row(
            
             children: [
                       new Expanded(child: Column(
                          children: <Widget>[
                                  Expanded(
                                    child: GoogleMap(
                                  
                                    initialCameraPosition: CameraPosition(target: LatLng( double.parse(document['latitude']) ,double.parse(document['longitude'])), zoom: 15),
                                    compassEnabled: false,
                                    onMapCreated: _onMapCreated,
                                    myLocationEnabled: true, // Add little blue dot for device location, requires permission from user
                                    mapType: MapType.normal, 
                                    
                                    markers:  Set<Marker>.of(markers.values),
                                    polylines: Set<Polyline>.of(polygons),
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
                                  telefon,
                                  new IconButton(icon:Icon(Icons.chat),color: Colors.purple,iconSize: 60.0,onPressed: (){
                                    Navigator.push(context,MaterialPageRoute(builder: (context) => chatPage()),);
                                  }
                                  ,),
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
        ),
        body: StreamBuilder(
                stream: Firestore.instance.collection('Incidencias').where("unique_id",isEqualTo: incidenceId).snapshots() ,
                 builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                     
                    if (!snapshot.hasData) return new Center(child: CircularProgressIndicator(), ) ;
                    
                    return new ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemExtent: 500.00,
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
final telefon = 
   new
   IconButton(icon:Icon(Icons.phone),color: Colors.purple,iconSize: 60.0, onPressed:()=> launch("tel://695745855"),);
  
  final chat = new IconButton(icon:Icon(Icons.chat),color: Colors.purple,iconSize: 60.0,onPressed: (){
    
   }
  ,);
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