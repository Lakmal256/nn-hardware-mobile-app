import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../localizations.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  final CameraPosition _kGooglePlex =
      const CameraPosition(target: LatLng(6.927079, 79.861244), zoom: 14.4746);

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  var addressTextController = TextEditingController();

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  Future<void> getCurrentLocation() async {
    var position = await _getCurrentPosition();
    LatLng latLng = LatLng(position.latitude, position.longitude);
    await updateLocation(latLng, _controller);
  }

  Future<Placemark?> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      return placemarks.isNotEmpty ? placemarks[0] : null;
    } catch (e) {
      // Handle the error or rethrow it
      debugPrint('Error getting address: $e');
      return null; // or throw an exception if needed
    }
  }

  Future<Position> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      // Handle the error or rethrow it
      throw Exception('Failed to get current position: $e');
    }
  }

  Future<void> updateLocation(
      LatLng position, Completer<GoogleMapController> _controller) async {
    var placeMark = await _getAddressFromLatLng(position);
    var latLng = LatLng(position.latitude, position.longitude);
    final Marker marker = Marker(
      markerId: MarkerId(AppLocalizations.of(context)!.nN_058),
      // markerId: const MarkerId('Me'),
      position: latLng,
      infoWindow: InfoWindow(title: AppLocalizations.of(context)!.nN_058, snippet: '*'),
    );
    setState(() {
      markers[marker.markerId] = marker; // Update the marker in the map
      addressTextController.text = '${placeMark!.name},${placeMark.locality}';
    });

    _controller.future.then((controller) => controller
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                target: LatLng(latLng.latitude, latLng.longitude), zoom: 15)))
            .then((_) async {
          controller = controller;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          Text(
              AppLocalizations.of(context)!.nN_059,
              // "Mark Your Location",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: GoogleMap(
                  myLocationEnabled: true,
                  initialCameraPosition: _kGooglePlex,
                  mapType: MapType.terrain,
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                  },
                  onTap: (latlang) {
                    updateLocation(latlang, _controller);
                  },
                  markers: Set<Marker>.of(markers.values)),
            ),
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: addressTextController,
            keyboardType: TextInputType.phone,
            autocorrect: false,
            decoration: InputDecoration(
              isDense: true,
              enabled: false,
              fillColor: Colors.black.withOpacity(0.1),
              filled: true,
              hintText: AppLocalizations.of(context)!.nN_060,
              // hintText: "Address",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        const Color.fromARGB(255, 151, 96, 96).withOpacity(0.1),
                    width: 0,
                  )),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 0,
                  )),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 0,
                  )),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.nN_061),
                // child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, addressTextController.text),
                child: Text(AppLocalizations.of(context)!.nN_062),
                // child: const Text('Save'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
