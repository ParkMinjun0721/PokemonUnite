import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pokemonbattle/home.dart';
import 'package:pokemonbattle/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load();

  // .env 파일 로드 확인
  if (dotenv.isEveryDefined(['API_KEY', 'AUTH_DOMAIN', 'PROJECT_ID', 'STORAGE_BUCKET', 'MESSAGING_SENDER_ID', 'APP_ID'])) {
    print('환경 변수 로드 성공:');
    print('API_KEY: ${dotenv.env['API_KEY']}');
    print('AUTH_DOMAIN: ${dotenv.env['AUTH_DOMAIN']}');
  } else {
    print('환경 변수 로드 실패. .env 파일을 확인하세요.');
  }

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['API_KEY'] ?? '',
      authDomain: dotenv.env['AUTH_DOMAIN'] ?? '',
      projectId: dotenv.env['PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['STORAGE_BUCKET'] ?? '',
      messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
      appId: dotenv.env['APP_ID'] ?? '',
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
