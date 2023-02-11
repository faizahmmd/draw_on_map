library draw_on_map;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatefulWidget {
  final double? minZoom, maxZoom;
  final double zoom, strokeWidth, borderStrokeWidth;
  final Color polylineColor, borderColor;
  final LatLng? center;
  final LatLng currentUserLocation;
  final List<Marker>? markers;
  final Positioned? polylineResetWidget, currentLocationFocusWidget;
  final ValueChanged drawnRouteLatLngList;
  final bool isDotted;
  const MapWidget({Key? key, this.minZoom, this.maxZoom, required this.zoom, this.center, this.markers, required this.polylineResetWidget, required this.drawnRouteLatLngList, required this.strokeWidth, required this.polylineColor, required this.borderStrokeWidth, required this.borderColor, required this.isDotted, this.currentLocationFocusWidget, required this.currentUserLocation}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  List<LatLng> polylineLatLngList = [];
  bool startDrawing = false;
  MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
            mapController: mapController,
            options: MapOptions(
                zoom: widget.zoom,
                minZoom: widget.minZoom,
                maxZoom: widget.maxZoom,
                center: widget.center,
                onTap: (tapPosition, latLng){
                  setState(() {
                    startDrawing = !startDrawing;
                  });
                },
                onPointerHover: (pointerHoverEvent, latLng){
                  if(startDrawing){
                    widget.drawnRouteLatLngList(polylineLatLngList);
                    setState(() {
                      polylineLatLngList.add
                        (LatLng(latLng.latitude, latLng.longitude))
                      ;
                    });
                  }

                }
            ),
            children: [
              TileLayer(
                minZoom: 1,
                maxZoom: 18,
                backgroundColor: Colors.white,
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: widget.markers??[]),
              PolylineLayer(polylines: [Polyline(
                  strokeWidth: widget.strokeWidth,
                  color: widget.polylineColor,
                  borderStrokeWidth: widget.borderStrokeWidth,
                  borderColor: widget.borderColor,
                  isDotted: widget.isDotted,
                  points: polylineLatLngList)])
            ]
        ),
        GestureDetector(
            onTap: (){
              setState(() {
                polylineLatLngList.clear();
              });
            },
            child: widget.polylineResetWidget),
        GestureDetector(
            onTap: (){
             mapController.move(widget.currentUserLocation, widget.zoom);
            },
            child: widget.currentLocationFocusWidget)
      ],
    );
  }
}