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
  
void main() => runApp(RealTimeLocationAdmin());


class RealTimeLocationAdmin extends StatelessWidget {

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
  String close = "";
  var finalDate;
  String incidenceId = "";
  SharedPreferences prefs ;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId markerId = new MarkerId("prueba");
  var markerIcon;
  final Database _database = Database();
  
  @override   
  initState() {
    super.initState();
    //carga las prefs
    getUser();
    getLocation();
   getUserLocation() ;
   // getUserPrefLocation();
  
 
    var thread = new Thread(() async{
        prefs = await SharedPreferences.getInstance();
        Database.getIncidenceState();
        var open = prefs.get("state");
        if(open == "true"){
          startTimer();
        }else{
          finalDate = prefs.get("IncidentDate");
        }
      
        
    });
   thread.start();
    
  }//End init State

  //Empezar Contador
  startTimer() async{
      if (timer!=null){
        timer.cancel();
      }
      const refreshTime = const Duration(seconds: 2);
      timer = new Timer.periodic(
        refreshTime,(timer){
          getLocation();
          getCounter();
          
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
        nombreUser = prefs.getString("UserName");
      });
          
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
                        latitude_user,longitude_user
                      ),
                      infoWindow: InfoWindow(title: nombreUser, snippet: "aquesta es la posició de la usuaria amb l'incidencia"),
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
     
          latitude = l.latitude;
          longitude = l.longitude;
      
  
   
    
    //save location in database
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uid = prefs.get("user");
    setState(() {
      incidenceId = prefs.get("incidenceId");
    });
    
    
    Database.setLocation(latitude, longitude, uid); 
    Database.setIncidenceLocationAdmin(latitude, longitude, incidenceId);
   // getUserLocation(incidenceId);
    
    }//end GetLocation

//Obtener la localizacion desde la incidencia
getUserLocation()  async {
   SharedPreferences prefs = await SharedPreferences.getInstance(); 
    Database.getIncidenceLocationUser().then((user){
     
         setState(() {
        latitude_user =  double.parse(prefs.get("lat_user"));
        longitude_user = double.parse(prefs.get("lon_user"));
        setMarker();
    });
    });
    
   
  }
getUserPrefLocation()async{
   
  
}

//Obtener la localizacion del admin desde la incidencia
  Future getAdminLocation(user)  async {
    
    Database.getLocationData(); 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      latitude =  prefs.getInt("lat_admin").toDouble();
      longitude = prefs.getInt("lon_admin").toDouble();
    });
  }
 
Widget _buildListItem(BuildContext context,DocumentSnapshot document){
         return Row(
            
             children: [
                       new Expanded(child: Column(
                          children: <Widget>[
                                  Expanded(
                                    child: GoogleMap(
                                  
                                    initialCameraPosition: CameraPosition(target: LatLng( double.parse(document['latitude']) ,double.parse(document['longitude'])), zoom: 10),
                                    compassEnabled: false,
                                    onMapCreated: _onMapCreated,
                                    myLocationEnabled: true, // Add little blue dot for device location, requires permission from user
                                    mapType: MapType.normal, 
                                    
                                    markers:  Set<Marker>.of(markers.values),
                                ),
                              ),
                             new Expanded(
                                child: 
                                GridView.count(
                                    crossAxisCount: 2,
                                    childAspectRatio: 3,
                                
                                  // Generate 100 Widgets that display their index in the List
                                  children: [leftSection,middleSection,new Text(document['name']),new Text(document['created']), telefon, new Container(
                
                            child: IconButton(icon:Icon(Icons.chat),color: Colors.purple,iconSize: 40.0,onPressed: (){ Navigator.push(this.context,MaterialPageRoute(builder: (context) => chatPage()),);}
                            ,)
                            ) ],
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
        ),
        body: StreamBuilder(
                stream: Firestore.instance.collection('Incidencias').where("unique_id",isEqualTo: incidenceId).snapshots() ,
                 builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){  
                    if (!snapshot.hasData) return new Text('Loading...');
                    return new ListView.builder(
                      itemExtent: 700.00,
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
final telefon = new Container(
   
  child: IconButton(icon:Icon(Icons.phone),color: Colors.purple,iconSize: 40.0, onPressed:()=> launch("tel://695745855"),)
  );
  final chat = new Container(
 
  child: IconButton(icon:Icon(Icons.chat),color: Colors.purple,iconSize: 40.0,onPressed: (){ }
  ,)
  );
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