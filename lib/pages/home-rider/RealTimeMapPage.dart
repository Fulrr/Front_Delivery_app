import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:delivery_app/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RealTimeMapPage extends StatefulWidget {
  final String orderId;
  const RealTimeMapPage({Key? key, required this.orderId}) : super(key: key);

  @override
  _RealTimeMapPageState createState() => _RealTimeMapPageState();
}

class _RealTimeMapPageState extends State<RealTimeMapPage>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  LatLng _currentPosition = LatLng(0, 0);
  bool _isDelivered = false;
  bool _hasPickedUp = false;
  List<File> _images = [];
  String? userId;
  bool _mapReady = false;
  Timer? _locationUpdateTimer;
  bool _isFollowingUser = true;

  // เพิ่มตัวแปรเก็บพิกัด
  LatLng? _pickupLocation;
  LatLng? _deliveryLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLocation();
    _getUserId();
  }

  // เพิ่มฟังก์ชันโหลดพิกัดจุดรับ-ส่ง
  Future<void> _loadOrderLocations() async {
    try {
      final response = await http.get(
        Uri.parse('${getOrderLocations}/${widget.orderId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _pickupLocation =
              LatLng(data['pickup']['latitude'], data['pickup']['longitude']);
          _deliveryLocation = LatLng(
              data['delivery']['latitude'], data['delivery']['longitude']);
        });
      }
    } catch (e) {
      _showErrorDialog("ไม่สามารถโหลดข้อมูลพิกัดได้");
    }
  }

  void _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) return;
      }

      // var userLocation = await _location.getLocation();
      // setState(() {
      //   _currentPosition =
      //       LatLng(userLocation.latitude!, userLocation.longitude!);
      //   _mapReady = true;
      // });
      // ตั้งค่าพิกัด rider ให้อยู่ที่มหาวิทยาลัยมหาสารคาม
      setState(() {
        _currentPosition =
            LatLng(16.2459, 103.2502); // พิกัดมหาวิทยาลัยมหาสารคาม
        _mapReady = true;
      });

      _startLocationUpdates();
      _startPeriodicUpdates();
    } catch (e) {
      _showErrorDialog("ไม่สามารถเข้าถึงตำแหน่งได้");
    }
  }

  void _startLocationUpdates() {
    _locationSubscription = _location.onLocationChanged.listen(
      (LocationData currentLocation) {
        setState(() {
          _currentPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
        if (_isFollowingUser) {
          _mapController.move(_currentPosition, _mapController.camera.zoom);
        }
      },
    );
  }

  void _startPeriodicUpdates() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (_) {
      _updateLocationOnServer();
    });
  }

  Future<void> _updateLocationOnServer() async {
    try {
      await http.post(
        Uri.parse('${updateLocation}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'userId': userId,
          'latitude': _currentPosition.latitude,
          'longitude': _currentPosition.longitude,
          'orderId': widget.orderId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      print("Location update error: $e");
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _images.add(File(image.path));
        });
      }
    } catch (e) {
      _showErrorDialog("ไม่สามารถถ่ายรูปได้");
    }
  }

  Future<void> _uploadImages() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${uploadDeliveryImages}/${widget.orderId}/images'),
      );

      request.fields['userId'] = userId ?? '';
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      request.fields['location'] =
          '${_currentPosition.latitude},${_currentPosition.longitude}';

      for (var image in _images) {
        request.files
            .add(await http.MultipartFile.fromPath('images', image.path));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        setState(() => _images.clear());
      }
    } catch (e) {
      _showErrorDialog("ไม่สามารถอัพโหลดรูปภาพได้");
    }
  }

  // ฟังก์ชันตรวจสอบระยะห่าง
  Future<bool> _validateDistance(LatLng? targetLocation) async {
    if (targetLocation == null) {
      _showErrorDialog("ไม่พบข้อมูลพิกัด");
      return false;
    }

    final distance =
        Distance().as(LengthUnit.Meter, _currentPosition, targetLocation);

    if (distance > 20) {
      _showErrorDialog(
          "กรุณาเข้าใกล้จุดหมายมากกว่านี้ (ระยะห่างไม่เกิน 20 เมตร)\n"
          "ระยะห่างปัจจุบัน: ${distance.toStringAsFixed(1)} เมตร");
      return false;
    }

    return true;
  }

  // ฟังก์ชันยืนยันการส่งสินค้า
  void _completeDelivery() async {
    try {
      // ตรวจสอบระยะห่างจากจุดส่งสินค้า
      if (!await _validateDistance(_deliveryLocation)) {
        return;
      }

      await _takePhoto();
      if (_images.isNotEmpty) {
        await _uploadImages();
        final response = await http.post(
          Uri.parse('${completeDelivery}/${widget.orderId}/complete'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'riderId': userId,
            'deliveryTime': DateTime.now().toIso8601String(),
            'location': {
              'latitude': _currentPosition.latitude,
              'longitude': _currentPosition.longitude,
            },
          }),
        );

        if (response.statusCode == 200) {
          setState(() => _isDelivered = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('การส่งสินค้าเสร็จสมบูรณ์'),
                backgroundColor: Colors.green),
          );
          await Future.delayed(Duration(seconds: 2));
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      _showErrorDialog("เกิดข้อผิดพลาดในการส่งสินค้า");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("แจ้งเตือน"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ตกลง"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('ติดตามการจัดส่ง'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: _mapReady
            ? _buildMap()
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition,
            initialZoom: 16.0,
            minZoom: 5,
            maxZoom: 18,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) setState(() => _isFollowingUser = false);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.delivery_app',
            ),
            MarkerLayer(
              markers: [
                // ตำแหน่งไรเดอร์
                Marker(
                  point: _currentPosition,
                  width: 80,
                  height: 80,
                  child:
                      Icon(Icons.delivery_dining, color: Colors.blue, size: 40),
                ),
                // จุดรับสินค้า
                if (_pickupLocation != null && !_hasPickedUp)
                  Marker(
                    point: _pickupLocation!,
                    width: 80,
                    height: 80,
                    child: Icon(Icons.store, color: Colors.green, size: 40),
                  ),
                // จุดส่งสินค้า
                if (_deliveryLocation != null && _hasPickedUp && !_isDelivered)
                  Marker(
                    point: _deliveryLocation!,
                    width: 80,
                    height: 80,
                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
              ],
            ),
          ],
        ),
        if (!_isFollowingUser) _buildRecenterButton(),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildRecenterButton() {
    return Positioned(
      right: 16,
      bottom: 120,
      child: FloatingActionButton(
        mini: true,
        onPressed: () {
          setState(() {
            _isFollowingUser = true;
            _mapController.move(_currentPosition, 16.0);
          });
        },
        child: Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          if (!_hasPickedUp)
            ElevatedButton(
              onPressed: _confirmPickup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text('ยืนยันการรับสินค้า', style: TextStyle(fontSize: 18)),
            ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isDelivered ? null : _completeDelivery,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: 16),
              minimumSize: Size(double.infinity, 48),
            ),
            child: Text(
              _isDelivered ? 'ส่งสินค้าเสร็จสิ้น' : 'ยืนยันการส่งสินค้า',
              style: TextStyle(fontSize: 18),
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
    _locationUpdateTimer?.cancel();
    _mapController.dispose();
    for (var image in _images) {
      try {
        image.deleteSync();
      } catch (e) {
        print("Error deleting temporary image: $e");
      }
    }
    super.dispose();
  }

  // ฟังก์ชันยืนยันการรับสินค้า
  void _confirmPickup() async {
    try {
      // ตรวจสอบระยะห่างจากจุดรับสินค้า
      if (!await _validateDistance(_pickupLocation)) {
        _showErrorDialog("คุณอยู่ห่างจากจุดรับสินค้ามากเกินไป");
        return;
      }

      await _takePhoto();
      if (_images.isEmpty) {
        _showErrorDialog("กรุณาถ่ายรูปสินค้า");
        return;
      }

      // อัพโหลดรูปภาพ
      await _uploadImages();

      // อัพเดทสถานะ
      final response = await http.put(
        Uri.parse('${updateOrderStatus}/${widget.orderId}/status'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'status': 'shipped',
          'riderId': userId,
          'pickupTime': DateTime.now().toIso8601String(),
          'location': {
            'latitude': _currentPosition.latitude,
            'longitude': _currentPosition.longitude,
          },
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _hasPickedUp = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('รับสินค้าเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('ไม่สามารถอัพเดทสถานะได้');
      }
    } catch (e) {
      _showErrorDialog("เกิดข้อผิดพลาด กรุณาลองใหม่");
    }
  }
}
