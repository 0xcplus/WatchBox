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

String errorFind = "";

Future<void> main() async{
  //WidgetsFlutterBinding.ensureInitialized();
  await pingServer();
  OpenAI.apiKey = await returnApiKey();
  runApp(const MyApp());
}

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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