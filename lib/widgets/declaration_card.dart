import 'package:appodcgroupe/message.dart';
import 'package:flutter/material.dart';

class DeclarationCard extends StatelessWidget {
  final Map<String, dynamic> declaration;
  final VoidCallback onTap;

  const DeclarationCard({
    super.key,
    required this.declaration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String? imageUrl = declaration['imageUrl'];
    final String object = declaration['objectid'];
    final String userId = declaration['userid'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  // Affichage de l'image
                  (imageUrl != null && imageUrl.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            imageUrl,
                            width: 160,
                            height: 320,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.image_not_supported, size: 60),
                  const SizedBox(width: 16.0),
                  // Texte des détails essentiels
                  Expanded(child: getDeclarationData()),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagingPage(
                        objectId: object,
                        userId: userId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.message, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget getDeclarationData() {
    switch (declaration['categorie']) {
      case "Personne":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRow("Nom", declaration['nom'] ?? 'Inconnu'),
            buildRow("Âge", declaration['age'] ?? 'Inconnu'),
            buildRow("Genre", declaration['genre'] ?? 'Inconnu'),
            buildRow("Lieu", declaration['lieu'] ?? 'Inconnu'),
            buildRow("Contact", declaration['numero'] ?? 'Non fourni'),
          ],
        );

      case "Moto":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRow("Marque", declaration['marque'] ?? 'Inconnue'),
            buildRow("Modèle", declaration['modele'] ?? 'Inconnu'),
            buildRow("Plaque", declaration['plaque'] ?? 'Inconnue'),
            buildRow("Lieu", declaration['lieu'] ?? 'Inconnu'),
            buildRow("Date de perte", declaration['datperte'] ?? 'Inconnue'),
            buildRow("Contact", declaration['numero'] ?? 'Non fourni'),
            const SizedBox(height: 8),
            Text(
              declaration['description'] ?? 'Pas de description',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );

      case "Telephone":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRow("Marque", declaration['marque'] ?? 'Inconnue'),
            buildRow("Modèle", declaration['modele'] ?? 'Inconnu'),
            buildRow("IMEI", declaration['imei'] ?? 'Inconnu'),
            buildRow("Lieu", declaration['lieu'] ?? 'Inconnu'),
            buildRow("Date de perte", declaration['datperte'] ?? 'Inconnue'),
            buildRow("Contact", declaration['numero'] ?? 'Non fourni'),
            const SizedBox(height: 8),
            Text(
              declaration['description'] ?? 'Pas de description',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );

      case "Ordinateur":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRow("Marque", declaration['marque'] ?? 'Inconnue'),
            buildRow("Modèle", declaration['modele'] ?? 'Inconnu'),
            buildRow(
                "Numéro de série", declaration['numseriemac'] ?? 'Inconnu'),
            buildRow("Lieu", declaration['lieu'] ?? 'Inconnu'),
            buildRow("Date de perte", declaration['datperte'] ?? 'Inconnue'),
            buildRow("Contact", declaration['numero'] ?? 'Non fourni'),
            const SizedBox(height: 8),
            Text(
              declaration['description'] ?? 'Pas de description',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );

      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRow("Date de perte", declaration['datperte'] ?? 'Inconnue'),
            buildRow("Lieu de perte", declaration['lieu'] ?? 'Inconnu'),
            buildRow("Région", declaration['region'] ?? 'Inconnue'),
            buildRow("Province", declaration['province'] ?? 'Inconnue'),
            buildRow("Statut", declaration['status'] ?? 'Non défini'),
            buildRow("Contact", declaration['numero'] ?? 'Non fourni'),
            const SizedBox(height: 8),
            Text(
              declaration['description'] ?? 'Pas de description',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
    }
  }
}
