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

  @override
  void initState() {
    // 실제 memo 데이블의 데이터를 TextEditingController에 표시하기 위해
    // 첫 실행시 같이 실행 되어야 한다.
    memoController.text = workout.memo;
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
                child: Row(
                  children: [

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
                        Text("식사시간"),
                        InkWell(
                          child: Text(
                              "${time.hour > 11 ? "오후" : "오전"}${Utils.makeTwoDigit(time.hour % 12)}:${Utils.makeTwoDigit(time.minute)}"),
                          onTap: () async {
                            TimeOfDay _time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now()
                            );

                            if(_time == null){
                              return;
                            }

                            setState(() { // 위에서 가져온 시간을 데이터 베이스에 저장할 수 있도록 설정
                              workout.time = int.parse("${_time.hour}${Utils.makeTwoDigit(_time.minute)}");
                            });
                          },
                        ),
                      ],
                    ),
                    Container(height: 12,),
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

  Future<void> selectImage()async{
    final _img = await MultiImagePicker.pickImages(maxImages: 1, enableCamera: true);

    // 이미지를 안불러 오면 함수 종료
    if(_img.length < 1){
      return;
    }

    setState(() {// 리프레시를 시켜서 실제 이미지를 볼 수 있도록
      // 이미지를 불러왔다면
      workout.image = _img.first.identifier;
    });
  }
}

