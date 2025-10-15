import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  // Flask 서버 주소 (현재 로컬에서 실행 중)
  final String flaskUrl = "https://watchbox-20924868085.asia-northeast3.run.app/predict"; //"http://192.168.0.6:8080/predict";

  // 데이터셋 옵션 
  final datasetOptions = const {
    'RTAL': '방사선 검사 | 알루미늄',
    'RTST': '방사선 검사 | 강재',
    'VTST': '육안 검사  강재',
  };

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
    if (_imageBytes == null || _selectedDataset == null) return;

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
        setState(() {
          _result = jsonData;
        });
      } else {
        debugPrint('Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    } finally {
      print("완료");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final annotatedImageBase64 = _result?['annotated_image'];
    final detectedObjects = _result?['results'];
    //final hasImage = _imageBytes != null;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 1️⃣ 이미지 업로드 영역
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
                          child: Text(
                            "클릭하여 이미지를 업로드하세요",
                            textAlign: TextAlign.center,
                          ),
                        )
                      : FittedBox(
                        fit:BoxFit.contain,
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover)
                      ) 
                ),
              ),
              const SizedBox(height: 24),

              // 2️⃣ 데이터셋 선택 라디오 버튼
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

              // 3️⃣ 분석 버튼
              ElevatedButton.icon(
                onPressed:
                    _isLoading ? null : (_selectedDataset != null ? _uploadAndAnalyze : null),
                icon: const Icon(Icons.analytics),
                label: Text(_isLoading ? "분석 중..." : "YOLO 분석 실행"),
              ),

              const SizedBox(height: 30),

              // 4️⃣ 결과 이미지 및 데이터 표시
              if (annotatedImageBase64 != null)
                Column(
                  children: [
                    const Text("🔍 분석 결과 이미지", style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Image.memory(base64Decode(annotatedImageBase64), width: 400),
                    const SizedBox(height: 20),
                    Text(
                      jsonEncode(detectedObjects),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
