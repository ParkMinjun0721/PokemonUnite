import 'package:flutter/material.dart';
import 'package:pokemonbattle/pokemon/playername.dart';
import 'package:pokemonbattle/team/teamassign.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 화면의 크기를 가져옵니다.
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('포켓몬 유나이트 내전 프로그램')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: screenWidth,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 400,
                    child: Image.asset('images/suzy3.jpeg'),
                  ),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: const SelectableText(
                      '모바일 기준으로 제작했습니다.\n'
                          '핸드폰 정도의 화면 비율로 바꾸시면 쾌적하게 이용하실 수 있습니다.\n'
                          'Made by 님블\n'
                          '오류/문의 : pmjunasd@gmail.com',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 15),
                  // 버튼 레이아웃 조정
                  Wrap(
                    spacing: screenWidth > 400 ? 100 : 20, // 버튼 간의 가로 간격
                    runSpacing: screenWidth > 400 ? 100 : 20, // 버튼 간의 세로 간격
                    alignment: WrapAlignment.center,
                    children: [
                      _buildButton(
                        context,
                        color: Colors.green,
                        label: '팀 랜덤 배정',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeamAssignmentPage(),
                            ),
                          );
                        },
                      ),
                      _buildButton(
                        context,
                        color: Colors.blue,
                        label: '포켓몬 랜덤 선택',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerNamePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required Color color,
        required String label,
        required VoidCallback onTap}) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: screenWidth > 400 ? 150 : screenWidth * 0.4, // 화면 너비에 따라 버튼 크기 조정
        height: screenWidth > 400 ? 150 : screenWidth * 0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: color,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: screenWidth > 400 ? 20 : 15,),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
