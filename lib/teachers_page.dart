import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TeachersPage extends StatelessWidget {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("users");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des enseignants')),
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

          Map<dynamic, dynamic> teachersMap = snapshot.data!.value as Map<dynamic, dynamic>;
          List<Widget> teacherWidgets = teachersMap.entries.map((entry) {
            var teacher = entry.value;
            return Card(
              child: ListTile(
                title: Text(teacher['name']),
                subtitle: Text('Email : ${teacher['email']}\nMatières : ${teacher['subject']}\nClasses : ${teacher['classes']?.join(", ") ?? "Non spécifiées"}'),
              ),
            );
          }).toList();

          return ListView(children: teacherWidgets);
        },
      ),
    );
  }
}
