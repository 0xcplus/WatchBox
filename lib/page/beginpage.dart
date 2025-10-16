import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'homepage.dart';
import 'imageuploadpage.dart';
import '../index/standard.dart';

// 지정
String url = 'https://github.com/0xcplus/WatchBox/';
Color infLinkColor = const Color.fromARGB(255, 126, 141, 134);

// 페이지 구성
class BeginPage extends StatefulWidget {
  const BeginPage({super.key, required this.title});
  final String title;

  @override
  State<BeginPage> createState() => _BeginPageState();
}

class _BeginPageState extends State<BeginPage> {
  int _selectedIndex = 1; // 초기 페이지: 분석
  final List<Widget> _pages = [HomePage(), ImageUploadPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer 유지
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [initShadowSetting()],
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/watchbox.png'),
                  backgroundColor: Colors.white70,
                ),
              ),
              accountName: Text(
                'WatchBox',
                style: initTextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 40, 40, 40)),
              ),
              accountEmail: MouseRegion(
                onEnter: (_) {
                  setState(() {
                    infLinkColor = const Color.fromARGB(255, 61, 55, 148);
                  });
                },
                onExit: (_) {
                  setState(() {
                    infLinkColor = const Color.fromARGB(255, 126, 141, 134);
                  });
                },
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    final Uri uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Text(
                    url,
                    style: initTextStyle(
                      fontSize: 18,
                      color: infLinkColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 93, 238, 204),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                boxShadow: [initShadowSetting(spreadRadius: 3, blurRadius: 5)],
              ),
            ),

            const SizedBox(height: 10),

            // Drawer 내 메뉴 (선택 옵션)
            ListTile(
              leading: const Icon(Icons.home, color: Colors.black87),
              title: Text('홈', style: initTextStyle(fontSize: 18)),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
              trailing: const Icon(Icons.navigate_next),
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.black87),
              title: Text('분석', style: initTextStyle(fontSize: 18)),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
              trailing: const Icon(Icons.navigate_next),
            ),
          ],
        ),
      ),

      // 본문
      body: SafeArea(
        child: Column(
          children: [
            // 페이지 제목
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              color: const Color.fromARGB(255, 53, 53, 53),
              child: Text(
                _selectedIndex == 0 ? '홈' : '분석',
                style: initTextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      ),

      // 하단 내비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueGrey[900],
        unselectedItemColor: Colors.grey[500],
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '분석',
          ),
        ],
      ),
    );
  }
}