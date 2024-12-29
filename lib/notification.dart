import 'dart:async';
import 'dart:io';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  late StreamSubscription _messageSubscription;
  List<Map<String, dynamic>> _notifications = [];
  final List<IconData> iconList = [
    Icons.home,
    Icons.message,
    Icons.notifications,
    Icons.person,
  ];

  int _bottomNavIndex = 0;
  int selectedCategoryIndex = 0;
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _bottomNavIndex=2;
    _initializeNotifications();
    _listenToMessages();
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<File?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/${Uri.parse(imageUrl).pathSegments.last}';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }

  void _showLocalNotification(
      String title, String body, String? imageUrl) async {
    File? localImageFile;
    if (imageUrl != null) {
      localImageFile = await _downloadImage(imageUrl);
    }

    final BigPictureStyleInformation? bigPictureStyle = localImageFile != null
        ? BigPictureStyleInformation(
      FilePathAndroidBitmap(localImageFile.path),
      contentTitle: title,
      summaryText: body,
    )
        : null;

    final AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigPictureStyle,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  void _listenToMessages() {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      _messageSubscription = _firestore
          .collection('messages')
          .where('userId', isEqualTo: currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        for (var docChange in snapshot.docChanges) {
          if (docChange.type == DocumentChangeType.added) {
            final newMessage = docChange.doc.data();
            final objectId = newMessage?['objectId'];
            final message = newMessage?['message'];

            if (objectId != null && message != null) {
              _firestore
                  .collection('declarations')
                  .doc(objectId)
                  .get()
                  .then((objectDoc) {
                if (objectDoc.exists) {
                  final objectImageUrl = objectDoc.data()?['imageUrl'];

                  if (objectImageUrl != null &&
                      Uri.tryParse(objectImageUrl)?.isAbsolute == true) {
                    setState(() {
                      _notifications.add({
                        'objectId': objectId,
                        'message': message,
                        'objectImageUrl': objectImageUrl,
                      });
                      _unreadNotificationCount++;
                    });

                    _showLocalNotification(
                      'Nouveau commentaire',
                      'Vous avez reçu un commentaire sur l\'objet $objectId',
                      objectImageUrl,
                    );
                  }
                }
              }).catchError((error) {
                print('Erreur lors de la récupération du document: $error');
              });
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/acceuil');
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Card(
            child: ListTile(
              leading: notification['objectImageUrl'] != null &&
                  Uri.tryParse(notification['objectImageUrl'])?.isAbsolute == true
                  ? Image.network(
                notification['objectImageUrl'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image);
                },
              )
                  : const Icon(Icons.image),
              title: Text('Objet: ${notification['objectId']}'),
              subtitle: Text(notification['message']),
            ),
          );
        },
      ),
      bottomNavigationBar: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBottomNavigationBar(
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
          if (_unreadNotificationCount > 0) // Si notifications non lues
            Positioned(
              top: 0,
              right: MediaQuery.of(context).size.width * 0.18 + 24,// Ajuster selon le design
              //left: MediaQuery.of(context).size.width * 0.03 + 24, // Aligné avec l'icône notifications
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Text(
                  '$_unreadNotificationCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed("/leading");
          print('Bouton flottant appuyé');
        },
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

}
