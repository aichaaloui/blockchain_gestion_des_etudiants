import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DashboardStudent extends StatelessWidget {
  final String studentId;

  DashboardStudent({required this.studentId});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("users");

    return Scaffold(
      appBar: AppBar(title: Text('Tableau de bord étudiant')),
      body: FutureBuilder<DataSnapshot>(
        future: _databaseRef.orderByChild("role").equalTo("Enseignant").get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.value == null) {
            return Center(child: Text('Aucun enseignant trouvé'));
          }

          // Corrige la typage de la Map
          final teachersMap = Map<String, dynamic>.from(snapshot.data!.value as Map);

          // Récupérer toutes les matières enseignées en s'assurant que le type est String
          final subjects = teachersMap.values
              .where((teacher) =>
                  teacher is Map && teacher['subject'] != null && teacher['subject'] is String)
              .map((teacher) => (teacher as Map)['subject'] as String)
              .toSet()
              .toList();

          return ListView(
            children: [
              ListTile(
                title: Text('Matières étudiées :'),
                subtitle: Text(subjects.join(", ")),
              ),
            ],
          );
        },
      ),
    );
  }
}
