
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission/permission.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}
  
class _GoogleMapScreenState extends State<GoogleMapScreen> {
   PermissionName permissionName = PermissionName.Location;
 Set<Marker> _markers = {};
 void _onMapCreated(GoogleMapController controller){
   setState(() {
        _markers.add(
        
    
           
          Marker(markerId: MarkerId('id-1'), position: LatLng(22.5448131, 88.3403691), 
          ),
        );
      });
 }
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map'),
      ),
      body: GoogleMap
      (
        onMapCreated: _onMapCreated,
        markers: _markers,
        
         initialCameraPosition: CameraPosition(
           
           target: LatLng(22.5448131, 88.3403691),
           zoom: 15,
           
           ),
      ),
    );
  }
}