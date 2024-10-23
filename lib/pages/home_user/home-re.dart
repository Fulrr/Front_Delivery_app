import 'dart:async';

import 'package:delivery_app/models/food_model.dart';
import 'package:delivery_app/pages/food-OR-setting/choose_food.dart';
import 'package:delivery_app/pages/home_user/profile.dart';
import 'package:delivery_app/services/food_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FoodHomeScreen extends StatefulWidget {
  const FoodHomeScreen({super.key});

  @override
  _FoodHomeScreenState createState() => _FoodHomeScreenState();
}

class _FoodHomeScreenState extends State<FoodHomeScreen> {
  int _selectedIndex = 0;
  final FoodService _foodService = FoodService();
  List<Food> _foods = [];
  List<Food> _filteredFoods = [];
  bool _isLoading = true;
  String _error = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ['All', 'Combos', 'Sliders', 'Classic'];

  // Update initState to include debouncing
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadFoods();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _onSearchChanged();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredFoods = _foods;
      });
    } else {
      _searchFoods();
    }
  }

  Future<void> _searchFoods() async {
    try {
      final searchResults =
          await _foodService.searchFoodsByName(_searchController.text);
      setState(() {
        _filteredFoods = searchResults.where((food) {
          final matchesCategory =
              _selectedCategory == 'All' || food.category == _selectedCategory;
          return matchesCategory;
        }).toList();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      // Optionally show a snackbar or other error indication
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching foods: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterFoods() {
    setState(() {
      _filteredFoods = _foods.where((food) {
        final matchesSearch = food.name.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
            food.description.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );

        final matchesCategory =
            _selectedCategory == 'All' || food.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _loadFoods() async {
    try {
      setState(() => _isLoading = true);
      final foods = await _foodService.getFoods();
      setState(() {
        _foods = foods;
        _filteredFoods = foods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          'Foodgo',
          style: GoogleFonts.lobster(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
                'https://i.pinimg.com/564x/43/6b/47/436b47519f01232a329d90f75dbeb3f4.jpg'),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFoods,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order your favourite food!',
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSearchField(),
              const SizedBox(height: 16),
              _buildCategoryChips(),
              const SizedBox(height: 16),
              _buildFoodGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filterFoods();
                },
              )
            : null,
      ),
      style: GoogleFonts.fredoka(),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories
            .map((category) => _buildCategoryChip(
                  category,
                  isSelected: _selectedCategory == category,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.fredoka(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? label : 'All';
            _filterFoods();
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.red,
      ),
    );
  }

  Widget _buildFoodGrid() {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return _buildErrorState();
    }

    if (_filteredFoods.isEmpty) {
      return _buildEmptyState();
    }

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.only(
            bottom: 80), // เพิ่ม padding ด้านล่างให้มากขึ้นเพื่อหลีกเลี่ยง FAB
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75, // ปรับอัตราส่วนให้เหมาะสม
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _filteredFoods.length,
        itemBuilder: (context, index) {
          final food = _filteredFoods[index];
          return _buildFoodItem(food);
        },
      ),
    );
  }

  Widget _buildFoodItem(Food food) {
    return InkWell(
      onTap: () {
        // เมื่อคลิกที่อาหาร ให้ไปที่หน้า FoodOrderComponent
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodOrderComponent(selectedFood: food),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: food.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      food.name,
                      style: GoogleFonts.fredoka(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      food.description,
                      style: GoogleFonts.fredoka(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '\$${food.price.toStringAsFixed(2)}',
                      style: GoogleFonts.fredoka(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Add these methods inside the _FoodHomeScreenState class

  Widget _buildErrorState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              style: GoogleFonts.fredoka(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFoods,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Try Again',
                style: GoogleFonts.fredoka(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No foods found',
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: GoogleFonts.fredoka(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_searchController.text.isNotEmpty || _selectedCategory != 'All')
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedCategory = 'All';
                    _filterFoods();
                  });
                },
                icon: const Icon(Icons.clear),
                label: Text(
                  'Clear Filters',
                  style: GoogleFonts.fredoka(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomAppBar(
        color: const Color(0xFFef2a38),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(Icons.home, '●', 0),
              _buildNavItem(Icons.person, '', 1),
              const SizedBox(width: 60),
              _buildNavItem(Icons.shopping_cart, '', 2),
              _buildNavItem(Icons.favorite, '', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        switch (_selectedIndex) {
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FoodProfileScreen()
                    .animate()
                    .slideX(begin: 1, end: 0, curve: Curves.ease),
              ),
            );
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Colors.white : Colors.white70,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.white : Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 3,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Action when tapped
        },
        child: const SizedBox(
          width: 65,
          height: 65,
          child: Icon(Icons.add, size: 35, color: Colors.white),
        ),
      ),
    );
  }
}
