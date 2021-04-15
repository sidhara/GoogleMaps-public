import 'package:flutter/material.dart';
import 'dart:async';

/*import para los permisos */
import 'package:permission_handler/permission_handler.dart';

/*import de google maps */
import 'package:google_maps_flutter/google_maps_flutter.dart';

/*import para la localizacion */
import 'package:geolocator/geolocator.dart';

class MapsDemo extends StatefulWidget{
  MapsDemo():super();
  final String title="Demo Google Maps";
  @override
  MapsDemoState createState()=>MapsDemoState();
}

class MapsDemoState extends State<MapsDemo>{

/*Localizacion*/
LatLng _currentLocation;
  _locatePosition()async{
    Position position=await Geolocator.getCurrentPosition(desiredAccuracy:LocationAccuracy.high,forceAndroidLocationManager: true);
    _currentLocation=LatLng(position.latitude, position.longitude);
  }

/*mapa */
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