import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delivery_app/config/config.dart';

class UserService {
  Future<Map<String, dynamic>> getUserByIdd(String userId) async {
    try {
      final response = await http.get(Uri.parse('$getUserById/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return data['data'];
        } else {
          throw Exception('ไม่พบข้อมูลผู้ใช้');
        }
      } else {
        throw Exception('เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้');
      }
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการเชื่อมต่อ: $e');
    }
  }
}
