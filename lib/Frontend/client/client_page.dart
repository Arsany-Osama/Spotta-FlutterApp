import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Backend/controllers/reservation_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/sign_screen.dart';
import 'venue_details_page.dart';

class ClientPage extends StatefulWidget {
  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final ReservationController _reservationController = ReservationController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String searchQuery = "";
  String selectedFilter = "All";
  double minPrice = 0.0;
  double maxPrice = 1000.0;
  String userName = "User Name"; // Default value

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  void _fetchUserName() async {
    try {
      String userId =
          _firebaseAuth.currentUser!.uid; // Get the current user's UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      setState(() {
        userName = userDoc['name'] ?? "User Name"; // Update with fetched name
      });
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  void _logout() async {
    await _firebaseAuth.signOut();
    Get.offAll(SignUpScreen());
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Client Page",
          style: GoogleFonts.lato(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 88, 39, 6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 50, color: Color.fromARGB(255, 88, 39, 6)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userName,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                // Navigate to profile
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigate to settings
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Card(
              color: Colors.white,
              elevation: 2,
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search venues...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
          Container(
            height: screenHeight / 2 * 0.1,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterButton("All", Colors.grey[200]!, Colors.black),
                _buildFilterButton("Low Price", Colors.blue[100]!, Colors.blue),
                _buildFilterButton(
                    "High Price", Colors.green[100]!, Colors.green),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _reservationController.getVenues(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No venues available.'));
                }

                List<QueryDocumentSnapshot> filteredDocs =
                    snapshot.data!.docs.where((doc) {
                  var venue = doc.data() as Map<String, dynamic>;
                  String name = (venue['name'] ?? '').toLowerCase();
                  String description =
                      (venue['description'] ?? '').toLowerCase();

                  double venuePrice = 0.0;
                  try {
                    venuePrice =
                        double.tryParse(venue['price'].toString()) ?? 0.0;
                  } catch (e) {
                    print("Error parsing price: $e");
                  }

                  bool matchesSearch = name.contains(searchQuery) ||
                      description.contains(searchQuery);

                  bool matchesFilter = selectedFilter == "All" ||
                      (selectedFilter == "Low Price" &&
                          venuePrice <= minPrice + (maxPrice - minPrice) / 2) ||
                      (selectedFilter == "High Price" &&
                          venuePrice > minPrice + (maxPrice - minPrice) / 2) ||
                      (selectedFilter == "Reserved" &&
                          (venue['reserved'] ?? false) == true);

                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                      child: Text('No venues match your search and filter.'));
                }

                return ListView(
                  children: filteredDocs.map((doc) {
                    var venue = doc.data() as Map<String, dynamic>;

                    return FutureBuilder<bool>(
                      future: _reservationController.isReserved(doc.id),
                      builder: (context, isReservedSnapshot) {
                        if (isReservedSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        bool isReserved = isReservedSnapshot.data ?? false;

                        String shortDescription = venue['description'] != null
                            ? (venue['description'] as String).length > 100
                                ? (venue['description'] as String)
                                        .substring(0, 100) +
                                    '...'
                                : venue['description'] as String
                            : 'No description available';

                        return Card(
                          elevation: isReserved ? 6 : 3,
                          margin: EdgeInsets.all(screenWidth * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: isReserved
                              ? Color.fromARGB(226, 81, 32, 7)
                              : Colors.white,
                          child: ListTile(
                            onTap: () {
                              Get.to(VenueDetailsPage(
                                  venueId: doc.id, venue: venue));
                            },
                            title: Text(
                              venue['name'] ?? 'No Name',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: isReserved ? Colors.white : Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price: ${venue['price']}',
                                  style: GoogleFonts.poppins(
                                    color: isReserved
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                Text(
                                  shortDescription,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: isReserved
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.to(VenueDetailsPage(
                                        venueId: doc.id, venue: venue));
                                  },
                                  child: Text(
                                    "See More",
                                    style: TextStyle(
                                      color: isReserved
                                          ? Colors.white
                                          : Color.fromARGB(255, 88, 39, 6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: isReserved
                                  ? null
                                  : () {
                                      _reservationController
                                          .makeReservation(doc.id)
                                          .then((_) {
                                        Get.forceAppUpdate();
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isReserved
                                    ? Color.fromARGB(255, 255, 255, 255)
                                    : Color.fromARGB(255, 88, 39, 6),
                                foregroundColor:
                                    isReserved ? Colors.black : Colors.white,
                                disabledBackgroundColor: Colors
                                    .white, // Explicitly set disabled background
                                disabledForegroundColor: Colors
                                    .black, // Explicitly set disabled text color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                isReserved ? 'Reserved' : 'Reserve',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isReserved ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(243, 252, 247, 246),
    );
  }

  Widget _buildFilterButton(String filterName, Color bgColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = filterName;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selectedFilter == filterName ? bgColor : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selectedFilter == filterName ? textColor : Colors.grey),
          ),
          child: Center(
            child: Text(
              filterName,
              style: TextStyle(
                color:
                    selectedFilter == filterName ? textColor : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
