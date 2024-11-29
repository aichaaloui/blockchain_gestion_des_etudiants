import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ManageUsers extends StatefulWidget {
  @override
  _ManageUsersState createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  String selectedRole = 'Étudiant';
  String selectedClass = 'GI3S1'; // Classe par défaut pour les étudiants
  List<String> selectedClassesForTeacher = []; // Classes sélectionnées pour le professeur

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("users");
  final List<String> classesList = ['GI3S1', 'GI3S2', 'GI3S3', 'GI3S4'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gérer les utilisateurs')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rôle :', style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  value: selectedRole,
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                      if (selectedRole == 'Enseignant') {
                        selectedClassesForTeacher = [];
                      }
                    });
                  },
                  items: ['Étudiant', 'Enseignant']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (selectedRole == 'Étudiant')
              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Classe',
                  prefixIcon: Icon(Icons.class_),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedClass = value!;
                  });
                },
                items: classesList
                    .map((classe) => DropdownMenuItem(
                          value: classe,
                          child: Text(classe),
                        ))
                    .toList(),
              ),
            if (selectedRole == 'Enseignant') ...[
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Matière à enseigner',
                  prefixIcon: Icon(Icons.book),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Classes à enseigner :', style: TextStyle(fontSize: 16)),
              Wrap(
                spacing: 8.0,
                children: classesList
                    .map(
                      (classe) => FilterChip(
                        label: Text(classe),
                        selected: selectedClassesForTeacher.contains(classe),
                        onSelected: (isSelected) {
                          setState(() {
                            if (isSelected) {
                              selectedClassesForTeacher.add(classe);
                            } else {
                              selectedClassesForTeacher.remove(classe);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await _addUser(context);
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addUser(BuildContext context) async {
    try {
      // Créez un utilisateur avec Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Préparation des données utilisateur
      Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': selectedRole,
        'createdAt': DateTime.now().toIso8601String(),
      };

      if (selectedRole == 'Étudiant') {
        userData['class'] = selectedClass; // Ajouter la classe pour l'étudiant
      } else if (selectedRole == 'Enseignant') {
        userData['subject'] = _subjectController.text.trim(); // Matière
        userData['classes'] = selectedClassesForTeacher; // Classes enseignées
      }

      // Ajoutez les informations de l'utilisateur dans Firebase Realtime Database
      await _databaseRef.child(userCredential.user!.uid).set(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur ajouté avec succès')),
      );

      // Réinitialiser les champs
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _subjectController.clear();
      setState(() {
        selectedRole = 'Étudiant';
        selectedClass = 'GI3S1';
        selectedClassesForTeacher = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }
}
