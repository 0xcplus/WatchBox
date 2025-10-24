//flutter & dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//openai
import 'package:dart_openai/dart_openai.dart';

//etc.
import 'openai/apikeyfetch.dart'; //'env/env.dart';
import 'page/beginpage.dart';
import 'index/standard.dart';

// Flask 서버 활성화
Future<void> pingServer() async {
  const String flaskUrl = "https://watchbox-20924868085.asia-northeast3.run.app/start"; // 실제 Flask 서버 주소로 변경

  try {
    final response = await http.get(Uri.parse(flaskUrl));
    if (response.statusCode == 200) {
      print('✅ Flask 서버 활성화 성공');
    } else {
      print('⚠️ Flask 서버 응답 코드: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Flask 서버 깨우기 실패: $e');
  }
}

//favicon.png
Future<String> fetchApiKey() async {
  final response = await http.get(Uri.parse('https://solar-liart.vercel.app/api/getApiKey'));
  
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return jsonResponse['apiKey'];
  } else {
    throw Exception('Failed to load API key');
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Flask 서버 활성화
    await pingServer();

    // OpenAI 키 설정
    OpenAI.apiKey = await returnApiKey();

    // 준비 완료 시 다음 화면으로 전환
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              "서버를 준비 중입니다...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WatchBox',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 70, 70, 70),
          brightness: Brightness.light, // 라이트 모드
        ).copyWith(
          primary: const Color.fromARGB(255, 71, 71, 71), // 주 테마 색상
          onPrimary: Colors.white, // 주 테마 색상의 대비 텍스트
          secondary: const Color.fromARGB(255, 100, 241, 171), // 보조 색상
          onSecondary: const Color.fromARGB(255, 242, 242, 242), // 보조 색상의 대비 텍스트
          surface: const Color.fromARGB(255, 238, 238, 238), // 표면 색상 (카드, 모달 등)
          onSurface: Colors.black, // 표면 색상에 쓰일 텍스트 색상
          error: const Color.fromARGB(255, 231, 141, 135), // 에러 색상
          onError: Colors.white, // 에러 색상의 대비 텍스트
        ),
        useMaterial3: false, // Material 3 스타일 사용

        // 기본 텍스트 스타일
        textTheme: TextTheme(
          bodyLarge: initTextStyle(),
        ),
      ),

      home: const BeginPage(title: 'ICT프로젝트'),
    );
  }
}