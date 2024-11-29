import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dashboard_student.dart';
import 'dashboard_teacher.dart';
import 'dashboard_admin.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Fonction de connexion
  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Se connecter avec Firebase Authentication
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        // Si l'utilisateur est l'administrateur, rediriger vers le tableau de bord administrateur
        if (user.email == "admin@enis.tn") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardAdmin()),
          );
        } else {
          // Récupérer les données utilisateur dans Firebase Realtime Database
          final databaseReference = FirebaseDatabase.instance.reference();
          final userRoleSnapshot = await databaseReference
              .child('users')
              .child(user.uid) // Utilisation de l'UID
              .once();

          if (userRoleSnapshot.snapshot.exists) {
            final userData = Map<String, dynamic>.from(
              userRoleSnapshot.snapshot.value as Map,
            );

            if (userData.containsKey('role')) {
              final role = userData['role'];

              // Rediriger selon le rôle
              if (role == 'Étudiant') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DashboardStudent(studentId: user.uid), // Ajout de studentId
                  ),
                );
              } else if (role == 'Enseignant') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DashboardTeacher(teacherId: user.uid), // Ajout de teacherId
                  ),
                );
              } else {
                _showMessage('Rôle non défini pour cet utilisateur.');
              }
            } else {
              _showMessage('Données utilisateur invalides : rôle manquant.');
            }
          } else {
            _showMessage('Utilisateur introuvable dans la base de données.');
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la connexion : $e');
      _showMessage(
        'Erreur lors de la connexion. Veuillez vérifier vos identifiants.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fonction pour afficher des messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Mot de passe'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Se connecter'),
                  ),
                ],
              ),
      ),
    );
  }
}
