import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pokemonbattle/home.dart';
import 'package:pokemonbattle/theme/app_theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, String>> fetchEnv() async {
  final response = await http.get(
    Uri.parse('https://us-central1-pokemonunite-e97fa.cloudfunctions.net/getEnv'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  } else {
    throw Exception('Failed to load environment variables');
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드
  final env = await fetchEnv();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: env['apiKey']!,
      authDomain: env['authDomain']!,
      projectId: env['projectId']!,
      storageBucket: env['storageBucket']!,
      messagingSenderId: env['messagingSenderId']!,
      appId: env['appId']!,
    ),
  );

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '포켓몬 유나이트 내전 프로그램',
      theme: AppTheme.lightTheme,
      home: HomePage(),
    );
  }
}
