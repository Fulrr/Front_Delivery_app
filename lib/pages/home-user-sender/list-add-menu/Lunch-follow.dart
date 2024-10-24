// ignore_for_file: file_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LunchFollowPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const LunchFollowPage({super.key, required this.order});

  @override
  State<LunchFollowPage> createState() => _LunchFollowPageState();
}

class _LunchFollowPageState extends State<LunchFollowPage> {
  late GoogleMapController mapController;
  bool isExpanded = false;

  CameraPosition initPosition = const CameraPosition(
    target: LatLng(16.246671218679253, 103.25207957788868),
    zoom: 17,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Lunch',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // แผนที่จะแสดงเต็มหน้าจอ
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: initPosition,
            markers: _createMarker(order),
          ),
          // ส่วนแสดงรายละเอียด Order จะอยู่ด้านล่างสุด
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildOrderDetails(order),
          ),
        ],
      ),
    );
  }

  Set<Marker> _createMarker(Map<String, dynamic> order) {
    return {
      Marker(
        markerId: const MarkerId('restaurant'),
        position: LatLng(16.246671218679253, 103.25207957788868), // ตำแหน่งของร้าน
        infoWindow: InfoWindow(
          title: 'Uttora Coffee House',
        ),
      ),
    };
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
        _buildDeliveryDetail('Name', order['recipient']['name']),
        _buildDeliveryDetail('Phone', order['recipient']['phone']),
        _buildDeliveryDetail('Address', order['recipient']['address']),
        const SizedBox(height: 16),
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
}
