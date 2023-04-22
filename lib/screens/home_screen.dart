import 'package:flutter/material.dart';
import 'package:toonflix/models/webtoon_model.dart';
import 'package:toonflix/services/api_service.dart';
import 'package:toonflix/widgets/webtoon_widget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final Future<List<WebtoonModel>> webtoons = ApiService.getTodaysToons();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          "오늘의 웹툰!",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      body: FutureBuilder(
        future: webtoons,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Expanded(child: makeList(snapshot))
              ],
            );
          }
          return const Center(
            // 값이 없을때 로딩 중 원형 프로그래스 이미지 출력
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  ListView makeList(AsyncSnapshot<List<WebtoonModel>> snapshot) {
    return ListView.separated(
      // 아이템들을 가로 스크롤 하게 해주는 명령어
      scrollDirection: Axis.horizontal,

      // 아이템 총량을 계산해주는 명령어, itemBuilder 에 인자로 넘긴다.
      itemCount: snapshot.data!.length,

      // 썸네일 이미지에 padding 간격을 준다.
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),

      // itemCount 값을 받아 스크롤을 생성해 주는 명령어
      itemBuilder: (context, index) {
        var webtoon = snapshot.data![index];

        // 아이템 목록을 텍스트로 리턴 받는다
        return Webtoon(
          title: webtoon.title,
          thumb: webtoon.thumb,
          id: webtoon.id,
        );
      },
      // 아이템들 사이에 구분자를 넣어주는 빌더
      separatorBuilder: (context, index) => const SizedBox(
        width: 40,
      ),
    );
  }
}
