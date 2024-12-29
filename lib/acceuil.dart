import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'main.dart';
import 'fonctions.dart';
import 'message.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({Key? key}) : super(key: key);

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final List<String> categories = [
    'Tous',
    'Moto',
    'Vélo',
    'Pièce',
    'Passeport',
    'Personne',
    'Carte Grise',
    'Ordinateur',
    'Telephone',
  ];

  List<Map<String, dynamic>> declarations = []; // Données récupérées
  // String object='';
  // String usere='';
  bool isLoading = false; // Indique si les données sont en chargement

  // Icônes de la barre de navigation
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
    _bottomNavIndex=0;

    // Charger les données pour la catégorie par défaut ("Tous")
    _loadInitialDeclarations();
  }
  void _loadInitialDeclarations() async {
    setState(() {
      isLoading = true;
    });

    try {
      var fetchedDeclarations = await fetchDeclarationsByCategory('Tous');
      setState(() {
        declarations = fetchedDeclarations;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur lors du chargement initial des données : $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ACCUEIL"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher IMEI,Plaque,Numero de serie",
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Liste des catégories
          SizedBox(
          height: MediaQuery.of(context).size.width * 0.03 + 24,
          child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
          bool isSelected = index == selectedCategoryIndex;
          return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Ajoute de l'espace entre chaque catégorie
          child: GestureDetector(
          onTap: () async {
          setState(() {
          selectedCategoryIndex = index;
          isLoading = true;
          });
          try {
          var fetchedDeclarations =
          await fetchDeclarationsByCategory(categories[index]);
          setState(() {
          declarations = fetchedDeclarations;
          isLoading = false;
          });
          } catch (e) {
          print("Erreur: $e");
          setState(() => isLoading = false);
          }
          },
          child: Chip(
          label: Text(categories[index]),
          padding: const EdgeInsets.all(0.02),
          backgroundColor: isSelected ? Colors.black : Colors.grey[200],
          labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          ),
          ),
          ),
          );
          },
          ),
          ),
          // Liste des déclarations
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : declarations.isEmpty
                ? const Center(child: Text("Aucune déclaration trouvée."))
                : ListView.builder(
              itemCount: declarations.length,
              itemBuilder: (context, index) {
                final declaration = declarations[index];
                String? imageUrl = declaration['imageUrl'];
                final String object = declaration['objectid'];
                final String usere = declaration['userid'];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Affichage de l'image
                        (imageUrl != null && imageUrl.isNotEmpty)
                            ? ClipRRect(
                          borderRadius:
                          BorderRadius.circular(12.0),
                          child: Image.network(
                            imageUrl,
                            width: 160,
                            height: 320,
                            fit: BoxFit.cover,
                          ),
                        )
                            : const Icon(Icons.image_not_supported,
                            size: 60),
                        const SizedBox(width: 16.0),
                        // Texte des détails
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              declaration['categorie']=="Personne"?
                              Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Nom: ${declaration['nom'] ?? 'Inconnu'}',
                                  ),
                                  Text(
                                    'Age: ${declaration['age'] ?? 'Inconnu'}',
                                  ),
                                  Text(
                                    'Genre: ${declaration['genre'] ?? 'Inconnu'}',
                                  ),
                                  Text(
                                    'Lieu: ${declaration['lieu'] ?? 'Inconnu'}',
                                  ),

                                  Text(
                                    'Date disparution: ${declaration['datperte'] ?? 'Inconnu'}',
                                  ),Text(
                                    'Region: ${declaration['region'] ?? 'Inconnue'}',
                                  ),Text(
                                    'Province: ${declaration['province'] ?? 'Inconnue'}',
                                  ),
                                  Text(
                                    'Statut: ${declaration['status'] ?? 'Non défini'}',
                                  ),
                                  Text(
                                    'Contact: ${declaration['numero'] ?? 'Non fourni'}',

                                  ),Text(
                                    declaration['description'] ??
                                        'Pas de description',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Bouton pour la messagerie
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      onPressed: () {

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MessagingPage(
                                              objectId: object,
                                              userId: usere,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.message, color: Colors.black),
                                    ),

                                  ),
                                ],
                              ):declaration['categorie']=="Moto"?
                              Column(
                  children: [
                      const SizedBox(height: 8),
                  Text(
                    'Marque: ${declaration['marque'] ?? 'Inconnu'}',
                  ),
                  Text(
                    'Modele: ${declaration['modele'] ?? 'Inconnu'}',
                  ),
                  Text(
                    'Plaque: ${declaration['plaque'] ?? 'Inconnu'}',
                  ),
                  Text(
                    'Lieu: ${declaration['lieu'] ?? 'Inconnu'}',
                  ),

                  Text(
                    'Date de perte: ${declaration['datperte'] ?? 'Inconnu'}',
                  ),Text(
                  'Region: ${declaration['region'] ?? 'Inconnue'}',
                ),Text(
                  'Province: ${declaration['province'] ?? 'Inconnue'}',
                ),
                  Text(
                    'Statut: ${declaration['status'] ?? 'Non défini'}',
                  ),
                  Text(
                    'Contact: ${declaration['numero'] ?? 'Non fourni'}'

                  ),Text(
                  declaration['description'] ??
                      'Pas de description',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                  // Bouton pour la messagerie
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: ()  {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagingPage(
                              objectId: object,
                              userId: usere,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.message, color: Colors.black),
                    ),

                  ),
                  ], ):declaration["categorie"]=="Telephone"?
                              Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Marque: ${declaration['marque'] ?? 'Inconnu'}',
                                  ),
                                  Text(
                                    'IMEI:${declaration['imei'] ??'Inconnu'}',
                                  ),
                                  Text(
                                    'Modele: ${declaration['modele'] ?? 'Inconnu'}',
                                  ),
                                  Text(
                                    'Lieu: ${declaration['lieu'] ?? 'Inconnu'}',
                                  ),

                                  Text(
                                    'Date de perte: ${declaration['datperte'] ?? 'Inconnu'}',
                                  ),Text(
                                    'Region: ${declaration['region'] ?? 'Inconnue'}',
                                  ),Text(
                                    'Province: ${declaration['province'] ?? 'Inconnue'}',
                                  ),
                                  Text(
                                    'Statut: ${declaration['status'] ?? 'Non défini'}',
                                  ),
                                  Text(
                                    'Contact: ${declaration['numero'] ?? 'Non fourni'}',
                                  ),
                                  Text(
                                    declaration['description'] ??
                                        'Pas de description',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Bouton pour la messagerie
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      onPressed: ()  {

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MessagingPage(
                                              objectId: object,
                                              userId: usere,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.message, color: Colors.black),
                                    ),

                                  ),
                                ],
                              ):declaration["categorie"]=="Ordinateur"?
                              Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Marque: ${declaration['marque'] ?? 'Inconnu'}',
                                  ),
                                  Text(
                                    'Modele: ${declaration['modele'] ?? 'Inconnu'}',
                                  ),
                                  Text('Numero de serie:${declaration['numseriemac']??'inconnu'}'
                                  ),
                                  Text(
                                    'Lieu: ${declaration['lieu'] ?? 'Inconnu'}',
                                  ),

                                  Text(
                                    'Date de perte: ${declaration['datperte'] ?? 'Inconnu'}',
                                  ),Text(
                                    'Region: ${declaration['region'] ?? 'Inconnue'}',
                                  ),Text(
                                    'Province: ${declaration['province'] ?? 'Inconnue'}',
                                  ),
                                  Text(
                                    'Statut: ${declaration['status'] ?? 'Non défini'}',
                                  ),
                                  Text(
                                    'Contact: ${declaration['numero'] ?? 'Non fourni'}',
                                  ),
                                  Text(
                                    declaration['description'] ??
                                        'Pas de description',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Bouton pour la messagerie
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      onPressed: ()  {

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MessagingPage(
                                              objectId: object,
                                              userId: usere,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.message, color: Colors.black),
                                    ),

                                  ),
                                ],
                              ):Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Date de perte: ${declaration['datperte'] ?? 'Inconnu'}',
                                  ),
                                  Text(
                                    'Lieu de perte: ${declaration['lieu'] ?? 'Inconnu'}',
                                  ),
                                  Text(
                                    'Region: ${declaration['region'] ?? 'Inconnue'}',
                                  ),Text(
                                    'Province: ${declaration['province'] ?? 'Inconnue'}',
                                  ),
                                  Text(
                                    'Statut: ${declaration['status'] ?? 'Non défini'}',
                                  ),

                                  Text(
                                    'Contact: ${declaration['numero'] ?? 'Non fourni'}',

                                  ),Text(
                                    declaration['description'] ??
                                        'Pas de description',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Bouton pour la messagerie
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(

                                      onPressed: () {

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MessagingPage(
                                              objectId: object,
                                              userId: usere,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.message, color: Colors.black),
                                    ),

                                  ),
                                ],
                              )
                            ],

                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
