import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'fonctions.dart';

class MessagingPage extends StatefulWidget {
  final String objectId; // Identifiant de l'objet
  final String userId;// Identifiant de l'utilisateur associé à l'objet
  const MessagingPage({
    Key? key,
    required this.objectId,
    required this.userId,
  }) : super(key: key);

  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;



  @override
  void initState() {
    super.initState();
    print("Object ID: ${widget.objectId}");
    print("User ID: ${widget.userId}");
  }
  late final String  name ;
  Future<void> _sendMessage({
    required String objectId,
    required String userId,
  }) async {
    final String message = _messageController.text.trim();

    if (message.isEmpty) {
      print("Le message est vide.");
      print("Le message est vide.${objectId} ${userId} ${objectId}");
      return; // Si le champ est vide, ne faites rien
    }

    try {
      final String senderId = _auth.currentUser?.uid ?? "inconnu"; // Identifiant de l'envoyeur
      final Timestamp timestamp = Timestamp.now();
      name = await fetchUserName(senderId);

      // Sauvegarde du message dans Firestore
      await FirebaseFirestore.instance.collection('messages').add({
        'message': message,
        'objectId': objectId, // L'identifiant de l'objet
        'userId': userId,     // L'identifiant de l'utilisateur
       'name': name, // Le nom de l'utilisateur
        'senderId': senderId, // L'identifiant de l'envoyeur
        'timestamp': timestamp, // Timestamp du message
      });

      print("Message envoyé : ${objectId} ${userId} ${name}");

      // Réinitialisation du champ de saisie
      _messageController.clear();
    } catch (e) {
      print("Erreur lors de l'envoi du message : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messagerie"),
          leading: IconButton(
      icon: Icon(Icons.arrow_back), // Icône de retour
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/acceuil'); // Retour à la page précédente
      },
    ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('objectId', isEqualTo: widget.objectId) // Filtrer par l'objet
                  //.where('userId', isEqualTo: widget.userId)
                  .orderBy('timestamp', descending: false) // Trier par date
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Aucun message pour cet objet."));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        title: Text(messageData['message']),
                        subtitle: Text("Envoyé par : ${messageData['name']}"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: "Saisissez votre message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Envoyer le message avec les données nécessaires
                    _sendMessage(
                      objectId: widget.objectId,
                      userId: widget.userId, // Remplacez par la logique de récupération du nom
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
