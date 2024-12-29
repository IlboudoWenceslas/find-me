import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagingcolectPage extends StatefulWidget {
  const MessagingcolectPage({Key? key}) : super(key: key);

  @override

  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingcolectPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<IconData> iconList = [
    Icons.home,
    Icons.message,
    Icons.notifications,
    Icons.person,
  ];

  int _bottomNavIndex = 0;
  int selectedCategoryIndex = 0;
  @override
  void initState() {
    super.initState();
    _bottomNavIndex = 1; // Index de l'icône "Compte"
  }



  Future<List<Map<String, dynamic>>> _fetchDeclarationsWithMessages() async {
    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception("Utilisateur non authentifié.");
    }

    List<Map<String, dynamic>> data = [];
    try {
      final QuerySnapshot declarationsSnapshot = await FirebaseFirestore.instance
          .collection('declarations')
          .where('userid', isEqualTo: currentUserId)
          .get();

      for (var declarationDoc in declarationsSnapshot.docs) {
        final declarationData = declarationDoc.data() as Map<String, dynamic>;
        final String objectId = declarationData['objectid'];
        final String imageUrl = declarationData['imageUrl'];

        final QuerySnapshot messagesSnapshot = await FirebaseFirestore.instance
            .collection('messages')
            .where('objectId', isEqualTo: objectId)
            .orderBy('timestamp', descending: false)
            .get();

        List<Map<String, dynamic>> messages = messagesSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        data.add({
          'docId': declarationDoc.id, // ID du document Firebase
          'objectid': objectId,
          'imageUrl': imageUrl,
          'message': messages,
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des données : $e");
    }

    return data;
  }

  void _showEditDialog(Map<String, dynamic> declaration) async {
    // Récupérer la catégorie depuis Firestore
    String? category = declaration['categorie'];

    // Contrôleurs pour les champs spécifiques
    final TextEditingController dateController = TextEditingController(text: declaration['datperte'] ?? "");
    final TextEditingController lieuPerteController = TextEditingController(text: declaration['lieu'] ?? "");
    final TextEditingController numeroController = TextEditingController(text: declaration['numero'] ?? "");
    final TextEditingController provinceController = TextEditingController(text: declaration['province'] ?? "");
    final TextEditingController regionController = TextEditingController(text: declaration['region'] ?? "");
    final TextEditingController statusController = TextEditingController(text: declaration['status'] ?? "");
    final TextEditingController descriptionController = TextEditingController(text: declaration['description'] ?? "");

    // Champs spécifiques aux catégories
    final TextEditingController marqueController = TextEditingController(text: declaration['marque'] ?? "");
    final TextEditingController modeleController = TextEditingController(text: declaration['modele'] ?? "");
    final TextEditingController plaqueController = TextEditingController(text: declaration['plaque'] ?? "");
    final TextEditingController nomController = TextEditingController(text: declaration['nom'] ?? "");
    final TextEditingController ageController = TextEditingController(text: declaration['age'] ?? "");
    final TextEditingController sexeController = TextEditingController(text: declaration['genre'] ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier la déclaration"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Champs communs à toutes les catégories
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: "Date de perte"),
                ),
                TextField(
                  controller: lieuPerteController,
                  decoration: const InputDecoration(labelText: "Lieu de perte"),
                ),
                TextField(
                  controller: provinceController,
                  decoration: const InputDecoration(labelText: "Province"),
                ),
                TextField(
                  controller: regionController,
                  decoration: const InputDecoration(labelText: "Région"),
                ),
                TextField(
                  controller: numeroController,
                  decoration: const InputDecoration(labelText: "Numéro de contact"),
                ),
                TextField(
                  controller: statusController,
                  decoration: const InputDecoration(labelText: "Statut"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),

                // Champs spécifiques aux catégories
                if (category == "Moto") ...[
                  TextField(
                    controller: marqueController,
                    decoration: const InputDecoration(labelText: "Marque"),
                  ),
                  TextField(
                    controller: modeleController,
                    decoration: const InputDecoration(labelText: "Modèle"),
                  ),
                  TextField(
                    controller: plaqueController,
                    decoration: const InputDecoration(labelText: "Plaque"),
                  ),
                ],
                if (category == "Personne") ...[
                  TextField(
                    controller: nomController,
                    decoration: const InputDecoration(labelText: "Nom"),
                  ),
                  TextField(
                    controller: ageController,
                    decoration: const InputDecoration(labelText: "Âge"),
                  ),
                  TextField(
                    controller: sexeController,
                    decoration: const InputDecoration(labelText: "Sexe"),
                  ),
                ],
                if (category == "Telephone") ...[
                  TextField(
                    controller: marqueController,
                    decoration: const InputDecoration(labelText: "Marque"),
                  ),
                  TextField(
                    controller: modeleController,
                    decoration: const InputDecoration(labelText: "Modèle"),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Construire les données à mettre à jour
                  Map<String, dynamic> updateData = {
                    'datperte': dateController.text,
                    'lieu': lieuPerteController.text,
                    'province': provinceController.text,
                    'region': regionController.text,
                    'numero': numeroController.text,
                    'status': statusController.text,
                    'description': descriptionController.text,
                  };

                  // Ajouter des champs spécifiques selon la catégorie
                  if (category == "Moto") {
                    updateData.addAll({
                      'marque': marqueController.text,
                      'modele': modeleController.text,
                      'plaque': plaqueController.text,
                    });
                  } else if (category == "Personne") {
                    updateData.addAll({
                      'nom': nomController.text,
                      'age': ageController.text,
                      'genre': sexeController.text,
                    });
                  } else if (category == "Telephone") {
                    updateData.addAll({
                      'marque': marqueController.text,
                      'modele': modeleController.text,
                    });
                  }

                  // Mettre à jour dans Firestore
                  await FirebaseFirestore.instance
                      .collection('declarations')
                      .doc(declaration['docId'])
                      .update(updateData);

                  Navigator.pop(context);
                  setState(() {}); // Recharger la liste
                } catch (e) {
                  print("Erreur lors de la mise à jour : $e");
                }
              },
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }


  void _confirmDeletion(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: const Text("Êtes-vous sûr de vouloir supprimer cette déclaration ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('declarations')
                      .doc(docId)
                      .delete();
                  Navigator.pop(context);
                  setState(() {}); // Recharger la liste
                } catch (e) {
                  print("Erreur lors de la suppression : $e");
                }
              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messagerie"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDeclarationsWithMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Erreur : ${snapshot.error}"),
            );
          }

          final data = snapshot.data;

          if (data == null || data.isEmpty) {
            return const Center(
              child: Text("Aucune déclaration trouvée."),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final declaration = data[index];
              final List messages = declaration['message'];

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (declaration['imageUrl'] != null)
                      Image.network(
                        declaration['imageUrl'],
                        height: 320,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      "Messages pour l'objet ${declaration['objectid']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...messages.map((message) {
                      final isSender = message['senderId'] == _auth.currentUser?.uid;
                      return ListTile(
                        title: Text(
                          message['message'],
                          style: TextStyle(
                            color: isSender ? Colors.blue : Colors.black,
                            fontWeight: isSender ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          isSender ? "Vous" : "Envoyé par : ${message['name']}",
                        ),
                      );
                    }).toList(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showEditDialog(declaration),
                          icon: const Icon(Icons.edit),
                          label: const Text("Modifier"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _confirmDeletion(declaration['docId']),
                          icon: const Icon(Icons.delete),
                          label: const Text("Supprimer"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red,),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed("/leading");
        print('Bouton flottant appuyé');
      },
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      foregroundColor: Colors.white,
      shape: CircleBorder(),
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
