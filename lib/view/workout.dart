import 'package:dietapp/data/data.dart';
import 'package:dietapp/data/database.dart';
import 'package:dietapp/style.dart';
import 'package:dietapp/utils.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class WorkoutAddPage extends StatefulWidget {

  final Workout workout;

  const WorkoutAddPage({Key key, this.workout,}) : super(key: key);

  @override
  State<WorkoutAddPage> createState() => _WorkoutAddPageState();
}

class _WorkoutAddPageState extends State<WorkoutAddPage> {
  // Food에 접근할 수 있게 설정
  Workout get workout => widget.workout;
  TextEditingController memoController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController calController = TextEditingController();
  TextEditingController distanceController = TextEditingController();

  @override
  void initState() {
    // 실제 memo 데이블의 데이터를 TextEditingController에 표시하기 위해
    // 첫 실행시 같이 실행 되어야 한다.
    memoController.text = workout.memo;
    nameController.text = workout.name;
    timeController.text = workout.time.toString();
    calController.text = workout.kcal.toString();
    distanceController.text = workout.distance.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: txtColor),
        elevation: 1.0,
        actions: [
          TextButton(
            onPressed: () async {
              // 저장하고 종료
              final db = DatabaseHelper.instance;
              workout.memo = memoController.text; // memo에 작성한 데이터를 다시 담아주어야 한다.
              workout.name = nameController.text;
              if(timeController.text.isEmpty){// time 을 입력 안 했을시 기본값 적용
                workout.time = 0;
              }else{
                workout.time = int.parse(timeController.text);
              }

              if(calController.text.isEmpty){// time 을 입력 안 했을시 기본값 적용
                workout.kcal = 0;
              }else{
                workout.kcal = int.parse(calController.text);
              }

              if(distanceController.text.isEmpty){// time 을 입력 안 했을시 기본값 적용
                workout.distance = 0;
              }else{
                workout.distance = int.parse(distanceController.text);
              }

              await db.insertWorkout(workout);
              Navigator.of(context).pop();
            },
            child: Text("저장"),
          )
        ],
      ),
      body: Container(
        child: ListView.builder(
          itemBuilder: (context, index) {
            if(index == 0){

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      child: InkWell(// 선택을 할때마다 운동 이미지를 변경할 수 있도록, 숫자에 맞게
                        child: Image.asset("assets/img/${workout.type}.png"),
                        onTap: () {
                          setState(() {
                            workout.type ++;
                            workout.type = workout.type % 4; // 0 나누기 4 하면 0이기에 반복 하도록
                          });
                        },
                      ),
                      height: 70, width: 70,
                      // 운동 이미지 클릭시 클릭 효과 처리
                      decoration: BoxDecoration(
                        color: ibgColor,
                        borderRadius: BorderRadius.circular(70),
                      ),
                    ),
                    Container(width: 8,),
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: txtColor,
                              width: 0.5
                            )
                          )
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            else if(index == 1){
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("운동시간"),
                        Container(
                          child: TextField(
                            keyboardType: TextInputType.number,// 숫자만 입력가능하게 설정
                            controller: timeController,
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
                          width: 70,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("운동 칼로리"),
                        Container(
                          child: TextField(
                            keyboardType: TextInputType.number,// 숫자만 입력가능하게 설정
                            controller: calController,
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
                          width: 70,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("운동 거리"),
                        Container(
                          child: TextField(
                            keyboardType: TextInputType.number,// 숫자만 입력가능하게 설정
                            controller: distanceController,
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
                          width: 70,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            else if(index == 2){
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("운동 부위"),
                      ],
                    ),
                    Container(height: 12,),
                    GridView.count(
                      // 그리드 뷰 이지만 움직이지 않게 설정
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: List.generate(
                        // utils 파일에 작성한 list 타입의 텍스트를 하나씩 만들어 준다.
                          wPart.length, (_index) {
                        return InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(wPart[_index],
                              style: TextStyle(
                                color: workout.part == _index ? Colors.white : iTxtColor,
                              ),),
                            // 클릭시 활성화 같은 표시를 위해 설정
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: workout.part == _index ? mainColor : ibgColor,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              workout.part = _index;
                            });
                          },
                        );
                      }
                      ),
                      crossAxisCount: 4, // 4개 만큼만 표시 넘으면 밑으로
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 2.5,
                    )
                  ],
                ),
              );
            }
            else if(index == 3){
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("운동 강도"),
                      ],
                    ),
                    Container(height: 12,),
                    GridView.count(
                      // 그리드 뷰 이지만 움직이지 않게 설정
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: List.generate(
                        // utils 파일에 작성한 list 타입의 텍스트를 하나씩 만들어 준다.
                          wIntense.length, (_index) {
                        return InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(wIntense[_index],
                              style: TextStyle(
                                color: workout.intense == _index ? Colors.white : iTxtColor,
                              ),),
                            // 클릭시 활성화 같은 표시를 위해 설정
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: workout.intense == _index ? mainColor : ibgColor,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              workout.intense = _index;
                            });
                          },
                        );
                      }
                      ),
                      crossAxisCount: 4, // 4개 만큼만 표시 넘으면 밑으로
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 2.5,
                    )
                  ],
                ),
              );
            }
            else if(index == 4){
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("식단메모"),
                    Container(height: 12),
                    TextField(
                      maxLines: 10,
                      minLines: 10,
                      keyboardType: TextInputType.multiline,
                      controller: memoController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: txtColor, width: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          )
                      ),
                    )
                  ],
                ),
              );
            }
            return Container();
          },
          itemCount: 5,
        ),
      ),
    );
  }
}

class MainWorkoutCard extends StatelessWidget {
  final Workout workout;
  const MainWorkoutCard({Key key, this.workout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRRect(
        child: AspectRatio(
          child: Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      child: Image.asset("assets/img/${workout.type}.png"),
                      height: 30, width: 30,
                      // 운동 이미지 클릭시 클릭 효과 처리
                      decoration: BoxDecoration(
                        color: ibgColor,
                        borderRadius: BorderRadius.circular(70),
                      ),
                    ),
                    Expanded(
                      child: Text(// 분을 시간으로 표현하기
                        "${Utils.makeTwoDigit(workout.time ~/ 60)}:"
                            "${Utils.makeTwoDigit(workout.time % 60)}",
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                Expanded(
                    child: Text(workout.name),
                ),
                Text(workout.kcal == 0 ? "": "${workout.kcal}kcal"),
                Text(workout.distance == 0 ? "": "${workout.distance}km"),
              ],
            ),
          ),
          aspectRatio: 1,
        ),
      ),
    );
  }
}
