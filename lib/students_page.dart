import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StudentsPage extends StatelessWidget {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("users");

  Future<List<Map<String, dynamic>>> _fetchStudentsWithSubjects() async {
    // Récupérer les étudiants
    DataSnapshot studentsSnapshot =
        await _databaseRef.orderByChild("role").equalTo("Étudiant").get();
    DataSnapshot teachersSnapshot =
        await _databaseRef.orderByChild("role").equalTo("Enseignant").get();

    // Vérifier si les données existent
    if (studentsSnapshot.value == null || teachersSnapshot.value == null) {
      return [];
    }

    // Convertir les snapshots en Map
    Map<dynamic, dynamic> studentsMap = studentsSnapshot.value as Map<dynamic, dynamic>;
    Map<dynamic, dynamic> teachersMap = teachersSnapshot.value as Map<dynamic, dynamic>;

    // Extraire les matières des enseignants
    List<String> allSubjects = teachersMap.entries
        .map((entry) => entry.value['subject'] as String)
        .where((subject) => subject != null)
        .toList();

    // Ajouter les matières aux étudiants
    List<Map<String, dynamic>> studentsWithSubjects = studentsMap.entries.map((entry) {
      var student = entry.value as Map<dynamic, dynamic>;
      return {
        "name": student['name'],
        "email": student['email'],
        "class": student['class'],
        "subjects": allSubjects, // Ajouter toutes les matières des enseignants
      };
    }).toList();

    return studentsWithSubjects;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des étudiants')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchStudentsWithSubjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun étudiant trouvé'));
          }

          List<Widget> studentWidgets = snapshot.data!.map((student) {
            return Card(
              child: ListTile(
                title: Text(student['name']),
                subtitle: Text(
                  'Email : ${student['email']}\nClasse : ${student['class']}\nMatières : ${student['subjects'].join(", ")}',
                ),
              ),
            );
          }).toList();

          return ListView(children: studentWidgets);
        },
      ),
    );
  }
}
