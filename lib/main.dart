import 'package:dietapp/data/data.dart';
import 'package:dietapp/style.dart';
import 'package:dietapp/utils.dart';
import 'package:dietapp/view/body.dart';
import 'package:dietapp/view/food.dart';
import 'package:dietapp/view/workout.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: getPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 선택 화면창 만들기
          showModalBottomSheet(
              context: context,
              backgroundColor: bgColor,
              builder: (context) {
                return SizedBox(
                  height: 250,
                    child: Column(
                      children: [
                        TextButton(
                            child: Text("식단"),
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => FoodAddPage(
                                  // 새로 만든 food를 불러준다.
                                  food: Food(
                                    date: Utils.getFormatTime(DateTime.now()),
                                    kcal: 0,
                                    memo: "",
                                    type: 0,
                                    meal: 0,
                                    image: "",
                                    time: 1130,
                                  ),
                                ),)
                              );
                            },
                        ),
                        TextButton(
                          child: Text("운동"),
                          onPressed: () async {
                            await Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => WorkoutAddPage(
                                  // 새로 만든 workout을 불러준다.
                                  workout: Workout(
                                    date: Utils.getFormatTime(DateTime.now()),
                                    time: 60,
                                    type: 0,
                                    kcal: 0,
                                    intense: 0,
                                    part: 0,
                                    distance: 0,
                                    name: "",
                                    memo: "",
                                  ),
                                ),)
                            );
                          },
                        ),
                        TextButton(
                          child: Text("몸무게"),
                          onPressed: () {

                          },
                        ),
                        TextButton(
                          child: Text("눈바디"),
                          onPressed: () async {
                            await Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => EyeBodyAddPage(
                                  // 새로 만든 workout을 불러준다.
                                  body: EyeBody(
                                    date: Utils.getFormatTime(DateTime.now()),
                                    image: "",
                                    memo: "",
                                  ),
                                ),)
                            );
                          },
                        ),
                      ],
                    ),
                );
              },
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "오늘"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: "기록"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: "몸무게"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: "통계"
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          // 네비게이션이 선택 될때마다 변경
          setState(() {
              currentIndex = index;
          });
        },
      ),
    );
  }

  Widget getPage(){
    if(currentIndex == 0){
      return getHomeWidget(DateTime.now());
    }

    return Container();
  }

  Container getHomeWidget(DateTime date){
    return Container(
      child: Column(
        children: [
          Container(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Container(
                  height: cardSize,
                  width: cardSize,
                  color: mainColor,
                );
              },
              itemCount: 3,
              scrollDirection: Axis.horizontal,
            ),
            height: cardSize + 20,
          ),
          Container(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Container(
                  height: cardSize,
                  width: cardSize,
                  color: mainColor,
                );
              },
              itemCount: 3,
              scrollDirection: Axis.horizontal,
            ),
            height: cardSize + 20,
          ),
          Container(
            child: ListView.builder(
              itemBuilder: (context, index) {
                if(index == 0) {
                  // 몸무게
                }else{
                  // 눈바디
                }
                return Container(
                  height: cardSize,
                  width: cardSize,
                  color: mainColor,
                );
              },
              itemCount: 3,
              scrollDirection: Axis.horizontal,
            ),
            height: cardSize + 20,
          ),
        ],
      ),
    );
  }
}
