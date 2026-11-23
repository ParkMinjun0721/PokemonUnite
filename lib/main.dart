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

  await initializeAndRunApp();
}

Future<void> initializeAndRunApp() async {
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
    runApp(AppStartupError(error: error, onRetry: initializeAndRunApp));
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

class AppStartupError extends StatefulWidget {
  final Object error;
  final Future<void> Function()? onRetry;

  const AppStartupError({super.key, required this.error, this.onRetry});

  @override
  State<AppStartupError> createState() => _AppStartupErrorState();
}

class _AppStartupErrorState extends State<AppStartupError> {
  bool isRetrying = false;
  late Object currentError;

  @override
  void initState() {
    super.initState();
    currentError = widget.error;
  }

  @override
  void didUpdateWidget(covariant AppStartupError oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.error != widget.error) {
      currentError = widget.error;
    }
  }

  Future<void> retry() async {
    final onRetry = widget.onRetry;

    if (onRetry == null || isRetrying) {
      return;
    }

    setState(() {
      isRetrying = true;
    });

    try {
      await onRetry();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        currentError = error;
      });
    }

    if (!mounted) {
      return;
    }

    setState(() {
      isRetrying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '포켓몬 유나이트 내전 프로그램',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(title: const Text('포켓몬 유나이트 내전 프로그램')),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      Icon(
                        Icons.cloud_off,
                        size: 56,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '앱 설정을 불러오지 못했습니다.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '네트워크 상태를 확인한 뒤 다시 시도해주세요.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: widget.onRetry == null || isRetrying
                              ? null
                              : retry,
                          icon: isRetrying
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(isRetrying ? '다시 시도 중' : '다시 시도'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '오류 상세',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.48),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: SelectableText('$currentError'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
