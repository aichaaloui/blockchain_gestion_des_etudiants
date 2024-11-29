import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ViewUsersPage extends StatelessWidget {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("users");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des utilisateurs')),
      body: FutureBuilder<DataSnapshot>(
        future: _databaseRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.value == null) {
            return Center(child: Text('Aucun utilisateur trouvé'));
          }

          Map<dynamic, dynamic> usersMap = snapshot.data!.value as Map<dynamic, dynamic>;
          List<Widget> userWidgets = usersMap.entries.map((entry) {
            var user = entry.value;
            return Card(
              child: ListTile(
                title: Text('${user['name']} (${user['role']})'),
                subtitle: Text('Email : ${user['email']}'),
              ),
            );
          }).toList();

          return ListView(children: userWidgets);
        },
      ),
    );
  }
}
