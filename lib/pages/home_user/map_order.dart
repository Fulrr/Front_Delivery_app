import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapOrder extends StatefulWidget {
  final Map<String, dynamic> order;

  const MapOrder({super.key, required this.order});

  @override
  State<MapOrder> createState() => _MapOrderState();
}

class _MapOrderState extends State<MapOrder> with WidgetsBindingObserver {
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
  double _estimatedTime = 15; // Estimated delivery time in minutes
  String _deliveryStatus = 'Preparing Order';

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
          currentLocation.longitude ?? 103.25207957788868,
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
    _riderLocationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
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
      // Update estimated time and status based on rider location
      _estimatedTime = 15 - (DateTime.now().minute % 15);
      if (_estimatedTime < 5) {
        _deliveryStatus = 'Arriving Soon';
      } else if (_estimatedTime < 10) {
        _deliveryStatus = 'On The Way';
      }
    });
  }

  Future<void> _loadRoute() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openrouteservice.org/v2/directions/driving-car?start=103.252,16.2466083&end=103.252185,16.2466083'),
        headers: {
          'Authorization': 'YOUR_API_KEY',
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
      }
    } catch (e) {
      print('Route loading error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notice"),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _mapReady
              ? _buildMap()
              : const Center(child: CircularProgressIndicator()),
          _buildTopBar(),
          _buildDeliveryStatus(),
          Positioned(
            left: 16,
            bottom: 200,
            child: _buildMapControls(),
          ),
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

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: Text(
                  'Order Tracking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryStatus() {
    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.delivery_dining, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _deliveryStatus,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Estimated arrival in $_estimatedTime minutes',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              setState(() => _isFollowingUser = true);
              _mapController.move(_currentPosition, 16.0);
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: IconButton(
            icon: Icon(
              Icons.navigation,
              color: _isFollowingUser ? Colors.blue : Colors.grey,
            ),
            onPressed: () {
              setState(() => _isFollowingUser = !_isFollowingUser);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition,
        initialZoom: 16.0,
        minZoom: 5,
        maxZoom: 18,
        onPositionChanged: (position, hasGesture) {
          if (hasGesture) setState(() => _isFollowingUser = false);
        },
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: _routePoints,
              strokeWidth: 4.0,
              color: Colors.blue.withOpacity(0.7),
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            if (_riderLocation != null)
              Marker(
                point: _riderLocation!,
                width: 50,
                height: 50,
                child: _buildMarkerIcon(
                  Icons.delivery_dining,
                  Colors.blue,
                  'Rider',
                ),
              ),
            Marker(
              point: LatLng(16.246671218679253, 103.25207957788868),
              width: 50,
              height: 50,
              child: _buildMarkerIcon(
                Icons.store,
                Colors.green,
                'Store',
              ),
            ),
            Marker(
              point: _currentPosition,
              width: 50,
              height: 50,
              child: _buildMarkerIcon(
                Icons.location_on,
                Colors.red,
                'You',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarkerIcon(IconData icon, Color color, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(Map<String, dynamic> order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order),
                if (isExpanded) ...[
                  const Divider(height: 24),
                  _buildExpandedDetails(order),
                ] else
                  _buildCollapsedDetails(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(Map<String, dynamic> order) {
    return InkWell(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/60'),
                fit: BoxFit.cover,
              ),
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
                  'Order #${order['id'] ?? 'N/A'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedDetails(Map<String, dynamic> order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Order Items',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...(order['items'] as List).map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item['quantity']}x',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['name'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildExpandedDetails(Map<String, dynamic> order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Order Items'),
        const SizedBox(height: 12),
        ...(order['items'] as List).map((item) => _buildOrderItem(
              item['name'],
              item['quantity'],
              item['price'],
            )),
        const Divider(height: 32),
        _buildSectionHeader('Order Summary'),
        const SizedBox(height: 12),
        _buildSummaryItem('Subtotal', calculateSubtotal(order)),
        _buildSummaryItem('Delivery Fee', 2.99),
        _buildSummaryItem('Total', calculateTotal(order)),
        const Divider(height: 32),
        _buildSectionHeader('Delivery Details'),
        const SizedBox(height: 12),
        _buildDeliveryDetail('Name', order['recipient']['name'] ?? 'N/A'),
        _buildDeliveryDetail('Phone', order['recipient']['phone'] ?? 'N/A'),
        _buildDeliveryDetail('Address', order['recipient']['address'] ?? 'N/A'),
        const Divider(height: 32),
        _buildSectionHeader('Rider Details'),
        const SizedBox(height: 12),
        _buildRiderDetails(order),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildOrderItem(String name, int quantity, dynamic price) {
    double priceAsDouble = price is int ? price.toDouble() : price;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${quantity}x',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14),
            ),
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

  Widget _buildSummaryItem(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  label == 'Total' ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  label == 'Total' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  double calculateSubtotal(Map<String, dynamic> order) {
    return (order['items'] as List).fold(0.0, (total, item) {
      double price =
          item['price'] is int ? item['price'].toDouble() : item['price'];
      return total + (price * item['quantity']);
    });
  }

  double calculateTotal(Map<String, dynamic> order) {
    return calculateSubtotal(order) + 2.99; // Adding delivery fee
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
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiderDetails(Map<String, dynamic> order) {
    final hasRider = order['rider'] != null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delivery_dining,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasRider ? 'Rider Name' : 'Waiting for rider',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (hasRider)
                  Text(
                    'ID: ${order['rider']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
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
