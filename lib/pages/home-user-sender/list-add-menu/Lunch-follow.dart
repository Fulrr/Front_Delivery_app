// ignore_for_file: file_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class lunchfollowpage extends StatefulWidget {
  const lunchfollowpage({super.key});

  @override
  State<lunchfollowpage> createState() => _lunchfollowpageState();
}

class _lunchfollowpageState extends State<lunchfollowpage> {
  late GoogleMapController mapController;
  bool isExpanded = false;

  final LatLng _center = const LatLng(15.7461, 100.3742);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
          'Lunch',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            ),
          ),
          _buildOrderDetails(),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uttora Coffee House',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        'Orderd At 06 Sept, 10:00pm',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 16),
            _buildExpandedDetails(),
          ] else ...[
            const SizedBox(height: 16),
            const Text('2x Burger'),
            const Text('4x Sanwitch'),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildOrderItem('Burger', 2, 15.99),
        _buildOrderItem('Sandwich', 4, 8.99),
        const SizedBox(height: 16),
        const Text('Delivery Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildDeliveryDetail('Address', '123 Main St, City, Country'),
        _buildDeliveryDetail('Estimated Time', '30-45 minutes'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Call Driver', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildOrderItem(String name, int quantity, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$quantity x $name'),
          Text('\$${(quantity * price).toStringAsFixed(2)}'),
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
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}