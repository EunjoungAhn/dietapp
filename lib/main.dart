import 'package:dietapp/data/data.dart';
import 'package:dietapp/data/database.dart';
import 'package:dietapp/style.dart';
import 'package:dietapp/utils.dart';
import 'package:dietapp/view/body.dart';
import 'package:dietapp/view/food.dart';
import 'package:dietapp/view/workout.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
  final dbHelper = DatabaseHelper.instance;

  int currentIndex = 0;
  DateTime dateTime = DateTime.now();

  // 메인화면에서 각각의 데이터를 표현할 데이터 저장 변수 선언
  List<Workout> workouts = [];
  List<Food> foods = [];
  List<EyeBody> bodies = [];
  List<Weight> weight = [];

  void getHistories() async {
    int _d = Utils.getFormatTime(dateTime);

    foods = await dbHelper.queryFoodByDate(_d);
    workouts = await dbHelper.queryWorkoutByDate(_d);
    bodies = await dbHelper.queryEyeBodyByDate(_d);
    weight = await dbHelper.queryWeightByDate(_d);

    setState(() { });
  }

  @override
  void initState() {
    super.initState();
  // 앱이 실행될때 오늘 날짜 기준으로 메인화면에 데이터 불러오기
    getHistories();
  }

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
                              
                              // 리프레시가 있을지 모르니 추가하여 항상 불러준다.
                              getHistories();
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

                            getHistories();
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

                            getHistories();
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
      return getHomeWidget();
    }else if(currentIndex == 1){
      return getHistoryWidget();
    }

    return Container();
  }

  Widget getHomeWidget(){
    return Container(
      child: Column(
        children: [
          Container(
            child: foods.isEmpty ? Image.asset("assets/img/rice.png") : ListView.builder(
              itemBuilder: (context, index) {
                return Container(
                  height: cardSize,
                  width: cardSize,
                  child: MainFoodCard(food: foods[index],),
                );
              },
              itemCount: foods.length,
              scrollDirection: Axis.horizontal,
            ),
            height: cardSize,
          ),
          Container(
            child: workouts.isEmpty ? Image.asset("assets/img/workout.png") : ListView.builder(
              itemBuilder: (context, index) {
                return Container(
                  height: cardSize,
                  width: cardSize,
                  child: MainWorkoutCard(workout: workouts[index],),
                );
              },
              itemCount: workouts.length,
              scrollDirection: Axis.horizontal,
            ),
            height: cardSize,
          ),
          Container(
            child: ListView.builder(
              itemBuilder: (context, index) {
                if(index == 0) {
                  // 몸무게
                }else{
                  // 눈바디
                  if(bodies.isEmpty){
                    return Container(
                      height: cardSize,
                      width: cardSize,
                      color: mainColor,
                    );
                  }
                  return Container(
                    height: cardSize,
                    width: cardSize,
                    child: MainEyeBodyCard(eyeBody: bodies[0],),
                  );
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

  CalendarController calendarController = CalendarController();

  Widget getHistoryWidget(){
    return Container(
      child: ListView.builder(
          itemBuilder: (context, index) {
            if(index == 0){
              return Container(
                child: TableCalendar(
                  initialSelectedDay: dateTime,
                  calendarController: calendarController,
                  onDaySelected: (date, events, holidays) {
                    dateTime = date;
                    getHistories();
                  },
                ),
              );
            }else if(index == 1){
              return getHomeWidget();
            }

            return Container();
          },
        itemCount: 2,
      ),
    );
  }
}
