import 'package:delivery_app/pages/home-user-sender/home-sender.dart';
import 'package:delivery_app/pages/list-on-profile-users/edit_profile.dart';
import 'package:delivery_app/pages/list-on-profile-users/histrory.dart';
import 'package:delivery_app/pages/list-on-profile-users/my-addr.dart';
import 'package:delivery_app/pages/list-on-profile-users/payment.dart';
import 'package:delivery_app/pages/home_user/home-re.dart';
import 'package:delivery_app/pages/login.dart';
import 'package:delivery_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodProfileScreen extends StatefulWidget {
  const FoodProfileScreen({super.key});

  @override
  _FoodProfileScreenState createState() => _FoodProfileScreenState();
}

class _FoodProfileScreenState extends State<FoodProfileScreen> {
  int _selectedIndex = 1;
  String userType = 'user';

  // User data fields
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String userImage = '';
  String userAddress = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');

      if (userId != null) {
        final userData = await UserService().getUserByIdd(userId);
        setState(() {
          userName = userData['name'] ?? 'User';
          userEmail = userData['email'] ?? 'user@example.com';
          userPhone = userData['phone'] ?? '';
          userImage = userData['profileImage'] ??
              'https://i.pinimg.com/564x/43/6b/47/436b47519f01232a329d90f75dbeb3f4.jpg';
          userAddress = userData['address'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading user data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFef2a38),
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.lobster(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader().animate().fadeIn(),
            _buildProfileOptions().animate().fadeIn(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFef2a38),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: CachedNetworkImageProvider(userImage),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userPhone,
                  style: const TextStyle(color: Colors.white70),
                ),
                if (userAddress.isNotEmpty)
                  Text(
                    userAddress,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const EditProfile()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        // _buildOptionTile(Icons.history, 'Order History', 0),
        _buildOptionTile(Icons.payment, 'Payment Method', 1),
        _buildOptionTile(Icons.location_on, 'My Address', 2),
        _buildOptionTile(Icons.card_giftcard, 'Market', 3),
        _buildOptionTile(Icons.favorite, 'My Favorite', 4),
        _buildOptionTile(Icons.exit_to_app, 'Sign out', 5),
      ],
    );
  }

  Widget _buildOptionTile(IconData icon, String title, int index) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.grey),
          title: Text(
            title,
            style: GoogleFonts.lato(), // Apply font style here
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            switch (_selectedIndex) {
              case 0:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderHistoryPage()));
                break;
              case 1:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentMethodPage()));
                break;
              case 2:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddressScreen()));
                break;
              case 3:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const HomesenderPage().animate().moveX()));
                break;
              case 4:
                // Handle My Favorite
                break;
              case 5:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const LoginScreen().animate().moveX()));
                break;
            }
          },
        ),
        // Optional: Uncomment if you want a divider
        // if (index < 5) const Divider(height: 1),
      ],
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
              _buildNavItem(Icons.home, '', 0),
              _buildNavItem(Icons.person, '●', 1),
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
          case 0:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FoodHomeScreen()
                        .animate()
                        .slideX(begin: -1, end: 0, curve: Curves.ease)));
            break;
          case 1:
            // Do nothing as it's the current screen
            break;
          case 2:
            // Handle Cart
            break;
          case 3:
            // Handle Favorites
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Colors.white : Colors.white,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.white : Colors.white,
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
