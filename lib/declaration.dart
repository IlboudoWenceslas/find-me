import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
//import 'package:image_picker/image_picker.dart';
import 'fonctions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/services.dart';
import 'Transactionpage.dart';
import 'main.dart';


class NouvelleDeclaration extends StatefulWidget {
  @override
  _NouvelleDeclarationState createState() => _NouvelleDeclarationState();
}

class _NouvelleDeclarationState extends State<NouvelleDeclaration> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  //final ImagePicker picker = ImagePicker();
  String imagePath = "";
  bool imageExist = false;
  bool istelephone=false;
  bool isordinateur=false;
  int? age=0;
  int? montant;
  bool isprime=false;

  TextEditingController dateController = TextEditingController();
  TextEditingController numeroController = TextEditingController();

  TextEditingController marqueController = TextEditingController();
  TextEditingController modeleController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController nomController = TextEditingController();
  TextEditingController sexeController = TextEditingController();
  TextEditingController plaqueController=TextEditingController();
  TextEditingController lieuPerteController = TextEditingController();
  TextEditingController regionController = TextEditingController();
  TextEditingController provinceController = TextEditingController();
  TextEditingController categorieController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController imeicontroller=TextEditingController();
  TextEditingController numserimaccontroller=TextEditingController();
  TextEditingController primeController=TextEditingController();

  final List<String> categories = [
    'Moto',
    'Vélo',
    'Pièce',
    'Passeport',
    'Personne',
    'Carte Grise',
    'Ordinateur',
    'Telephone',
  ];
  final List<String> sexe = ['Femme','Homme'];
  bool ispersonne=false;
  bool ismoto=false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  File? selectedImageFile;
  String? imageUrl; // URL HTTP de l'image téléchargée

  final List<IconData> iconList = [
    Icons.home,
    Icons.message,
    Icons.notifications,
    Icons.person,
  ];
  int _bottomNavIndex = 0;
  int selectedCategoryIndex = 0;
  void proceedToTransaction() {
    if (isprime && int.tryParse(primeController.text) != null && int.parse(primeController.text) > 500) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionPage(
            primeAmount: int.parse(primeController.text),
          ),
        ),
      );
    }}

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouvelle déclaration"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w500,
        ),leading: IconButton(
        icon: Icon(Icons.arrow_back), // Icône de retour
        onPressed: () {
          Navigator.of(context).pushReplacementNamed('/acceuil'); // Retour à la page précédente
        },
      ),
        //nterTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: imageExist && imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      imageUrl!, // Affiche l'image depuis le lien HTTP
                      fit: BoxFit.cover,
                    ),
                  )
                      : IconButton(
                    onPressed: () async {
                      // Sélectionner une image
                      File? imageFile = await pickImage();

                      if (imageFile != null) {
                        // Télécharger l'image et récupérer le lien
                        String? uploadedUrl = await uploadImageToImgBB(imageFile);

                        if (uploadedUrl != null) {
                          setState(() {
                            selectedImageFile = imageFile;
                            imageUrl = uploadedUrl; // Met à jour le lien de l'image
                            imageExist = true;
                          });
                          print("Image téléchargée avec succès : $uploadedUrl");
                        } else {
                          print("Erreur lors du téléchargement de l'image.");
                        }
                      } else {
                        print("Aucune image sélectionnée.");
                      }
                    },
                    icon: Icon(Icons.add_a_photo, size: 50),
                  ),
                ),
                SizedBox(height: 20),DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // Mettre à jour le controller
                    categorieController.text = value!;

                    // Modifier les variables globales en fonction de la sélection
                    setState(() {
                      if (value == "Personne") {
                        ispersonne = true;
                        ismoto = false;
                        isordinateur=false;
                        istelephone=false;
                      } else if (value == "Moto") {
                        ismoto = true;
                        ispersonne = false;
                        isordinateur=false;
                        istelephone=false;
                      }else if(value=='Telephone'){
                        istelephone=true;
                        ismoto = false;
                        ispersonne = false;
                        isordinateur=false;


                      }else if(value=='Ordinateur'){
                        istelephone=false;
                        ismoto = false;
                        ispersonne = false;
                        isordinateur=true;
    }
                      else {
                        // Réinitialiser les variables globales si nécessaire
                        ispersonne = false;
                        ismoto = false;
                        istelephone=false;
                      }
                    });

                    // Imprimer la sélection pour debug
                    print("Catégorie sélectionnée : $value");
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner une catégorie';
                    }
                    return null;
                  },
                ),

                ispersonne?
                Column(
                  children: [
                    SizedBox(height: 20),
                    TextFormField(
                      controller: nomController,
                      decoration: InputDecoration(
                        labelText: 'Nom et prénom',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le Nom et le prenom';
                        }
                        return null;
                      },
                    ),
              SizedBox(height: 15),DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Genre',
                        border: OutlineInputBorder(),
                      ),
                      items: sexe.map((sexe) {
                        return DropdownMenuItem(
                          value: sexe,
                          child: Text(sexe),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // Mettre à jour le controller
                        sexeController.text = value!;

                        // Modifier les variables globales en fonction de la sélection


                        // Imprimer la sélection pour debug
                        print("sexe sélectionnée : $value");
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner votre genre';
                        }
                        return null;
                      },
                    ),SizedBox(height: 15),TextFormField(
                      controller: ageController, // Changez le nom pour refléter son usage
                      decoration: InputDecoration(
                        labelText: 'Âge',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number, // Affiche le clavier numérique
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Accepte uniquement les chiffres
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre âge';
                        }
                         age = int.tryParse(value);
                        if (age == null || age! <= 0) {
                          return 'Veuillez entrer un âge valide';
                        }
                        return null;
                      },
                    ),SizedBox(height: 15),

                    TextFormField(
                controller: dateController,
                readOnly: true, // Empêche l'édition manuelle
                decoration: InputDecoration(
                  labelText: 'Date de disparution',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today), // Icône pour indiquer le calendrier
                ),
                onTap: () async {
                  // Affiche le calendrier
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(), // Date par défaut
                    firstDate: DateTime(2000),   // Date minimale
                    lastDate: DateTime(2100),    // Date maximale
                  );

                  if (pickedDate != null) {
                    // Met à jour le contrôleur avec la date formatée
                    String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    setState(() {
                      dateController.text = formattedDate;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la date de perte';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
                    TextFormField(
                      controller: lieuPerteController,
                      decoration: InputDecoration(
                        labelText: 'Lieu de disparution',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le lieu de disparution';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: regionController,
                      decoration: InputDecoration(
                        labelText: 'Région',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la région';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: provinceController,
                      decoration: InputDecoration(
                        labelText: 'Province',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la province';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: numeroController, // Changez le nom pour refléter son usage
                      decoration: InputDecoration(
                        labelText: 'Numéro à contacter',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number, // Affiche le clavier numérique
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Accepte uniquement les chiffres
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro';
                        }
                        if (value.length < 8) {
                          return 'Veuillez entrer un numéro de téléphone valide (8 chiffres minimum)';
                        }
                        return null;
                      },
                    ),


                    SizedBox(height: 15),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Description de l'individu disparu",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
                    ),SizedBox(height: 20,),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedImageFile != null && descriptionController.text.isNotEmpty&&categorieController.text.isNotEmpty&&provinceController.text.isNotEmpty&&regionController.text.isNotEmpty&&lieuPerteController.text.isNotEmpty&&dateController.text.isNotEmpty&&numeroController.text.isNotEmpty&&numeroController.text.length==8&&nomController.text.length>3&&ageController.text.isNotEmpty&&sexeController.text.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => Center(child: CircularProgressIndicator()),
                            barrierDismissible: false,
                          );

                          await saveDeclarationWithImage(


                            categorie: categorieController.text,
                            description: descriptionController.text,
                            imageFile: imageUrl!,
                            plaque:plaqueController.text,
                            province:provinceController.text,
                            region:regionController.text,
                            lieu:lieuPerteController.text,
                            datperte: dateController.text,
                            marque: marqueController.text,
                            modele: modeleController.text,
                            nom: nomController.text,
                            numero: numeroController.text,
                            status:'Wanted',
                            imei: imeicontroller.text,
                            numseriemac: numserimaccontroller.text,
                            age: ageController.text,
                            genre:sexeController.text,
                            prime: primeController.text,
                            dateperte: '',



                          );

                          Navigator.pop(context); // Fermer le chargement
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Déclaration enregistrée avec succès'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          setState(() {
                            //selectedImageFile = null;
                            descriptionController.clear();
                            categorieController.clear();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Veuillez remplir tous  les champs et ajouter une image.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text('Enregistrer'),
                    ),
                  ],
                )
                    :ismoto?
                Column(
                  children: [SizedBox(height: 20),
                    TextFormField(
                      controller: plaqueController,
                      // maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Numero imatriculation de la moto",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le numero de la plaque';
                        }
                        return null;
                      },
                    ),SizedBox(height: 15),
                    TextFormField(
                      controller: marqueController,
                      // maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Marque de la moto",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la marque de la moto';
                        }
                        return null;
                      },
                    ),SizedBox(height: 15),
                    TextFormField(
                      controller: modeleController,
                      // maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Modèle de la moto",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le modèle';
                        }
                        return null;
                      },
                    ), SizedBox(height: 20),
                    TextFormField(
                      controller: dateController,
                      readOnly: true, // Empêche l'édition manuelle
                      decoration: InputDecoration(
                        labelText: 'Date de perte',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today), // Icône pour indiquer le calendrier
                      ),
                      onTap: () async {
                        // Affiche le calendrier
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(), // Date par défaut
                          firstDate: DateTime(2000),   // Date minimale
                          lastDate: DateTime(2100),    // Date maximale
                        );

                        if (pickedDate != null) {
                          // Met à jour le contrôleur avec la date formatée
                          String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          setState(() {
                            dateController.text = formattedDate;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la date de perte';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 15),
                    TextFormField(
                      controller: lieuPerteController,
                      decoration: InputDecoration(
                        labelText: 'Lieu de perte',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le lieu de perte';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: regionController,
                      decoration: InputDecoration(
                        labelText: 'Région',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la région';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: provinceController,
                      decoration: InputDecoration(
                        labelText: 'Province',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la province';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: numeroController, // Changez le nom pour refléter son usage
                      decoration: InputDecoration(
                        labelText: 'Numéro à contacter',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number, // Affiche le clavier numérique
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Accepte uniquement les chiffres
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro';
                        }
                        if (value.length < 8) {
                          return 'Veuillez entrer un numéro de téléphone valide (8 chiffres minimum)';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20),
                    CheckboxListTile(
                      title: Text("Cochez pour ajouter une prime"), // Texte à afficher à côté de la case
                      value: isprime,
                      onChanged: (bool? value) {
                        setState(() {
                          isprime = value ?? false;
                        });
                      },
                    ),
                if (isprime) // Affiche le champ si la case est cochée
                  TextFormField(
                    controller: primeController,
                    decoration: InputDecoration(
                      labelText: 'Montant de la prime',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number, // Clavier numérique
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Accepte uniquement les chiffres
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le montant de la prime';
                      }
                       montant = int.tryParse(value);
                      if (montant == null || montant! < 500) {
                        return 'Veuillez entrer un montant supérieur ou égal à 500';
                      }
                      return null;
                    },
                  ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: descriptionController,

                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Description de l'objet perdu",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
                    ),
                    // Bouton enregistrer
                    isprime?ElevatedButton(onPressed: proceedToTransaction,child: Text("Continuer"),)
                        :ElevatedButton(
                      onPressed: () async {
                        if (selectedImageFile != null &&
                            descriptionController.text.isNotEmpty &&
                            categorieController.text.isNotEmpty &&
                            provinceController.text.isNotEmpty &&
                            regionController.text.isNotEmpty &&
                            lieuPerteController.text.isNotEmpty &&
                            dateController.text.isNotEmpty &&
                            numeroController.text.isNotEmpty &&
                            numeroController.text.length == 8 &&
                            modeleController.text.isNotEmpty &&
                            marqueController.text.isNotEmpty &&
                            plaqueController.text.length > 0 && // Correction ici
                            (montant != null && montant! >= 500 || montant == null))  {
                          showDialog(
                            context: context,
                            builder: (context) => Center(child: CircularProgressIndicator()),
                            barrierDismissible: false,
                          );

                          await saveDeclarationWithImage(
                            categorie: categorieController.text,
                            description: descriptionController.text,
                            imageFile:imageUrl! ,
                            plaque:plaqueController.text,
                            province:provinceController.text,
                            region:regionController.text,
                            lieu:lieuPerteController.text,
                            datperte: dateController.text,
                            marque: marqueController.text,
                            modele: modeleController.text,
                            nom: nomController.text,
                            numero: numeroController.text,
                            imei: imeicontroller.text,
                            numseriemac: numserimaccontroller.text,
                            age:ageController.text,
                            genre:sexeController.text,
                            prime: primeController.text,
                            status:'Wanted',
                            dateperte: '',
                          );

                          Navigator.pop(context); // Fermer le chargement
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Déclaration enregistrée avec succès'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          setState(() {
                            selectedImageFile = null;
                            descriptionController.clear();
                            categorieController.clear();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Veuillez remplir tous  les champs et ajouter une image.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text('Enregistrer'),
                    ),

                  ],
                ):istelephone?Column(
                  children: [SizedBox(height: 20),

                    TextFormField(
                      controller: marqueController,
                      // maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Marque de Telephone",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la marque du telephone';
                        }
                        return null;
                      },
                    ),SizedBox(height: 20),TextFormField(
                      controller: imeicontroller,
                      // maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Numero IMEI",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le numero IMEI';
                        }
                        return null;
                      },
                    ),SizedBox(height: 15),
                    TextFormField(
                      controller: modeleController,
                      // maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Modèle de telephone",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le modèle';
                        }
                        return null;
                      },
                    ),
                    // SizedBox(height: 20),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: dateController,
                      readOnly: true, // Empêche l'édition manuelle
                      decoration: InputDecoration(
                        labelText: 'Date de perte',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today), // Icône pour indiquer le calendrier
                      ),
                      onTap: () async {
                        // Affiche le calendrier
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(), // Date par défaut
                          firstDate: DateTime(2000),   // Date minimale
                          lastDate: DateTime(2100),    // Date maximale
                        );

                        if (pickedDate != null) {
                          // Met à jour le contrôleur avec la date formatée
                          String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          setState(() {
                            dateController.text = formattedDate;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la date de perte';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 15),
                    TextFormField(
                      controller: lieuPerteController,
                      decoration: InputDecoration(
                        labelText: 'Lieu de perte',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le lieu de perte';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: regionController,
                      decoration: InputDecoration(
                        labelText: 'Région',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la région';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: provinceController,
                      decoration: InputDecoration(
                        labelText: 'Province',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la province';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: numeroController, // Changez le nom pour refléter son usage
                      decoration: InputDecoration(
                        labelText: 'Numéro à contacter',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number, // Affiche le clavier numérique
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Accepte uniquement les chiffres
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro';
                        }
                        if (value.length < 8) {
                          return 'Veuillez entrer un numéro de téléphone valide (8 chiffres minimum)';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20),
                    SizedBox(height: 20),
                    CheckboxListTile(
                      title: Text("Cochez pour ajouter une prime"), // Texte à afficher à côté de la case
                      value: isprime,
                      onChanged: (bool? value) {
                        setState(() {
                          isprime = value ?? false;
                        });
                      },
                    ),
                    if (isprime) // Affiche le champ si la case est cochée
                      TextFormField(
                        controller: primeController,
                        decoration: InputDecoration(
                          labelText: 'Montant de la prime',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number, // Clavier numérique
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Accepte uniquement les chiffres
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le montant de la prime';
                          }
                           montant = int.tryParse(value);
                          if (montant == null || montant! < 500) {
                            return 'Veuillez entrer un montant supérieur ou égal à 500';
                          }
                          return null;
                        },
                      ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Description de l'objet perdu",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
                    ),
                    // Bouton enregistrer
                    isprime?ElevatedButton(onPressed: proceedToTransaction,child: Text("Continuer"),)
                        :ElevatedButton(
                      onPressed: () async {
                        if (selectedImageFile != null && descriptionController.text.isNotEmpty&&categorieController.text.isNotEmpty&&provinceController.text.isNotEmpty&&regionController.text.isNotEmpty&&lieuPerteController.text.isNotEmpty&&dateController.text.isNotEmpty&&numeroController.text.isNotEmpty&&numeroController.text.length==8&&modeleController.text.isNotEmpty&&marqueController.text.isNotEmpty&&imeicontroller.text.length==15 &&(montant != null && montant ! >= 500 || montant == null)) {
                          showDialog(
                            context: context,
                            builder: (context) => Center(child: CircularProgressIndicator()),
                            barrierDismissible: false,
                          );

                          await saveDeclarationWithImage(
                            categorie: categorieController.text,
                            description: descriptionController.text,
                            imageFile:imageUrl! ,
                            plaque:plaqueController.text,
                            province:provinceController.text,
                            region:regionController.text,
                            lieu:lieuPerteController.text,
                            datperte: dateController.text,
                            marque: marqueController.text,
                            modele: modeleController.text,
                            nom: nomController.text,
                            numero: numeroController.text,
                            imei: imeicontroller.text,
                            numseriemac: numserimaccontroller.text,
                            genre:sexeController.text,
                            prime: primeController.text,
                            status:'Wanted',
                            age: ageController.text,
                            dateperte: '',
                          );

                          Navigator.pop(context); // Fermer le chargement
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Déclaration enregistrée avec succès'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          setState(() {
                            selectedImageFile = null;
                            descriptionController.clear();
                            categorieController.clear();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Veuillez remplir tous  les champs et ajouter une image.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text('Enregistrer'),
                    ),

                  ],):isordinateur?Column(
                  children: [SizedBox(height: 20),

                    TextFormField(
                      controller: marqueController,
                      // maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Marque de l'ordinateur",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la marque du telephone';
                        }
                        return null;
                      },
                    ),SizedBox(height: 20),TextFormField(
                      controller: numserimaccontroller,
                      // maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Numero serie de l'ordinateur",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le numero IMEI';
                        }
                        return null;
                      },
                    ),SizedBox(height: 15),
                    TextFormField(
                      controller: modeleController,
                      // maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Modèle de l'ordinateur",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le modèle';
                        }
                        return null;
                      },
                    ),
                    // SizedBox(height: 20),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: dateController,
                      readOnly: true, // Empêche l'édition manuelle
                      decoration: InputDecoration(
                        labelText: 'Date de perte',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today), // Icône pour indiquer le calendrier
                      ),
                      onTap: () async {
                        // Affiche le calendrier
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(), // Date par défaut
                          firstDate: DateTime(2000),   // Date minimale
                          lastDate: DateTime(2100),    // Date maximale
                        );

                        if (pickedDate != null) {
                          // Met à jour le contrôleur avec la date formatée
                          String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          setState(() {
                            dateController.text = formattedDate;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la date de perte';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 15),
                    TextFormField(
                      controller: lieuPerteController,
                      decoration: InputDecoration(
                        labelText: 'Lieu de perte',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le lieu de perte';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: regionController,
                      decoration: InputDecoration(
                        labelText: 'Région',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la région';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: provinceController,
                      decoration: InputDecoration(
                        labelText: 'Province',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la province';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: numeroController, // Changez le nom pour refléter son usage
                      decoration: InputDecoration(
                        labelText: 'Numéro à contacter',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number, // Affiche le clavier numérique
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Accepte uniquement les chiffres
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro';
                        }
                        if (value.length < 8) {
                          return 'Veuillez entrer un numéro de téléphone valide (8 chiffres minimum)';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20),
                    SizedBox(height: 20),
                    CheckboxListTile(
                      title: Text("Cochez pour ajouter une prime"), // Texte à afficher à côté de la case
                      value: isprime,
                      onChanged: (bool? value) {
                        setState(() {
                          isprime = value ?? false;
                        });
                      },
                    ),
                    if (isprime) // Affiche le champ si la case est cochée
                      TextFormField(
                        controller: primeController,
                        decoration: InputDecoration(
                          labelText: 'Montant de la prime',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number, // Clavier numérique
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Accepte uniquement les chiffres
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le montant de la prime';
                          }
                           montant = int.tryParse(value);
                          if (montant == null || montant! < 500) {
                            return 'Veuillez entrer un montant supérieur ou égal à 500';
                          }
                          return null;
                        },
                      ),

                    SizedBox(height: 15),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Description de l'objet perdu",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
                    ),
                    // Bouton enregistrer

                    isprime?ElevatedButton(onPressed: proceedToTransaction,child: Text("Continuer"),)
                        :ElevatedButton(
                      onPressed: () async {
                        if (selectedImageFile != null && descriptionController.text.isNotEmpty&&categorieController.text.isNotEmpty&&provinceController.text.isNotEmpty&&regionController.text.isNotEmpty&&lieuPerteController.text.isNotEmpty&&dateController.text.isNotEmpty&&numeroController.text.isNotEmpty&&numeroController.text.length==8&&modeleController.text.isNotEmpty&&marqueController.text.isNotEmpty&&numserimaccontroller.text.length>=7 &&(montant !=null && montant! >=500||montant ==null)) {
                          showDialog(
                            context: context,
                            builder: (context) => Center(child: CircularProgressIndicator()),
                            barrierDismissible: false,
                          );

                          await saveDeclarationWithImage(
                            categorie: categorieController.text,
                            description: descriptionController.text,
                            imageFile:imageUrl! ,
                            plaque:plaqueController.text,
                            province:provinceController.text,
                            region:regionController.text,
                            lieu:lieuPerteController.text,
                            datperte: dateController.text,
                            marque: marqueController.text,
                            modele: modeleController.text,
                            nom: nomController.text,
                            numero: numeroController.text,
                            imei: imeicontroller.text,
                            numseriemac: numserimaccontroller.text,
                            genre:sexeController.text,
                            status:'Wanted',
                            prime: primeController.text,
                            age: ageController.text,
                            dateperte: '',
                          );

                          Navigator.pop(context); // Fermer le chargement
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Déclaration enregistrée avec succès'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          setState(() {
                            selectedImageFile = null;
                            descriptionController.clear();
                            categorieController.clear();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Veuillez remplir tous  les champs et ajouter une image.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text('Enregistrer'),
                    ),

                  ],):
                  Column(
                      children: [
                        SizedBox(height: 20),
              TextFormField(
                controller: dateController,
                readOnly: true, // Empêche l'édition manuelle
                decoration: InputDecoration(
                  labelText: 'Date de perte',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today), // Icône pour indiquer le calendrier
                ),
                onTap: () async {
                  // Affiche le calendrier
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(), // Date par défaut
                    firstDate: DateTime(2000),   // Date minimale
                    lastDate: DateTime(2100),    // Date maximale
                  );

                  if (pickedDate != null) {
                    // Met à jour le contrôleur avec la date formatée
                    String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    setState(() {
                      dateController.text = formattedDate;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la date de perte';
                  }
                  return null;
                },
              ),

                        SizedBox(height: 15),
                        TextFormField(
                          controller: lieuPerteController,
                          decoration: InputDecoration(
                            labelText: 'Lieu de perte',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le lieu de perte';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: regionController,
                          decoration: InputDecoration(
                            labelText: 'Région',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la région';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: provinceController,
                          decoration: InputDecoration(
                            labelText: 'Province',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la province';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: numeroController, // Changez le nom pour refléter son usage
                          decoration: InputDecoration(
                            labelText: 'Numéro à contacter',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number, // Affiche le clavier numérique
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, // Accepte uniquement les chiffres
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre numéro';
                            }
                            if (value.length < 8) {
                              return 'Veuillez entrer un numéro de téléphone valide (8 chiffres minimum)';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15,),
                        SizedBox(height: 20),
                        CheckboxListTile(
                          title: Text("Cochez pour ajouter une prime"), // Texte à afficher à côté de la case
                          value: isprime,
                          onChanged: (bool? value) {
                            setState(() {
                              isprime = value ?? false;
                            });
                          },
                        ),
                        if (isprime) // Affiche le champ si la case est cochée
                          TextFormField(
                            controller: primeController,
                            decoration: InputDecoration(
                              labelText: 'Montant de la prime',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number, // Clavier numérique
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, // Accepte uniquement les chiffres
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le montant de la prime';
                              }
                              int? montant = int.tryParse(value);
                              if (montant == null || montant < 500) {
                                return 'Veuillez entrer un montant supérieur ou égal à 500';
                              }
                              return null;
                            },
                          ),


                        SizedBox(height: 15),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: "Description de l'objet perdu",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une description';
                            }
                            return null;
                          },
                        ),SizedBox(height: 20),
                        // Bouton enregistrer

                        isprime?ElevatedButton(onPressed: proceedToTransaction,child: Text("Continuer"),)


                            :ElevatedButton(
                          onPressed: () async {
                            if (selectedImageFile != null && descriptionController.text.isNotEmpty&&categorieController.text.isNotEmpty&&provinceController.text.isNotEmpty&&regionController.text.isNotEmpty&&lieuPerteController.text.isNotEmpty&&dateController.text.isNotEmpty&&numeroController.text.isNotEmpty&&numeroController.text.length==8 && (montant !=null && montant ! >= 500||montant ==null)) {
                              showDialog(
                                context: context,
                                builder: (context) => Center(child: CircularProgressIndicator()),
                                barrierDismissible: false,
                              );

                              await saveDeclarationWithImage(


                                categorie: categorieController.text,
                                description: descriptionController.text,
                                imageFile: imageUrl!,
                                plaque:plaqueController.text,
                                province:provinceController.text,
                                region:regionController.text,
                                lieu:lieuPerteController.text,
                                datperte: dateController.text,
                                marque: marqueController.text,
                                modele: modeleController.text,
                                nom: nomController.text,
                                numero: numeroController.text,
                                imei: imeicontroller.text,
                                numseriemac: numserimaccontroller.text,
                                genre:sexeController.text,
                                status:'Wanted',
                                prime: primeController.text,
                                age: ageController.text,
                                dateperte: '',



                              );

                              Navigator.pop(context); // Fermer le chargement
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Déclaration enregistrée avec succès'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              setState(() {
                                //selectedImageFile = null;
                                descriptionController.clear();
                                categorieController.clear();
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Veuillez remplir tous  les champs et ajouter une image.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text('Enregistrer'),
                        )



                      ],
                    ),



            ]),
          ),
        ),
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
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
          switch(_bottomNavIndex){
            case 0:Navigator.of(context).pushReplacementNamed('/acceuil');
            break;
            case 1:Navigator.of(context).pushReplacementNamed('/rmessage');
            break;
            case 2:Navigator.of(context).pushReplacementNamed('/notification');
            break;
            case 3:Navigator.of(context).pushReplacementNamed('/compte');
          }
        },
      ),
    );
  }
}