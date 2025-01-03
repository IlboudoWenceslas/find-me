import 'package:appodcgroupe/rmessage.dart';
import 'package:flutter/material.dart';
import 'acceuil.dart';
import 'compte.dart';
import 'declaration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fonctions.dart';
import 'message.dart';
import 'notification.dart';
import 'telephone.dart';
import '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialisation de Firebase
  runApp(const Route()); // Lancement de l'application avec la route principale
}

class Route extends StatefulWidget {
  const Route({super.key});
  @override
  State<StatefulWidget> createState() => _RouteState();
}

class _RouteState extends State<Route> {
  @override
  Widget build(BuildContext context) {
    // Vérifier si un utilisateur est déjà connecté
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Désactiver le bandeau de debug
      initialRoute: currentUser != null
          ? '/acceuil'
          : '/', // Rediriger en fonction de l'état de connexion
      routes: {
        '/': (context) => const Connexion(),
        '/leading': (context) =>
            NouvelleDeclaration(), // Route pour la page de connexion
        '/acceuil': (context) => AccueilPage(), // Route pour la page d'accueil
        '/compte': (context) => ComptePage(),
        '/notification': (context) => NotificationPage(),
        '/declaration': (context) => NouvelleDeclaration(),
        '/rmessage': (context) => MessagingcolectPage(),
        '/message': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return MessagingPage(
            objectId: args['objectid'] as String,
            userId: args['userid'] as String,
          );
        },
      },
    );
  }
}

class Connexion extends StatefulWidget {
  const Connexion({super.key});
  @override
  State<StatefulWidget> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black), // AppBar avec fond noir
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.black, // Fond de la page en noir
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Center(
                child: Text(
                  ' Find Me ',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
              ),
              SizedBox(height: 20),

              // Affichage du logo au centre de l'écran
              Container(
                width: screenwidth * 0.65,
                height: screenheight * 0.3,
                child: Center(
                  child: Image(
                    width: 300,
                    height: 150,
                    image: AssetImage("assets/images/logo.jpg"),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadiusDirectional.circular(90),
                ),
              ),
              SizedBox(height: screenheight * 0.02),
              SizedBox(height: screenheight * 0.05),
              // Les boutons de connexion
              Column(
                children: [
                  // Connexion avec Facebook
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenwidth * 0.75,
                        height: screenheight * 0.05,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              padding:
                                  WidgetStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.symmetric(vertical: 5))),
                          onPressed: () async {
                            Navigator.of(context)
                                .pushReplacementNamed('/telephone');
                          },
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 50, 0, 50)),
                                Image(
                                    image:
                                        AssetImage("assets/images/face_.png")),
                                Text(" Se connecter avec Facebook",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenheight * 0.05),
                  // Connexion avec Google
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenwidth * 0.75,
                        height: screenheight * 0.05,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              padding:
                                  WidgetStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.symmetric(vertical: 5))),
                          onPressed: () async {
                            final user = await signInWithGoogle();
                            if (user != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Bienvenue, ${user.displayName}!")),
                              );
                              Navigator.of(context).pushReplacementNamed(
                                  '/acceuil',
                                  arguments: {"data": "Wenceslas"});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("Connexion annulée ou échouée.")),
                              );
                            }
                          },
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                    image:
                                        AssetImage("assets/images/google.png")),
                                Text(" Se connecter avec Google",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenheight * 0.05),
                  // Texte pour rediriger vers la page de connexion
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/acceuil',
                          arguments: {"data": "Wenceslas"});
                    },
                    child: Text(
                      "Vous avez deja un compte ? Se connecter",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Colors.white // Ajout de la ligne soulignée
                          ),
                    ),
                  ),
                  SizedBox(height: screenheight * 0.03),
                  // Continuer sans se connecter
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.of(context).pushReplacementNamed('/acceuil', arguments: {"data": "Wenceslas"});
                  //   },
                  //   child: Text(
                  //     " Continuer sans se connecter .",
                  //     style: TextStyle(color: Colors.white, fontSize: 16),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
