import 'dart:io';
import 'package:ecotrak_driver/screens/Welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'track_truck_screen.dart';
import 'profile_screen.dart';
import 'manage_booking_screen.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  File? _profileImage;
  Position? _currentPosition; // Store the current location
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  String get currentUserId => _auth.currentUser?.uid ?? '';
  final List<Widget> _widgetOptions = [
    // TrackTruckScreen(),
    //MapSample(),
    TrackTruckScreen(),
    ProfileScreen(),
    ManageBookingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Call the function to get the current location when the screen loads
    _getCurrentLocation();
  }

  // Function to get the current location
  // Function to get the current location
  // Function to get the current location
  void _getCurrentLocation() async {
    try {
      // Request permission to access the device's location
      final bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        // Handle the case where location services are disabled
        // You can display a message or guide the user to enable location services
        return;
      }

      final LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle the case where the user denied location permissions
        // You can display a message or guide the user to enable location permissions
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        // Handle the case where the user denied location permissions permanently
        // You can display a message or guide the user to app settings
        return;
      }

      // Get the current location
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        _currentPosition = position; // Store the current location
        print(_currentPosition);
      });
      if(_currentPosition != null) {
        // Create a GeoPoint from the latitude and longitude
        GeoPoint geoPoint = GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude);

        // Get a reference to the driver's document in the "drivers" collection
        DocumentReference driverDocRef = _firestore.collection('driver').doc(currentUserId);

        // Update the location field in the driver's document
        // Update the location field in the driver's document
        await driverDocRef.update({'location': geoPoint}).then((_) {
          print("Location updated successfully");
        }).catchError((error) {
          print("Error updating location: $error");
        });
      }
      else {
        print("it is null");
      }
    } catch (e) {
      print("Error: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ecotrak'),
          backgroundColor: Colors.green
      ),
      drawer: buildSidebar(context),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildSidebar(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      :Image.asset("assets/images/donate-blood-collage-coronavirus-icons-vector-30596014.png").image,
                ),
                SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe', // Replace with user's name
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Premium Member', // Replace with user's membership status
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Rewards'),
            onTap: () {
              // Navigate to rewards screen
              Navigator.pushNamed(context, '/rewards');
            },
          ),
          ListTile(
            leading: Icon(Icons.image),
            title: Text('Change Profile Picture'),
            // onTap: () async {
            //   await _pickImage(ImageSource.gallery);
            //   Navigator.pop(context); // Close the drawer after selecting image
            // },

          ),
          ListTile(
              leading: Icon(Icons.exit_to_app), // Logout icon
              title: Text('Logout'), // Logout text
              onTap: () async {
                // Sign out from Firebase
                await _auth.signOut();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                      (Route<dynamic> route) => false, // Remove all previous routes
                );
              }
          ),
        ],
      ),
    );
  }


  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on),
          label: 'Track Truck',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Manage Booking',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.black,
      onTap: _onItemTapped,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
