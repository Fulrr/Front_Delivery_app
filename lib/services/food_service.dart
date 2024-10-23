// food_service.dart
import 'dart:convert';
import 'package:delivery_app/models/food_model.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/config/config.dart';

class FoodService {
  Future<List<Food>> getFoods() async {
    try {
      final response = await http.get(Uri.parse('$getAllFood'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['data'];
        return jsonData.map((json) => Food.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load foods');
      }
    } catch (e) {
      throw Exception('Error fetching foods: $e');
    }
  }

  Future<List<Food>> searchFoodsByName(String name) async {
    try {
      if (name.isEmpty) return [];

      final response = await http.get(
        Uri.parse('$getFoodByName/$name'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((item) => Food.fromJson(item))
              .toList();
        }
      } else if (response.statusCode == 404) {
        return [];
      }
      throw Exception('Failed to search foods');
    } catch (e) {
      throw Exception('Error searching foods: $e');
    }
  }
}
