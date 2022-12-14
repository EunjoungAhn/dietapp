import 'package:dietapp/data/data.dart';
import 'package:dietapp/data/database.dart';
import 'package:dietapp/style.dart';
import 'package:dietapp/utils.dart';
import 'package:dietapp/view/body.dart';
import 'package:dietapp/view/food.dart';
import 'package:dietapp/view/workout.dart';
import 'package:fl_chart/fl_chart.dart';
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
  List<Weight> weights = [];

  void getHistories() async {
    int _d = Utils.getFormatTime(dateTime);

    foods = await dbHelper.queryFoodByDate(_d);
    workouts = await dbHelper.queryWorkoutByDate(_d);
    bodies = await dbHelper.queryEyeBodyByDate(_d);
    weight = await dbHelper.queryWeightByDate(_d);
    weights = await dbHelper.queryAllWeight();
    int charIndex = 0; // 어떤 그래프를 클릭했는지

    //그 날짜의 몸무게가 존재한다면 불러와라
    if(weight.isNotEmpty){
      final w = weight.first;
      wCtrl.text = w.weight.toString();
      mCtrl.text = w.muscle.toString();
      fCtrl.text = w.fat.toString();
    }else{
      wCtrl.text = "";
      mCtrl.text = "";
      fCtrl.text = "";
    }

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
      floatingActionButton: ![0,1].contains(currentIndex) ? Container() : FloatingActionButton(// 0이나1 인덱스가 아니면 안보이게 설정
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
                                    date: Utils.getFormatTime(dateTime),
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
                                    date: Utils.getFormatTime(dateTime),
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
                                    date: Utils.getFormatTime(dateTime),
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
    }else if(currentIndex == 2){
      return getWeightWidget();
    }


    return Container();
  }

  Widget getHomeWidget(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: foods.isEmpty ? Container(
              padding: EdgeInsets.all(8),
                child: 
              ClipRRect(
                child: Image.asset("assets/img/rice.png"))) : ListView.builder(
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
            child: workouts.isEmpty ?
            Container(
              padding: EdgeInsets.all(8),
                child:
                  ClipRRect(
                    child: Image.asset("assets/img/workout.png"),
                  borderRadius: BorderRadius.circular(12),
                  )) : ListView.builder(
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
                  if(weight.isEmpty){
                    return Container();
                  }else{
                    final w = weight.first;

                    return Container(
                      child: Container(
                        height: cardSize,
                        width: cardSize,
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 4,
                                  spreadRadius: 4,
                                  color: Colors.black12
                              )
                            ]
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${w.weight}kg", style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold
                            ),),
                          ],
                        ),
                      ),
                      height: cardSize,
                      width: cardSize,
                    );
                  }


                }else{
                  // 눈바디
                  if(bodies.isEmpty){
                    return Container(
                      padding: EdgeInsets.all(8),
                        child: ClipRRect(
                            child: Image.asset("assets/img/eyeBody.png"),
                            borderRadius: BorderRadius.circular(12),
                    ));
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
                  headerStyle:  HeaderStyle(
                    centerHeaderTitle: true
                  ),
                  calendarStyle: CalendarStyle(
                    selectedColor: mainColor
                  ),
                  initialCalendarFormat: CalendarFormat.month,
                  availableCalendarFormats: {
                    CalendarFormat.month: ""
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

  CalendarController weightCalendarController = CalendarController();
  TextEditingController wCtrl = TextEditingController();
  TextEditingController mCtrl = TextEditingController();
  TextEditingController fCtrl = TextEditingController();
  int chartIndex = 0; // 어떤 그래프를 선택했는지

  Widget getWeightWidget(){
    return Container(
      child: ListView.builder(
        itemBuilder: (context, index) {
          if(index == 0){
            return Container(
              child: TableCalendar(
                key: Key("weighCalendar"),
                initialSelectedDay: dateTime,
                calendarController: weightCalendarController,
                onDaySelected: (date, events, holidays) {
                  dateTime = date;
                  getHistories();
                },
                headerStyle:  HeaderStyle(
                    centerHeaderTitle: true
                ),
                initialCalendarFormat: CalendarFormat.week,
                availableCalendarFormats: {
                  CalendarFormat.week: ""
                },
              ),
            );
          }else if(index == 1){
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${dateTime.month}월 ${dateTime.day}일"),
                      InkWell(
                        child: Container(
                          child: Text("저장"),
                          decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius: BorderRadius.circular(8)
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onTap: () async {
                          Weight w;
                          if(weight.isEmpty){
                            w = Weight(date: Utils.getFormatTime(dateTime));
                          }else{
                            w = weight.first;
                          }
                          // passing 했는데 값이 없으면 0으로 대입해라
                          w.weight = int.tryParse(wCtrl.text) ?? 0;
                          w.muscle = int.tryParse(mCtrl.text) ?? 0;
                          w.fat = int.tryParse(fCtrl.text) ?? 0;

                          await dbHelper.insertWeight(w);
                          getHistories();
                          // 키보드 닫히게 하기
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ],
                  ),
                  Container(height: 12,),
                  Row(
                    children: [
                      Container(width: 8,),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch ,
                            children: [
                              Text("몸무게"),
                              TextField(
                                keyboardType: TextInputType.number,// 숫자만 입력가능하게 설정
                                controller: wCtrl,
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: txtColor,
                                            width: 0.5
                                        )
                                    )
                                ),
                              ),
                            ],
                          ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch ,
                          children: [
                            Text("근육량"),
                            TextField(
                              keyboardType: TextInputType.number,// 숫자만 입력가능하게 설정
                              controller: mCtrl,
                              textAlign: TextAlign.end,
                              decoration: InputDecoration(
                                  border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: txtColor,
                                          width: 0.5
                                      )
                                  )
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 8,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch ,
                          children: [
                            Text("지방"),
                            TextField(
                              keyboardType: TextInputType.number,// 숫자만 입력가능하게 설정
                              controller: fCtrl,
                              textAlign: TextAlign.end,
                              decoration: InputDecoration(
                                  border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: txtColor,
                                          width: 0.5
                                      )
                                  )
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 8,),
                    ],
                  ),
                ],
              ),
            );
          }
          else if(index == 2){
            List<FlSpot> spots = [];

            //반복을 돌면서 그래프를 그린다.
            for(final w in weights){
                if(chartIndex == 0){
                  //몸무게
                  spots.add(FlSpot(w.date.toDouble(), w.weight.toDouble()));
                }else if(chartIndex == 1){
                  //근육량
                  spots.add(FlSpot(w.date.toDouble(), w.muscle.toDouble()));
                }else{
                  //지방
                  spots.add(FlSpot(w.date.toDouble(), w.fat.toDouble()));
                }
            }

            return Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        child: Container(
                          child: Text("몸무게", style: TextStyle(
                            color: chartIndex == 0 ? Colors.white : iTxtColor
                          ),),
                          decoration: BoxDecoration(
                              color: chartIndex == 0 ? mainColor : ibgColor,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onTap: () async {
                          setState(() {
                            chartIndex = 0;
                          });
                        },
                      ),
                      Container(width: 8,),
                      InkWell(
                        child: Container(
                          child: Text("근육량", style: TextStyle(
                              color: chartIndex == 1 ? Colors.white : iTxtColor
                          ),),
                          decoration: BoxDecoration(
                              color: chartIndex == 1 ? mainColor : ibgColor,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onTap: () async {
                          setState(() {
                            chartIndex = 1;
                          });
                        },
                      ),
                      Container(width: 8,),
                      InkWell(
                        child: Container(
                          child: Text("지방", style: TextStyle(
                              color: chartIndex == 2 ? Colors.white : iTxtColor
                          ),),
                          decoration: BoxDecoration(
                              color: chartIndex == 2 ? mainColor : ibgColor,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onTap: () async {
                          setState(() {
                            chartIndex = 2;
                          });
                        },
                      ),
                    ],
                  ),
                  // 차트
                  Container(
                    height: 300,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 4,
                            spreadRadius: 4,
                            color: Colors.black12
                        )
                      ]
                    ),
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            colors:  [mainColor]
                          )
                        ],
                        gridData: FlGridData(
                          show: false
                        ),
                        borderData: FlBorderData(
                          show: false
                        ),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (spots) {
                              return [
                                LineTooltipItem(
                                  "${spots.first.y}kg", TextStyle(color: mainColor)
                                )
                              ];
                            },
                          )
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: SideTitles(
                            showTitles: true,
                            getTitles: (value) {
                              DateTime date = Utils.stringToDateTime(value.toInt().toString());
                                return "${date.day}일";
                            },
                          ),
                          leftTitles: SideTitles(
                            showTitles: false,
                          )
                        ),

                      ),
                    ),
                  )
                ],
              ),
            );
          }

          return Container();
        },
        itemCount: 3,
      ),
    );
  }
}
