import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_compression/image_compression.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;








Future<String> fetchUserName(String userId) async {
  String userName = "Utilisateur non trouvé"; // Valeur par défaut si l'utilisateur n'est pas trouvé

  try {
    // Accédez à la collection 'users' dans Firestore
    final CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Effectuer une requête pour obtenir l'utilisateur avec l'uid spécifié
    DocumentSnapshot userDoc = await users.doc(userId).get();

    // Vérifiez si l'utilisateur existe
    if (userDoc.exists) {
      // Si l'utilisateur existe, récupérez le champ 'name'
      userName = userDoc['name'] ?? 'Nom non défini';  // Valeur par défaut si le champ 'name' est absent
    } else {
      print("Utilisateur non trouvé");
    }
  } catch (e) {
    print("Erreur lors de la récupération du nom de l'utilisateur : $e");
  }

  return userName;
}










Future<Map<String, String>> _fetchObjectAndUserIds(String objectId) async {
  try {
    // Étape 1 : Recherche de la déclaration avec l'objectId
    final declarationSnapshot = await FirebaseFirestore.instance
        .collection('declarations')
        .doc(objectId)
        .get();

    if (!declarationSnapshot.exists) {
      throw Exception("Déclaration avec objectId $objectId non trouvée.");
    }

    final declarationData = declarationSnapshot.data();
    if (declarationData == null || !declarationData.containsKey('userId')) {
      throw Exception("Le champ 'userId' est manquant dans la déclaration.");
    }

    final String userId = declarationData['userId'];

    // Étape 2 : Recherche de l'utilisateur avec le userId
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userSnapshot.exists) {
      throw Exception("Utilisateur avec userId $userId non trouvé.");
    }

    final userData = userSnapshot.data();
    if (userData == null || !userData.containsKey('name')) {
      throw Exception("Le champ 'name' est manquant dans l'utilisateur.");
    }

    final String userName = userData['name'];

    // Étape 3 : Retour des données sous forme de map
    return {
      'objectId': objectId,
      'userId': userId,
      'userName': userName,
    };
  } catch (e) {
    print("Erreur dans _fetchObjectAndUserIds : $e");
    rethrow; // Relancer l'erreur pour une gestion ultérieure
  }
}





Future<String?> uploadImageToImgBB(File imageFile) async {
  const String apiKey = '6fea62b7a1c253aa85e459e6d1f72087'; // Remplacez par votre clé API
  final Uri uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

  final request = http.MultipartRequest('POST', uri);
  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  final response = await request.send();
  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseBody);
    return jsonResponse['data']['url']; // Retourne le lien de l'image
  } else {
    print('Erreur lors du téléchargement : ${response.statusCode}');
    return null;
  }
}

Future<File?> pickImage() async {
  final ImagePicker _picker = ImagePicker();

  // Sélectionner une image depuis la galerie
  final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);

  if (selectedImage == null) return null;

  return File(selectedImage.path);
}

Future<List<Map<String, dynamic>>> fetchDeclarationsByCategory(String category) async {
  List<Map<String, dynamic>> fetchedDeclarations = [];

  try {
    print("Récupération des déclarations pour la catégorie : $category");

    QuerySnapshot querySnapshot;

    if (category == "Tous") {
      // Récupère toutes les déclarations sans filtrer
      querySnapshot = await FirebaseFirestore.instance
          .collection('declarations')
          .orderBy('timestamp', descending: true)
          .get();

    } else {
      // Récupère seulement les déclarations de la catégorie spécifiée, triées par date décroissante
      querySnapshot = await FirebaseFirestore.instance
          .collection('declarations')
          .where('categorie', isEqualTo: category) // Filtrer par catégorie
          // Trier par date décroissante
          .get();
    }


    print("Nombre de déclarations récupérées : ${querySnapshot.docs.length}");

    for (var doc in querySnapshot.docs) {
      fetchedDeclarations.add(doc.data() as Map<String, dynamic>);
    }
  } catch (e) {
    print("Erreur lors de la récupération des données : $e");
  }

  return fetchedDeclarations;
}







Future<File?> pickAndCompressImage() async {
  final ImagePicker _picker = ImagePicker();

  // Sélectionner une image
  final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);

  if (selectedImage == null) return null; // Si l'utilisateur annule

  // Convertir XFile en File
  final File imageFile = File(selectedImage.path);

  // Chemin de destination pour l'image compressée
  final String targetPath = '${imageFile.path}_compressed.jpg';

  try {
    // Compresser l'image
    final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path, // Chemin de l'image d'entrée
      targetPath,             // Chemin de l'image compressée
      quality: 50,            // Niveau de compression (1-100)
    );

    if (compressedXFile == null) return null;

    return File(compressedXFile.path); // Retourner l'image compressée sous forme de File
  } catch (e) {
    print('Erreur lors de la compression de l\'image : $e');
    return null;
  }
}

/// **Convertir un fichier image en Base64**
Future<String?> convertImageToBase64(File file) async {
  try {
    // Lire les bytes de l'image
    final List<int> imageBytes = await file.readAsBytes();
    // Encoder en Base64
    return base64Encode(imageBytes);
  } catch (e) {
    print('Erreur lors de la conversion en Base64 : $e');
    return null;
  }
}


Future<void> saveDeclarationWithImage({
  required String categorie,
  required String description,
  required String imageFile,
  required String plaque,
  required String dateperte,
  required String province,
  required String region,
  required String lieu,
  required String imei,
  required String numseriemac,
  required String marque,
  required String modele,
  required String nom,
  required String age,
  required String genre,
  required String numero,
  required String status,
  required String datperte,
}) async {
  try {
    // Obtenir l'utilisateur connecté
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print('Aucun utilisateur connecté.');
      return;
    }

    String userid = currentUser.uid; // ID de l'utilisateur connecté

    // Ajouter la déclaration dans Firestore
    DocumentReference docRef = await FirebaseFirestore.instance.collection('declarations').add({
      'categorie': categorie,
      'description': description,
      'plaque': plaque,
      'province': province,
      'region': region,
      'lieu': lieu,
      'marque': marque,
      'modele': modele,
      'nom': nom,
      'age': age,
      'genre':genre,
      'imei':imei,
      'numserimac':numseriemac,
      'numero': numero,
      'status': status,
      'datperte': datperte,
      'userid': userid,         // ID de l'utilisateur connecté
      'imageUrl': imageFile,    // URL ou référence de l'image
      'timestamp': FieldValue.serverTimestamp(), // Date et heure serveur
    });

    // Ajouter l'ID auto-généré par Firestore comme `objectid`
    await docRef.update({'objectid': docRef.id});

    print('Déclaration enregistrée avec succès. ObjectID : ${docRef.id}');
  } catch (e) {
    print('Erreur lors de l\'enregistrement : $e');
  }
}


// Fonction pour enregistrer l'utilisateur dans Firestore
Future<void> saveUserToFirestore(User user) async {
  try {
    final CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Créer ou mettre à jour les données de l'utilisateur
    await users.doc(user.uid).set({
      'uid': user.uid,
      'name': user.displayName,
      'email': user.email,
      'photoUrl': user.photoURL,
      'lastSignIn': DateTime.now(),
    }, SetOptions(merge: true)); // Utiliser merge pour ne pas écraser les données existantes
    print("Utilisateur enregistré dans Firestore.");
  } catch (e) {
    print("Erreur lors de l'enregistrement dans Firestore : $e");
  }
}
Future<User?> signInWithGoogle() async {
  try {
    // Étape 1 : Initialiser Google Sign-In
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      // Étape 2 : Obtenir les informations d'authentification Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Étape 3 : Créer des identifiants Firebase avec le token Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Étape 4 : Connecter l'utilisateur à Firebase
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Récupérer les informations de l'utilisateur
      final User? user = userCredential.user;
      if (user != null) {
        // Étape 5 : Enregistrer les informations dans Firestore
        await saveUserToFirestore(user);

        print("Connexion réussie et données sauvegardées : ${user.displayName}");
        return user;
      }
    } else {
      print("Connexion Google annulée par l'utilisateur.");
      return null;
    }
  } catch (e) {
    print("Erreur pendant la connexion Google : $e");
    return null;
  }
}

Future<User?> loginWithFacebook() async {
  try {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final AccessToken? accessToken = result.accessToken;

      if (accessToken != null) {
        // Vérifiez ici quelle propriété contient le jeton : token ou tokenString
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString, // Utilisez la bonne propriété
        );

        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        print("Connexion réussie : ${userCredential.user?.displayName}");
        return userCredential.user;
      }
    } else if (result.status == LoginStatus.cancelled) {
      print("Connexion annulée par l'utilisateur.");
    } else {
      print("Erreur pendant la connexion Facebook : ${result.message}");
    }
  } catch (e) {
    print("Exception pendant la connexion Facebook : $e");
  }

  return null;
}