import 'package:flutter/material.dart';
import 'dart:async';

/*import para los permisos */
import 'package:permission_handler/permission_handler.dart';

/*import de google maps */
import 'package:google_maps_flutter/google_maps_flutter.dart';

/*import para la localizacion */
import 'package:geolocator/geolocator.dart';

/*import para ejecutar en segundo plano */
import 'package:workmanager/workmanager.dart';

/*import para enrutamiento */
import 'package:googlemapsflutter/routing/directions_repository.dart';
import 'package:googlemapsflutter/routing/direction_models.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:googlemapsflutter/routing/.env.dart';

/*import para notificaciones */
import 'package:firebase_core/firebase_core.dart';
import 'package:googlemapsflutter/notifications/apihelper.dart';
import 'package:googlemapsflutter/notifications/local_notification.dart';

class MapsDemo extends StatefulWidget{
  MapsDemo():super();
  final String title="Demo Google Maps";
  @override
  MapsDemoState createState()=>MapsDemoState();
}

/*funcion para el background */
void callbackDispatcher() {
  Workmanager.executeTask((taskName, inputData) async {
    //show the notification
    await Firebase.initializeApp();
    ApiHelper().save(inputData);
    LocalNotification.initializer();
    LocalNotification.showOneTimeNotification(DateTime.now());
    return Future.value(true);
  });
}

class MapsDemoState extends State<MapsDemo>{
/*enrutamiento */
Directions _info;
PolylinePoints polylinePoints = PolylinePoints();
Map<PolylineId, Polyline> polylines = {};
  _traceRoute(LatLng pos)async{
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      PointLatLng(pos.latitude, pos.longitude),
      PointLatLng(_currentLocation.latitude, _currentLocation.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    _addPolyLine(polylineCoordinates);
  }
  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

/*Localizacion*/
LatLng _currentLocation;
  _locatePosition()async{
    Position position=await Geolocator.getCurrentPosition(desiredAccuracy:LocationAccuracy.high,forceAndroidLocationManager: true);
    _currentLocation=LatLng(position.latitude, position.longitude);
  }

/*mapa */
//Completer<GoogleMapController>_controller=Completer();
final Set <Marker> _markers={};
MapType _currentMapType=MapType.normal;

  @override
  Widget build(BuildContext contex){
    _locatePosition();
    _setPermissions();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.blue,
        ),
        body: Stack(
          children: <Widget>[          
            GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
//DIBUJADO DE LA RUTA-----------------------------------------------------------------
              polylines: /*Set<Polyline>.of(polylines.values),*/{
                if (_info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.red,
                  width: 5,
                  points: _info.polylinePoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
              },
//-------------------------------------------------------------------------------------
              initialCameraPosition: CameraPosition(
                target: LatLng(10,10),
                zoom: 11.0),
              onMapCreated: (GoogleMapController controller){
                  _locatePosition();
                  controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _currentLocation,zoom: 9.0)));
                },
              onLongPress: _addMarkerOnMap,  
              mapType: _currentMapType,
              markers: _markers,
              onCameraMove: _onCameraMove
            ),
// DISPLAY DE LA INFO DE ENRUTAMIENTO--------------------------------------------------
            if (_info != null)
              Positioned(
                top: 20.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      )
                    ],
                  ),
                  child: Text(
                    '${_info.totalDistance}, ${_info.totalDuration}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
//-----------------------------------------------------------------------------------
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 50.0,),
                    button(_onMapTypeButtonPressed, Icons.map),
                    SizedBox(height: 16.0,),
                    button(_onAddMarkerButtonPressed, Icons.add_location)
                  ],
                ),
              ),
            )
          ]
        ),
      ),
    );
  }

  _addMarkerOnMap(LatLng pos)async{
    setState(() {
      _markers.add(
        Marker(
          markerId:MarkerId(pos.toString()),
          position: pos,
          infoWindow:InfoWindow(
            title: 'Destino',
            snippet: 'esta es la ubicacion a la que quieres ir'
          ),
          icon: BitmapDescriptor.defaultMarker
        )
      );      
    });

    //obtener direcciones
    _setPermissions();
    final directions=await DirectionsRepository().getDirections(origin: _currentLocation, destination: pos);
    setState(() {
    _info=directions;
    });
    print(_info==null);//esto es true

    _traceRoute(pos);
  }

  _setPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [Permission.location].request();
  }   

  _onCameraMove(CameraPosition position){
    _currentLocation=position.target;
  }  

  Widget button(Function function,IconData icon){
    _setPermissions();
    return FloatingActionButton(
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        size: 36.0,)
    );
  }

  _onMapTypeButtonPressed(){
    setState(() {
      _currentMapType=_currentMapType==MapType.normal
      ?MapType.satellite
      :MapType.normal;
    });
  }

  _onAddMarkerButtonPressed(){
    setState(() {
      _markers.add(
        Marker(
          markerId:MarkerId(_currentLocation.toString()),
          position: _currentLocation,
          infoWindow:InfoWindow(
            title: 'ubicacion',
            snippet: 'esta es una ubicacion'
          ),
          icon: BitmapDescriptor.defaultMarker
        )
      );      
    });
  }
}