import 'package:flutter/material.dart';
import 'pokemon_category_page.dart'; // 카테고리 선택 페이지로 이동하기 위해 불러옴

class PlayerNamePage extends StatefulWidget {
  @override
  _PlayerNamePageState createState() => _PlayerNamePageState();
}

class _PlayerNamePageState extends State<PlayerNamePage> {
  List<String> players = List.filled(10, ''); // 10명의 플레이어 이름 저장

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('플레이어 이름 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 왼쪽에 1팀의 이름을 입력하는 컬럼
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          players[index] = value; // 1팀 플레이어 이름 입력
                        });
                      },
                      decoration: InputDecoration(
                        hintText: '1팀 참가자 ${index + 1} 이름 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(width: 20), // 좌우 간격
            // 오른쪽에 2팀의 이름을 입력하는 컬럼
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          players[index + 5] = value; // 2팀 플레이어 이름 입력
                        });
                      },
                      decoration: InputDecoration(
                        hintText: '2팀 참가자 ${index + 1} 이름 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: players.every((name) => name.isNotEmpty) ? () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => PokemonCategoryPage(players: players)
          ));
        } : null,
        child: Icon(Icons.navigate_next),
      ),
    );
  }
}
