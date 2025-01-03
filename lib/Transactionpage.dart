import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  final int primeAmount;

  const TransactionPage({Key? key, required this.primeAmount}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  void verifyTransaction() {
    if (phoneController.text.length == 10 && otpController.text == '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaction réussie et déclaration sauvegardée !")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Échec de la transaction. Vérifiez vos informations.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(

          padding: const EdgeInsets.fromLTRB(20, 200, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Montant de la prime : ${widget.primeAmount} FCFA',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    color: Colors.blue,
                    child: Image.asset("assets/images/orange.png"),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: 'Numéro de téléphone'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    color: Colors.blue,
                    child: Image.asset("assets/images/orange.png"),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Code OTP'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: verifyTransaction,
                  child: Text('Confirmer la transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
