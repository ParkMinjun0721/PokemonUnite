import 'package:flutter/material.dart';
import 'package:pokemonbattle/pokemon/playername.dart';
import 'package:pokemonbattle/team/teamassign.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('포켓몬 유나이트 내전 프로그램')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400,
                child: Image.asset('images/suzy3.jpeg')
            ),
            SizedBox(height: 15,),
            Container(
                child: const SelectableText('모바일 기준으로 제작했습니다.\n'
                    '핸드폰 정도의 화면 비율로 바꾸시면 쾌적하게 이용하실 수 있습니다.\n'
                    'Made by 님블\n'
                    '오류/문의 : pmjunasd@gmail.com'
                )
            ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TeamAssignmentPage()));
                  },
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.green,),
                    width: 150,
                    height: 150,
                    child: const Center(
                      child: Text('팀 랜덤 배정', style: TextStyle(color: Colors.white, fontSize: 20),),
                    ),
                  ),
                ),
                SizedBox(width: 100,),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerNamePage()));
                  },
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.blue,),
                    width: 150,
                    height: 150,
                    child: const Center(
                      child: Text('포켓몬 랜덤 선택', style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
