# PokemonUnite 내전 프로그램

포켓몬유나이트 내전 프로그램
서클은? 고양이발바닥

[웹버전 접속 링크](https://pokemonunite-e97fa.web.app/)

# 🧰 Getting Started
1. Make sure Git and Flutter is installed.
2. Clone this repository to your local computer.
3. Create .env file in root directory.
4. Contents of .env:
<pre>
<code>
API_KEY=XXXXXXXXXXXXXXXXXXXXXXXXX
AUTH_DOMAIN=XXXXXXXXXXX.firebaseapp.com
PROJECT_ID=XXXXXXXXXXXXXXX
STORAGE_BUCKET=XXXXXXXXXXXXX.appspot.com
MESSAGING_SENDER_ID=XXXXXXXXXXX
APP_ID=1:XXXXXXXXXXXXX:web:XXXXXXXXXXXXXX
</code>
</pre>

## Git 관리

git add .

git commit -m “[Feat] commit messages (edit date)”

feat : 새로운 기능 추가, 기존의 기능을 요구 사항에 맞추어 수정  
fix : 기능에 대한 버그 수정  
build : 빌드 관련 수정  
chore : 패키지 매니저 수정, 그 외 기타 수정 ex) .gitignore  
docs : 문서(주석) 수정  
style : 코드 스타일, 포맷팅에 대한 수정  
refactor : 기능의 변화가 아닌 코드 리팩터링 ex) 변수 이름 변경  
release : 버전 릴리즈
merge : 병합

git pull origin master

## Web Hosting

flutter clean  
flutter pub get  
flutter build web  
firebase deploy  