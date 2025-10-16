import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../index/standard.dart';
import '../openai/openai.dart';
import '../function/weldingdefects.dart';

class ImageUploadArea extends StatefulWidget {
  const ImageUploadArea({super.key});

  @override
  State<ImageUploadArea> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadArea> {
  Uint8List? _imageBytes;
  String? _selectedDataset;
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  // Flask 서버 주소
  final String flaskUrl =
      "https://watchbox-20924868085.asia-northeast3.run.app/predict";

  // 데이터셋 옵션
  final datasetOptions = const {
    'RTAL': '방사선 검사 | 알루미늄',
    'RTST': '방사선 검사 | 강재',
    'VTST': '육안 검사 | 강재',
  };

  // ✅ ChatGPT 스트림 컨트롤러 (재분석 시 안전하게 새로 생성)
  StreamController<String>? chatStreamController;

  @override
  void initState() {
    super.initState();
    chatStreamController = StreamController<String>.broadcast();
  }

  /// 파일 선택
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
      });
    }
  }

  /// Flask 서버로 이미지 + 데이터셋 전송
  Future<void> _uploadAndAnalyze() async {
    if (_imageBytes == null || _selectedDataset == null) {
      debugPrint('⚠️ 이미지 또는 데이터셋이 선택되지 않음.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지와 데이터셋을 선택해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final request = http.MultipartRequest('POST', Uri.parse(flaskUrl))
        ..fields['dataset'] = _selectedDataset!
        ..files.add(http.MultipartFile.fromBytes('image', _imageBytes!,
            filename: 'input.jpg'));

      debugPrint('📤 Flask 서버에 요청 전송 중...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint('✅ Flask 응답 수신 완료: ${jsonData.keys}');

        setState(() {
          _result = jsonData;
        });

        // ✅ YOLO 분석 결과가 도착하면 ChatGPT 자동 실행
        final detectedObjects = _result?['results'];
        if (detectedObjects != null && detectedObjects is List) {
          debugPrint('🤖 ChatGPT 분석 시작...');
          analyzeAndChat(detectedObjects);
        } else {
          debugPrint('⚠️ Flask 결과에 results 필드가 없음.');
          if (!chatStreamController!.isClosed) {
            chatStreamController!.add('❌ 결과 데이터가 올바르지 않습니다.');
          }
        }
      } else {
        debugPrint('❌ Flask 오류: ${response.statusCode} ${response.body}');
        if (!chatStreamController!.isClosed) {
          chatStreamController!.add('❌ Flask 서버 오류 (${response.statusCode})');
        }
      }
    } catch (e) {
      debugPrint('🚨 Flask 요청 중 오류 발생: $e');
      if (!chatStreamController!.isClosed) {
        chatStreamController!.add('❌ 서버 통신 오류: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ChatGPT 분석 호출
  void analyzeAndChat(List detectedObjects) {
    // 이전 스트림이 닫혔거나 null이면 새로 생성
    if (chatStreamController == null || chatStreamController!.isClosed) {
      chatStreamController = StreamController<String>.broadcast();
    }

    try {
      String prompt = conclusionReturn(detectedObjects);
      debugPrint('📜 ChatGPT Prompt: $prompt');

      fetchStreamedResponse(prompt, 'initGPT', chatStreamController!);
    } catch (e) {
      debugPrint('💥 ChatGPT 분석 중 오류 발생: $e');
      if (!chatStreamController!.isClosed) {
        chatStreamController!.add('❌ ChatGPT 분석 중 오류 발생: $e');
      }
    }
  }

  @override
  void dispose() {
    chatStreamController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final annotatedImageBase64 = _result?['annotated_image'];
    final detectedObjects = _result?['results'];

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 이미지 업로드 영역
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 400,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imageBytes == null
                      ? const Center(
                          child: Text("클릭하여 이미지를 업로드하세요"),
                        )
                      : FittedBox(
                          fit: BoxFit.contain,
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // 데이터셋 선택
              Column(
                children: datasetOptions.entries.map((entry) {
                  return RadioListTile<String>(
                    title: Text("${entry.key} — ${entry.value}"),
                    value: entry.key,
                    groupValue: _selectedDataset,
                    onChanged: (v) => setState(() => _selectedDataset = v),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 분석 버튼
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _uploadAndAnalyze,
                icon: const Icon(Icons.analytics),
                label: Text(_isLoading ? "분석 중..." : "YOLO 분석 실행"),
              ),

              const SizedBox(height: 30),

              // 결과 이미지 및 데이터
              if (_result != null)
                Column(
                  children: [
                    const Text("🔍 분석 결과 이미지",
                        style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    if (annotatedImageBase64 != null)
                      Image.memory(base64Decode(annotatedImageBase64),
                          width: 400),
                    const SizedBox(height: 20),
                    if (detectedObjects != null)
                      Text(
                        conclusionReturn(detectedObjects),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                )
              else
                const Text(
                  '아직 분석 결과가 없습니다.',
                  style: TextStyle(color: Colors.grey),
                ),

              const SizedBox(height: 20),

              // ChatGPT 출력
              if (_result != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🤖 ChatGPT 분석 결과",
                      style: initTextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<String>(
                      stream: chatStreamController?.stream,
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'AI 분석 대기 중...',
                          style: initTextStyle(fontSize: 18),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}