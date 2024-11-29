import 'package:flutter/material.dart';
import 'manage_users.dart';
import 'view_users.dart';
import 'teachers_page.dart';
import 'students_page.dart';
import 'logout.dart';

class DashboardAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tableau de bord administration')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue administrateur !',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageUsers()),
                );
              },
              child: Text('Gérer les utilisateurs'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewUsersPage()),
                );
              },
              child: Text('Voir les utilisateurs'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeachersPage()),
                );
              },
              child: Text('Liste des professeurs'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentsPage()),
                );
              },
              child: Text('Liste des étudiants'),
            ),
            SizedBox(height: 20),
            LogoutButton(), // Bouton de déconnexion
          ],
        ),
      ),
    );
  }
}
