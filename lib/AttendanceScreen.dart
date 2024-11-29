import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'BlockchainService.dart';  // Assurez-vous que BlockchainService est correctement importé

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final DatabaseReference _firebaseRef = FirebaseDatabase.instance.ref().child("users");
  final BlockchainService _blockchainService = BlockchainService();

  List<Map<String, dynamic>> _students = [];
  bool _isBlockchainInitialized = false;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _initializeBlockchain();
  }

  // Initialisation du service Blockchain (chargement de l'ABI et du contrat)
  Future<void> _initializeBlockchain() async {
    await _blockchainService.init();
    setState(() {
      _isBlockchainInitialized = _blockchainService.isInitialized;  // Mettre à jour l'état lorsque l'initialisation est terminée
    });
  }

  // Récupérer les étudiants depuis Firebase
  Future<void> _fetchStudents() async {
    _firebaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _students = data.entries.map((e) {
          return {
            'id': e.key,
            'name': e.value['name'],
            'email': e.value['email'],
          };
        }).toList();
      });
    });
  }

  // Fonction pour marquer la présence de l'étudiant
  Future<void> _markAttendance(bool isPresent) async {
    if (!_isBlockchainInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Blockchain not initialized yet. Please wait.")),
      );
      return;
    }

    String studentAddress = "0x88E5129992AE9ae6F476fe3169dFE5F7dF8A0BCB";  // L'adresse Ethereum unique

    // Appel à la méthode BlockchainService pour marquer la présence sur la blockchain
    await _blockchainService.markAttendance(studentAddress, isPresent);

    // Enregistrer la présence dans Firebase
    await _firebaseRef.child(studentAddress).update({'isPresent': isPresent});
    
    // Affichage du message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Présence enregistrée pour $studentAddress')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Présence des étudiants"),
      ),
      body: _isBlockchainInitialized
          ? ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return ListTile(
                  title: Text(student['name']),
                  subtitle: Text(student['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _markAttendance(true),  // Marquer comme présent
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _markAttendance(false),  // Marquer comme absent
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(child: CircularProgressIndicator()),  // Afficher un indicateur de chargement pendant l'initialisation
    );
  }
}
