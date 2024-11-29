import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase avec les paramètres fournis
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyD_WnQtwJeD6cxUP3zHXRzymn9s4_BKt20",
      authDomain: "blockchainproject-263e5.firebaseapp.com",
      databaseURL: "https://blockchainproject-263e5-default-rtdb.firebaseio.com",
      projectId: "blockchainproject-263e5",
      storageBucket: "blockchainproject-263e5.appspot.com",
      messagingSenderId: "231250951381",
      appId: "1:231250951381:web:e1264d5eef72902126765c",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Présences',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}
