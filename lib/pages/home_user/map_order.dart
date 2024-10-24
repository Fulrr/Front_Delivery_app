import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class mapOrder extends StatefulWidget {
  final Map<String, dynamic> order;

  const mapOrder({super.key, required this.order});

  @override
  State<mapOrder> createState() => _mapOrderState();
}

class _mapOrderState extends State<mapOrder> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  LatLng _currentPosition = LatLng(16.246671218679253, 103.25207957788868);
  bool _mapReady = false;
  bool _isFollowingUser = true;
  Timer? _riderLocationTimer;
  LatLng? _riderLocation;
  bool isExpanded = false;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLocation();
    _startRiderLocationTracking();
    _loadRoute();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _showErrorDialog("Location services are not enabled");
          return;
        }
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          _showErrorDialog("Location permission is required");
          return;
        }
      }

      LocationData currentLocation = await _location.getLocation();
      setState(() {
        _currentPosition = LatLng(
          currentLocation.latitude ?? 16.246671218679253,
          currentLocation.longitude ?? 113.25207957788868,
        );
        _mapReady = true;
      });

      _startLocationUpdates();
    } catch (e) {
      print('Location initialization error: $e');
      _showErrorDialog("Could not access location");
    }
  }

  void _startLocationUpdates() {
    _locationSubscription = _location.onLocationChanged.listen(
      (LocationData currentLocation) {
        setState(() {
          _currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
        if (_isFollowingUser) {
          _mapController.move(_currentPosition, _mapController.camera.zoom);
        }
      },
    );
  }

  void _startRiderLocationTracking() {
    _riderLocationTimer?.cancel();
    _riderLocationTimer = Timer.periodic(Duration(seconds: 10), (_) {
      _fetchRiderLocation();
    });
    _fetchRiderLocation();
  }

  Future<void> _fetchRiderLocation() async {
    // Simulated rider location for demo - replace with actual API call
    setState(() {
      _riderLocation = LatLng(
        16.246671218679253 + (DateTime.now().millisecond / 10000),
        103.25207957788868 + (DateTime.now().millisecond / 10000),
      );
    });
  }

  Future<void> _loadRoute() async {
    // Replace with your actual API endpoint and parameters
    final response = await http.get(
      Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?start=103.252,16.2466083&end=103.252185,16.2466083'),
      headers: {
        'Authorization':
            'YOUR_API_KEY', // Add your OpenRouteService API Key here
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<LatLng> points = [];
      for (var point in data['features'][0]['geometry']['coordinates']) {
        points.add(LatLng(point[1], point[0]));
      }
      setState(() {
        _routePoints = points;
      });
    } else {
      print('Failed to load route: ${response.statusCode}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Notice"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Lunch Delivery Tracking',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _mapReady ? _buildMap() : Center(child: CircularProgressIndicator()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildOrderDetails(widget.order),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition, // ใช้ initialCenter แทน center
        initialZoom: 16.0, // ใช้ initialZoom แทน zoom
        minZoom: 5,
        maxZoom: 18,
        onPositionChanged: (position, hasGesture) {
          if (hasGesture) setState(() => _isFollowingUser = false);
        },
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            if (_riderLocation != null)
              Marker(
                point: _riderLocation!,
                width: 80,
                height: 80,
                child:
                    Icon(Icons.delivery_dining, color: Colors.blue, size: 40),
              ),
            Marker(
              point: LatLng(
                  16.246671218679253, 103.25207957788868), // ตำแหน่งร้านค้า
              width: 80,
              height: 80,
              child: Icon(Icons.store, color: Colors.green, size: 40),
            ),
            Marker(
              point: _currentPosition, // ตำแหน่งผู้ใช้
              width: 80,
              height: 80,
              child: Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [
                _currentPosition,
                LatLng(
                    16.246671218679253, 103.25207957788868), // ตำแหน่งร้านค้า
              ],
              strokeWidth: 4.0,
              color: Colors.red,
            ),
            Polyline(
              points: _routePoints, // เพิ่มพอยต์ของเส้นทางไรเดอร์
              strokeWidth: 4.0,
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderDetails(Map<String, dynamic> order) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ปุ่มเพื่อแสดงตำแหน่งปัจจุบันของผู้ใช้
        ElevatedButton(
          onPressed: () {
            if (_currentPosition != null) {
              _mapController.move(_currentPosition, 16.0); // เปลี่ยนมุมมองไปที่ตำแหน่งปัจจุบันของผู้ใช้
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('แสดงตำแหน่งของฉัน'),
        ),
        // เนื้อหาอื่น ๆ ของ order details
        InkWell(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Uttora Coffee House',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ordered At 06 Sept, 10:00pm',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const Divider(),
          _buildExpandedDetails(order),
        ] else ...[
          const SizedBox(height: 8),
          ...(order['items'] as List)
              .map<Widget>((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${item['quantity']}x ${item['name']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ))
              .toList(),
        ],
      ],
    ),
  );
}


  Widget _buildExpandedDetails(Map<String, dynamic> order) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Order Details',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 12),
      ...(order['items'] as List).map<Widget>(
        (item) => _buildOrderItem(item['name'], item['quantity'], item['price']),
      ),
      const SizedBox(height: 20),
      const Text(
        'Delivery Details',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 12),
      _buildDeliveryDetail('Name', order['recipient']['name'] ?? 'N/A'),
      _buildDeliveryDetail('Phone', order['recipient']['phone'] ?? 'N/A'),
      _buildDeliveryDetail('Address', order['recipient']['address'] ?? 'N/A'),
      const SizedBox(height: 16),

      // เพิ่มข้อมูลไรเดอร์
      const Text(
        'Rider Details',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 12),
      _buildDeliveryDetail('Rider ID', order['rider'] ?? 'รอไรเดอร์รับ'),
      // คุณสามารถแทนที่ด้วยชื่อและเบอร์โทรถ้ามี
    ],
  );
}


  Widget _buildOrderItem(String name, int quantity, dynamic price) {
    double priceAsDouble = price is int ? price.toDouble() : price;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$quantity x $name',
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            '\$${(quantity * priceAsDouble).toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    _riderLocationTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }
}