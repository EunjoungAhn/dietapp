import 'dart:async';

import 'package:dietapp/data/data.dart';
import 'package:dietapp/data/database.dart';
import 'package:dietapp/style.dart';
import 'package:dietapp/utils.dart';
import 'package:dietapp/view/body.dart';
import 'package:dietapp/view/food.dart';
import 'package:dietapp/view/workout.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runZonedGuarded(() {
    initializeDateFormatting().then((_) {
      runApp(const MyApp());
    });
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });

  tz.initializeTimeZones();
  // 채널 생성
  const AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel("fs", "dietapp", "dietapp");
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // 채널 요청
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
    androidNotificationChannel
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: mainMColor,
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
  List<Workout> allWorkouts = [];
  List<Food> foods = [];
  List<Food> allFoods = [];
  List<EyeBody> bodies = [];
  List<EyeBody> allBodies = [];
  List<Weight> weight = [];
  List<Weight> weights = [];

  // 알림 초기화 및 알림 설정
  Future<bool> initNotification() async {
    if(flutterLocalNotificationsPlugin == null){
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    }

    var initSettingAndroid = AndroidInitializationSettings("app_icon");
    var initIOSSetting = IOSInitializationSettings();

    var initSetting = InitializationSettings(
      android: initSettingAndroid, iOS: initIOSSetting
    );

    await flutterLocalNotificationsPlugin.initialize(initSetting,
    onSelectNotification: (payload) async {

    });

    setScheduling(); // 테스트를 위해 불러오기
    return true;
  }

  void getHistories() async {
    int _d = Utils.getFormatTime(dateTime);

    foods = await dbHelper.queryFoodByDate(_d);
    workouts = await dbHelper.queryWorkoutByDate(_d);
    bodies = await dbHelper.queryEyeBodyByDate(_d);
    weight = await dbHelper.queryWeightByDate(_d);
    weights = await dbHelper.queryAllWeight();
    //통계를 위한 변수 선언
    allFoods = await dbHelper.queryAllFood();
    allWorkouts = await dbHelper.queryAllWorkout();
    allBodies = await dbHelper.queryAllEyeBody();
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
    initNotification();
  }

  // 알림을 언제 보낼지 셋팅
  void setScheduling(){
    var android = AndroidNotificationDetails(
        "fs", "dietapp", "dietapp",
        importance: Importance.max,
        priority: Priority.max
    );
    var ios = const IOSNotificationDetails();

    NotificationDetails details = NotificationDetails(
      iOS: ios,
      android: android
    );
    
    flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "오늘 다이어트를 기록해주세요!",
        "앱을 실행해주세요!",
        tz.TZDateTime.from(DateTime.now().add(Duration(seconds: 10)), tz.local),// 알림 테스트를 위해 앱 실행 후 10초 후,
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: "dietapp",
        matchDateTimeComponents: DateTimeComponents.time //매일 알림을 주기위해 설정 (매주 설정도 가능)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(child: AppBar(), preferredSize: Size.fromHeight(0),),
      body: getPage(),
      floatingActionButton: ![0,1].contains(currentIndex) ? Container() : FloatingActionButton(// 0이나1 인덱스가 아니면 안보이게 설정
        onPressed: () {
          setState(() {
            changeToDarkMode();
          });
          return;
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
    }else if(currentIndex == 3){
      return getStatisticWidget();
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
                  locale: "ko-KR",
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
                locale: "ko-KR",
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
  
  // 통계 페이지
  Widget getStatisticWidget(){
    return Container(
      child: ListView.builder(
          itemBuilder: (context, index) {
            if(index == 0){
              List<FlSpot> spots = [];

              //반복을 돌면서 그래프를 그린다.
              for(final w in allWorkouts){
                if(chartIndex == 0){
                  //몸무게
                  spots.add(FlSpot(w.date.toDouble(), w.time.toDouble()));
                }else if(chartIndex == 1){
                  //근육량
                  spots.add(FlSpot(w.date.toDouble(), w.kcal.toDouble()));
                }else{
                  //지방
                  spots.add(FlSpot(w.date.toDouble(), w.distance.toDouble()));
                }
              }

             return Container(
               child: Column(
                 children: [
                   Row(
                     children: [
                       InkWell(
                         child: Container(
                           child: Text("운동시간", style: TextStyle(
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
                           child: Text("칼로리", style: TextStyle(
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
                           child: Text("거리", style: TextStyle(
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
                                       "${spots.first.y}", TextStyle(color: mainColor)
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
            else if(index == 1){
              return Container(
                height: cardSize,
                child: ListView.builder(
                  itemBuilder: (context, _index) {
                    return Container(
                      height: cardSize,
                      width: cardSize,
                      child: MainFoodCard(food: allFoods[_index],),
                    );
                  },
                  itemCount: allFoods.length,
                  scrollDirection: Axis.horizontal,
                ),
              );
            }
            else if(index == 2){
              return Container(
                height: cardSize,
                child: ListView.builder(
                  itemBuilder: (context, _index) {
                    return Container(
                      height: cardSize,
                      width: cardSize,
                      child: MainWorkoutCard(workout: allWorkouts[_index],),
                    );
                  },
                  itemCount: allWorkouts.length,
                  scrollDirection: Axis.horizontal,
                ),
              );
            }
            else if(index == 3){
              return Container(
                height: cardSize,
                child: ListView.builder(
                  itemBuilder: (context, _index) {
                    return Container(
                      height: cardSize,
                      width: cardSize,
                      child: MainEyeBodyCard(eyeBody: allBodies[_index],),
                    );
                  },
                  itemCount: allBodies.length,
                  scrollDirection: Axis.horizontal,
                ),
              );
            }

            return Container();
          },
        itemCount: 4,
      ),
    );
  }
}
