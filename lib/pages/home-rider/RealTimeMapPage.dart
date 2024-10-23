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

import 'dart:math';
import 'dart:math' show log, min, max;

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
  String? riderId; // เพิ่มตัวแปรสำหรับเก็บ riderId
  Timer? _riderLocationTimer; // Timer สำหรับเรียก API ดึงตำแหน่งไรเดอร์
  LatLng? _riderLocation; // ตำแหน่งของไรเดอร์

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLocation().then((_) {
      _loadOrderLocations();
      _getRiderId(); // เรียกฟังก์ชันดึง riderId
    });
    _getUserId();
  }

  // เพิ่มฟังก์ชันดึง riderId
  Future<void> _getRiderId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      riderId = prefs.getString('userId');
      if (riderId != null) {
        // เริ่มการติดตามตำแหน่งไรเดอร์
        _startRiderLocationTracking();
      }
    } catch (e) {
      print('Error getting riderId: $e');
    }
  }

  // เพิ่มฟังก์ชันติดตามตำแหน่งไรเดอร์
  void _startRiderLocationTracking() {
    // ยกเลิก Timer เดิมถ้ามีอยู่
    _riderLocationTimer?.cancel();

    // สร้าง Timer ใหม่สำหรับเรียก API ทุก 10 วินาที
    _riderLocationTimer = Timer.periodic(Duration(seconds: 10), (_) {
      _fetchRiderLocation();
    });

    // เรียกครั้งแรกทันที
    _fetchRiderLocation();
  }

  // เพิ่มฟังก์ชันดึงตำแหน่งไรเดอร์จาก API
  // เพิ่มฟังก์ชันดึงตำแหน่งไรเดอร์จาก API
  Future<void> _fetchRiderLocation() async {
    if (riderId == null || riderId!.isEmpty) {
      print('Invalid riderId');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${getRiderLocation}/$riderId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null &&
            data['latitude'] != null &&
            data['longitude'] != null) {
          final latitude = double.tryParse(data['latitude'].toString());
          final longitude = double.tryParse(data['longitude'].toString());

          if (latitude != null && longitude != null) {
            setState(() {
              _riderLocation = LatLng(latitude, longitude);
            });
          } else {
            print('Invalid GPS data');
          }
        } else {
          print('Invalid response data');
        }
      } else {
        print('Failed to fetch rider location: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching rider location: $e');
    }
  }

  // เพิ่มฟังก์ชันโหลดพิกัดจุดรับ-ส่ง
  Future<void> _loadOrderLocations() async {
    try {
      final response = await http.get(
        Uri.parse('${getOrderLocations}/${widget.orderId}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validate data structure
        if (data['pickupLocation'] == null ||
            data['deliveryLocation'] == null) {
          throw Exception('Missing location data');
        }

        // Validate coordinates
        final pickupLat = data['pickupLocation']['latitude'];
        final pickupLng = data['pickupLocation']['longitude'];
        final deliveryLat = data['deliveryLocation']['latitude'];
        final deliveryLng = data['deliveryLocation']['longitude'];

        if (pickupLat == null ||
            pickupLng == null ||
            deliveryLat == null ||
            deliveryLng == null) {
          throw Exception('Invalid coordinate data');
        }

        setState(() {
          _pickupLocation = LatLng(
            double.parse(pickupLat.toString()),
            double.parse(pickupLng.toString()),
          );

          _deliveryLocation = LatLng(
            double.parse(deliveryLat.toString()),
            double.parse(deliveryLng.toString()),
          );

          // Update map to show both locations
          if (_mapReady && _mapController != null) {
            // Calculate center point between all locations
            final centerLat = (_pickupLocation!.latitude +
                    _deliveryLocation!.latitude +
                    _currentPosition.latitude) /
                3;
            final centerLng = (_pickupLocation!.longitude +
                    _deliveryLocation!.longitude +
                    _currentPosition.longitude) /
                3;

            // Calculate appropriate zoom level
            double maxLat = [
              _pickupLocation!.latitude,
              _deliveryLocation!.latitude,
              _currentPosition.latitude
            ].reduce(max);
            double minLat = [
              _pickupLocation!.latitude,
              _deliveryLocation!.latitude,
              _currentPosition.latitude
            ].reduce(min);
            double maxLng = [
              _pickupLocation!.longitude,
              _deliveryLocation!.longitude,
              _currentPosition.longitude
            ].reduce(max);
            double minLng = [
              _pickupLocation!.longitude,
              _deliveryLocation!.longitude,
              _currentPosition.longitude
            ].reduce(min);

            // Calculate zoom level based on the distance between points
            double latZoom = log(360 / (maxLat - minLat)) / log(2);
            double lngZoom = log(360 / (maxLng - minLng)) / log(2);
            double zoom =
                min(latZoom, lngZoom) - 1; // Subtract 1 for some padding

            // Limit zoom level to reasonable bounds
            zoom = zoom.clamp(5.0, 15.0);

            // Move map to show all points
            _mapController.move(LatLng(centerLat, centerLng), zoom);
          }
        });
      } else {
        throw Exception('Failed to load locations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading order locations: $e');
      if (mounted) {
        _showErrorDialog("ไม่สามารถโหลดข้อมูลพิกัดได้ กรุณาลองใหม่อีกครั้ง\n"
            "Error: ${e.toString()}");
      }
    }
  }

  void _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
  }

  Future<void> _initializeLocation() async {
    try {
      // ตรวจสอบว่า location service เปิดอยู่หรือไม่
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _showErrorDialog("กรุณาเปิดการใช้งาน Location Service");
          return;
        }
      }

      // ขอ permission การเข้าถึงตำแหน่ง
      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          _showErrorDialog("กรุณาอนุญาตการเข้าถึงตำแหน่ง");
          return;
        }
      }

      // ดึงตำแหน่งปัจจุบัน
      LocationData currentLocation = await _location.getLocation();

      setState(() {
        _currentPosition = LatLng(
            currentLocation.latitude ?? 0, currentLocation.longitude ?? 0);
        _mapReady = true;
      });

      // เริ่มการติดตามตำแหน่งและอัพเดทข้อมูล
      _startLocationUpdates();
      _startPeriodicUpdates();
    } catch (e) {
      print('Location initialization error: $e');
      _showErrorDialog("ไม่สามารถเข้าถึงตำแหน่งได้\nError: ${e.toString()}");
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
            'deliveryLocation': {
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

// อัพเดท _buildMap() เพื่อแสดงตำแหน่งไรเดอร์
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
                // แสดงตำแหน่งไรเดอร์ถ้ามีข้อมูล
                if (_riderLocation != null)
                  Marker(
                    point: _riderLocation!,
                    width: 80,
                    height: 80,
                    child: Icon(Icons.delivery_dining,
                        color: Colors.blue, size: 40),
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
    _riderLocationTimer?.cancel(); // ยกเลิก Timer เมื่อออกจากหน้าจอ
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
          'pickupLocation': {
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
