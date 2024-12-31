import 'package:flutter/material.dart';

class DeclarationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> declaration;

  const DeclarationDetailsPage({super.key, required this.declaration});

  @override
  Widget build(BuildContext context) {
    String? imageUrl = declaration['imageUrl'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Déclaration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affichage de l'image
            (imageUrl != null && imageUrl.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.image_not_supported, size: 100),
            const SizedBox(height: 16.0),
            // Affichage des détails
            getAtt()
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

  Widget getAtt() {
    List<Widget> atts = [];

    // Fonction pour ajouter les informations communes
    void addCommonFields() {
      atts += [
        buildRow("Date de perte", declaration['datperte'] ?? 'Inconnue'),
        buildRow("Lieu de perte", declaration['lieu'] ?? 'Inconnu'),
        buildRow("Région", declaration['region'] ?? 'Inconnue'),
        buildRow("Province", declaration['province'] ?? 'Inconnue'),
        buildRow("Statut", declaration['status'] ?? 'Non défini'),
        buildRow("Contact", declaration['numero'] ?? 'Non fourni'),
        // buildRow(
        //     "Description", "\n${declaration['description'] ?? 'Inconnue'}"),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Description :",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                declaration['description'] ?? 'Inconnue',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        )
      ];
    }

    // Ajout des informations spécifiques à chaque catégorie
    switch (declaration['categorie']) {
      case "Personne":
        atts += [
          buildRow("Nom", declaration['nom'] ?? 'Inconnu'),
          buildRow("Âge", declaration['age'] ?? 'Inconnu'),
          buildRow("Genre", declaration['genre'] ?? 'Inconnu'),
          buildRow("Lieu", declaration['lieu'] ?? 'Inconnu'),
          buildRow("Date disparition", declaration['datperte'] ?? 'Non fourni'),
        ];
        break;
      case "Moto":
        atts += [
          buildRow("Marque", declaration['marque'] ?? 'Inconnue'),
          buildRow("Modèle", declaration['modele'] ?? 'Inconnu'),
          buildRow("Plaque", declaration['plaque'] ?? 'Inconnue'),
          buildRow("Lieu", declaration['lieu'] ?? 'Inconnu'),
        ];
        break;
      case "Telephone":
        atts += [
          buildRow("Marque", declaration['marque'] ?? 'Inconnue'),
          buildRow("Modèle", declaration['modele'] ?? 'Inconnu'),
          buildRow("IMEI", declaration['imei'] ?? 'Inconnu'),
          buildRow("Lieu", declaration['lieu'] ?? 'Inconnu'),
        ];
        break;
      case "Ordinateur":
        atts += [
          buildRow("Marque", declaration['marque'] ?? 'Inconnue'),
          buildRow("Modèle", declaration['modele'] ?? 'Inconnu'),
          buildRow("Numéro de série", declaration['numseriemac'] ?? 'Inconnu'),
          buildRow("Lieu", declaration['lieu'] ?? 'Inconnu'),
        ];
        break;
      default:
        atts += [];
        break;
    }

    // Ajouter les informations communes à tous les types
    addCommonFields();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: atts);
  }
}
