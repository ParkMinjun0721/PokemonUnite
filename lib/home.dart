import 'package:flutter/material.dart';
import 'package:pokemonbattle/pokemon/playername.dart';
import 'package:pokemonbattle/pokemon/pokemonassign.dart';
import 'package:pokemonbattle/team/teamassign.dart';
import 'pokemon/pokemon_category_page.dart';

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
                child: Text('큰 화면으로 볼 시 불편할 수 있습니다.\n'
                    '핸드폰 정도의 화면 비율로 바꾸시면 쾌적하게 이용하실 수 있습니다.\n'
                    'Made by 님블\n')
            ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TeamAssignmentPage()));
                  },
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.green,),
                    width: 150,
                    height: 150,
                    child: Center(
                      child: const Text('팀 랜덤 배정', style: TextStyle(color: Colors.white, fontSize: 20),),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerNamePage()));
                  },
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.blue,),
                    width: 150,
                    height: 150,
                    child: Center(
                      child: const Text('포켓몬 랜덤 선택', style: TextStyle(color: Colors.white, fontSize: 20)),
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
