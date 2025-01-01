import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pokemonbattle/home.dart';


void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: 'AIzaSyCH6czBKZhaGWMM_Rc7H0FjJIYi1vFVDFI',
          authDomain: 'pokemonunite-e97fa.firebaseapp.com',
          projectId: 'pokemonunite-e97fa',
          storageBucket: 'pokemonunite-e97fa.appspot.com',
          messagingSenderId: '871843847800',
          appId: '1:871843847800:web:974b66fb5a40842458978d',
        )
    );
    runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '포켓몬유나이트 내전 프로그램(냥발 최고)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
