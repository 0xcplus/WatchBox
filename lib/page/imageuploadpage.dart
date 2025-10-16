import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../openai/openai.dart';
import '../function/weldingdefects.dart';

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  Uint8List? _imageBytes;
  String? _selectedDataset;
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  final String flaskUrl =
      "https://watchbox-20924868085.asia-northeast3.run.app/predict";

  final datasetOptions = const {
    'RTAL': '방사선 검사 | 알루미늄',
    'RTST': '방사선 검사 | 강재',
    'VTST': '육안 검사 | 강재',
  };

  StreamController<String>? chatStreamController;

  @override
  void initState() {
    super.initState();
    chatStreamController = StreamController<String>.broadcast();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
      });
    }
  }

  Future<void> _uploadAndAnalyze() async {
    if (_imageBytes == null || _selectedDataset == null) {
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

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() => _result = jsonData);

        final detectedObjects = _result?['results'];
        if (detectedObjects != null && detectedObjects is List) {
          analyzeAndChat(detectedObjects);
        } else {
          if (!chatStreamController!.isClosed) {
            chatStreamController!.add('❌ 결과 데이터가 올바르지 않습니다.');
          }
        }
      } else {
        if (!chatStreamController!.isClosed) {
          chatStreamController!.add('❌ Flask 서버 오류 (${response.statusCode})');
        }
      }
    } catch (e) {
      if (!chatStreamController!.isClosed) {
        chatStreamController!.add('❌ 서버 통신 오류: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void analyzeAndChat(List detectedObjects) {
    if (chatStreamController == null || chatStreamController!.isClosed) {
      chatStreamController = StreamController<String>.broadcast();
    }

    try {
      String prompt = conclusionReturn(detectedObjects);
      fetchStreamedResponse(prompt, 'initGPT', chatStreamController!);
    } catch (e) {
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
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이미지 업로드 섹션
            Card(
              elevation: 4,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: _imageBytes == null
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 60),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: const Center(
                                child: Text(
                                  "클릭하여 이미지를 업로드하세요",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    _imageBytes!,
                                    fit: BoxFit.contain,
                                    width: constraints.maxWidth,
                                    // height는 자동 조정되어 aspect ratio 유지
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _uploadAndAnalyze,
                      icon: const Icon(Icons.analytics),
                      label: Text(_isLoading ? "분석 중..." : "YOLO 분석 실행"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 분석 결과 이미지
            if (_result != null && annotatedImageBase64 != null)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "🔍 분석 결과 이미지",
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(annotatedImageBase64),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // 분석 결과 텍스트
            if (_result != null && detectedObjects != null)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "📄 YOLO 분석 결과",
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        conclusionReturn(detectedObjects),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ChatGPT 출력
            if (_result != null)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "🤖 ChatGPT 분석 결과",
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<String>(
                        stream: chatStreamController?.stream,
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'AI 분석 대기 중...',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}