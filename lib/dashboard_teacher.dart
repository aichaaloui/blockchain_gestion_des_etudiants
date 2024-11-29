import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DashboardTeacher extends StatelessWidget {
  final String teacherId;

  DashboardTeacher({required this.teacherId});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("users");

    return Scaffold(
      appBar: AppBar(title: Text('Tableau de bord enseignant')),
      body: FutureBuilder<DataSnapshot>(
        future: _databaseRef.child(teacherId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.value == null) {
            return Center(child: Text('Aucune donnée disponible'));
          }

          // Récupérer les classes enseignées par le professeur
          var teacher = snapshot.data!.value as Map<dynamic, dynamic>;
          List<dynamic> teacherClasses = teacher['classes'] ?? [];

          return FutureBuilder<DataSnapshot>(
            future: _databaseRef.orderByChild("role").equalTo("Étudiant").get(),
            builder: (context, studentsSnapshot) {
              if (studentsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (studentsSnapshot.hasError) {
                return Center(child: Text('Erreur : ${studentsSnapshot.error}'));
              }

              if (!studentsSnapshot.hasData || studentsSnapshot.data!.value == null) {
                return Center(child: Text('Aucun étudiant trouvé'));
              }

              Map<dynamic, dynamic> studentsMap = studentsSnapshot.data!.value as Map<dynamic, dynamic>;

              // Filtrer les étudiants par les classes enseignées
              List<Widget> studentWidgets = studentsMap.entries
                  .where((entry) => teacherClasses.contains(entry.value['class']))
                  .map((entry) {
                    var student = entry.value;
                    return Card(
                      child: ListTile(
                        title: Text(student['name']),
                        //subtitle: Text('Email : ${student['email']}\nClasse : ${student['class']}'),
                      ),
                    );
                  })
                  .toList();

              return ListView(children: studentWidgets);
            },
          );
        },
      ),
    );
  }
}
