import 'dart:convert';
import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ComptePage extends StatefulWidget {
  const ComptePage({Key? key}) : super(key: key);

  @override
  _ComptePageState createState() => _ComptePageState();
}

class _ComptePageState extends State<ComptePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<IconData> iconList = [
    Icons.home,
    Icons.message,
    Icons.notifications,
    Icons.person,
  ];

  int _bottomNavIndex = 0;
  File? _selectedImage;
  String? _imageUrl;
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = 3; // Index de l'icône "Compte"
    _loadUserInfo();
  }
  Future<void> _loadUserInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? "Utilisateur";
        userEmail = user.email ?? "email@example.com";
      });

      // Charger l'image locale si disponible
      final directory = await getApplicationDocumentsDirectory();
      final localImage = File('${directory.path}/profile_image.jpg');
      if (localImage.existsSync()) {
        setState(() {
          _selectedImage = localImage;
        });
      } else {
        // Charger l'image depuis Firestore si disponible
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final photoUrl = userDoc.data()!['photoUrl'] as String?;
          if (photoUrl != null) {
            final downloadedImage = await _downloadImage(photoUrl);
            if (downloadedImage != null) {
              setState(() {
                _selectedImage = downloadedImage;
              });
            }
          }
        }
      }
    }
  }

  Future<String?> uploadImageToImgBB(File imageFile) async {
    const String apiKey = '6fea62b7a1c253aa85e459e6d1f72087';
    final Uri uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      return jsonResponse['data']['url'];
    } else {
      print('Erreur lors du téléchargement : ${response.statusCode}');
      return null;
    }
  }

  Future<File?> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (selectedImage == null) return null;

    // Sauvegarder localement l'image
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/profile_image.jpg';
    final file = File(selectedImage.path).copySync(filePath);
    return file;
  }

  Future<File?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/profile_image.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image : $e');
    }
    return null;
  }

  Future<void> _onImageIconPressed() async {
    final imageFile = await pickImage();
    if (imageFile != null) {
      final imageUrl = await uploadImageToImgBB(imageFile);
      if (imageUrl != null) {
        setState(() {
          _selectedImage = imageFile;
          _imageUrl = imageUrl;
        });

        // Enregistrer dans Firestore
        final user = _auth.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'photoUrl': _imageUrl,
          }, SetOptions(merge: true));
        }
      }
    }
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compte"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/acceuil');
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _onImageIconPressed,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : const AssetImage('assets/moi.png') as ImageProvider,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(userName ?? 'Nom', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(userEmail ?? 'Email', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed("/leading");
        },
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.defaultEdge,
        activeColor: Colors.grey, // Couleur de l'icône active
        inactiveColor: Colors.black, // Couleur des icônes inactives
        backgroundColor: Colors.white, // Fond blanc
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
          switch (_bottomNavIndex) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/acceuil');
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed('/rmessage');
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed('/notification');
              break;
            case 3:
              Navigator.of(context).pushReplacementNamed('/compte');
          }
        },
      ),

    );
  }
}
