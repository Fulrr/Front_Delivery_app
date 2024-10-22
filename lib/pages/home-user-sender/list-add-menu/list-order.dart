// ignore_for_file: camel_case_types

import 'package:delivery_app/pages/home-user-sender/add-menu.dart';
import 'package:flutter/material.dart';

class listorders extends StatelessWidget {
  const listorders({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16.0),
      width: media.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'รายการสินค้า',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text("test01"),
          const Text("test02"),
          const Text("test03"),
          const Text("test04"),
          const Text("test05"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigator.pop(context); 
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ListOrdersPage()),
            );
            },
            child: const Text('จัดส่ง'),
          ),
        ],
      ),
    );
  }
}
