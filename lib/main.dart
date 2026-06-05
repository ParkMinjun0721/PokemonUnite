import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pokemonbattle/home.dart';
import 'package:pokemonbattle/theme/app_theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, String>> fetchEnv() async {
  final response = await http.get(
    Uri.parse(
      'https://us-central1-pokemonunite-e97fa.cloudfunctions.net/getEnv',
    ),
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

  try {
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

    runApp(const ProviderScope(child: MyApp()));
  } catch (error) {
    runApp(AppStartupError(error: error));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '포켓몬 유나이트 내전 프로그램',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}

class AppStartupError extends StatelessWidget {
  final Object error;

  const AppStartupError({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '포켓몬 유나이트 내전 프로그램',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(title: const Text('포켓몬 유나이트 내전 프로그램')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_off,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '앱 설정을 불러오지 못했습니다.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text('$error', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
