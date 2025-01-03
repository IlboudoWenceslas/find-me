import 'package:appodcgroupe/widgets/declaration_list.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'main.dart';
import 'fonctions.dart';
import 'message.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

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
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredDeclarations = []; // Déclarations filtrées

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
    _loadInitialDeclarations();
    _searchController.addListener(_filterDeclarations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialDeclarations() async {
    setState(() {
      isLoading = true;
    });

    try {
      var fetchedDeclarations = await fetchDeclarationsByCategory('Tous');
      setState(() {
        declarations = fetchedDeclarations;
        filteredDeclarations = fetchedDeclarations;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur lors du chargement initial des données : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterDeclarations() {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        filteredDeclarations = declarations;
      });
      return;
    }

    setState(() {
      filteredDeclarations = declarations.where((declaration) {
        return (declaration['plaque']?.toLowerCase().startsWith(query) ?? false) ||
            (declaration['imei']?.toLowerCase().startsWith(query) ?? false) ||
            (declaration['nom']?.toLowerCase().startsWith(query) ?? false) ||
            (declaration['numero']?.toLowerCase().startsWith(query) ?? false);
      }).toList();
    });
  }

  @override
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher IMEI, Plaque, Nom ou Numéro",
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                          filteredDeclarations = fetchedDeclarations;
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
                      backgroundColor:
                      isSelected ? Colors.black : Colors.grey[200],
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
                : filteredDeclarations.isEmpty
                ? const Center(child: Text("Aucune déclaration trouvée."))
                : DeclarationList(declarations: filteredDeclarations),
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
