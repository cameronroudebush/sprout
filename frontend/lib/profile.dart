// // lib/main.dart
// // Import for checking debug mode.
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// /// A stateful widget for the profile page, accessible after login.
// class ProfilePage extends StatefulWidget {

//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   // Stores the fetched profile data.
//   Map<String, dynamic>? _profileData;
//   // Message to display profile loading status or errors.
//   String _message = 'Loading profile...';

//   @override
//   void initState() {
//     super.initState();
//     _fetchProfile(); // Fetch profile data when the page initializes.
//   }

//   // /// Fetches the user profile data from the backend.
//   // Future<void> _fetchProfile() async {
//   //   setState(() {
//   //     _message = 'Loading profile...';
//   //     _profileData = null; // Clear previous data while loading
//   //   });
//   //   try {
//   //     final data = await widget.apiClient.getProfile();
//   //     if (data != null) {
//   //       setState(() {
//   //         _profileData = data;
//   //         _message = 'Profile Loaded!';
//   //       });
//   //     } else {
//   //       setState(() {
//   //         _message = 'Failed to load profile data.';
//   //       });
//   //     }
//   //   } catch (e) {
//   //     setState(() {
//   //       _message = e.toString();
//   //     });
//   //     // If an 'Unauthorized' exception occurs, navigate back to the login page.
//   //     if (e.toString().contains('Unauthorized')) {
//   //       Navigator.pushReplacement(
//   //         context,
//   //         MaterialPageRoute(builder: (context) => const LoginPage()),
//   //       );
//   //     }
//   //   }
//   // }

//   // /// Handles the logout process.
//   // /// Deletes the token and navigates back to the login page.
//   // Future<void> _logout() async {
//   //   await widget.apiClient.deleteToken();
//   //   Navigator.pushReplacement(
//   //     context,
//   //     MaterialPageRoute(builder: (context) => const LoginPage()),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.white),
//             onPressed: _logout,
//             tooltip: 'Logout',
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: _profileData == null
//               ? Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const CircularProgressIndicator(),
//                     const SizedBox(height: 20),
//                     Text(
//                       _message,
//                       style: const TextStyle(fontSize: 18, color: Colors.grey),
//                     ),
//                   ],
//                 )
//               : Card(
//                   elevation: 8,
//                   child: Padding(
//                     padding: const EdgeInsets.all(24.0),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'User Profile',
//                           style: TextStyle(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blueAccent,
//                           ),
//                         ),
//                         const Divider(height: 30, thickness: 1),
//                         _buildProfileRow('ID', _profileData!['id']),
//                         _buildProfileRow('Username', _profileData!['username']),
//                         _buildProfileRow('Email', _profileData!['email']),
//                         // Add more profile fields as per your API response structure
//                         const SizedBox(height: 30),
//                         Center(
//                           child: ElevatedButton(
//                             onPressed: _fetchProfile,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green,
//                               foregroundColor: Colors.white,
//                               elevation: 5,
//                             ),
//                             child: const Text(
//                               'Refresh Profile',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }

//   /// Helper method to build a row for profile data.
//   Widget _buildProfileRow(String label, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value?.toString() ?? 'N/A',
//               style: const TextStyle(fontSize: 18, color: Colors.black54),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
