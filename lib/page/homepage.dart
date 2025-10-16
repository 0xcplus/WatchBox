import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              color: Colors.blueGrey[900],
              child: Column(
                children: [
                  // Logo
                  kIsWeb
                    ? Image.network(
                        'watchbox.png', // GitHub Pages에 복사한 build/web 경로 기준
                        width: 180,
                    )
                    : Image.asset(
                        'assets/images/watchbox.png', // 앱/모바일용 로컬 에셋
                        width: 180,
                    ),
                  const SizedBox(height: 20),

                  // Headline
                  const Text(
                    "WatchBox\n용접 결함 검출 AI 모델",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "눈으로 찾아내기 어려운 결함,\n일일이 확인해야 할까?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // App Description Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "앱 소개",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "어디서든 쉽고 빠르게, 활용 가능한 앱입니다. "
                        "Ultralytics Yolov11 모델을 활용하여 알루미늄·강재에 대한 "
                        "육안 및 방사능 검사 이미지를 학습하고, "
                        "용접 부위의 결함을 탐지하고 분류합니다.",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Project Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "프로젝트 정보",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "동남권ICT 이노베이션스퀘이션스퀘어 2025 부트캠프 프로젝트의 일환입니다. "
                        "용접 결함을 탐지, 분류하여 사전에 신속한 조치를 취할 수 있도록 하는 애플리케이션입니다.",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Data Source Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "데이터 출처",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                         "이 연구는 과학기술정보통신부의 재원으로 한국지능정보사회진흥원의 지원을 받아 구축된 \"창원 지역 특화산업 고도화 및 디지털 전환 촉진을 위한 용접 AI 학습 데이터 구축\"을 활용하여 수행되었습니다.\n"
                        "본 연구에 활용된 데이터는 AI 허브(aihub.or.kr)에서 다운로드 받으실 수 있습니다.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.blueGrey[900],
              child: const Center(
                child: Text(
                  "© 2025 WatchBox.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}