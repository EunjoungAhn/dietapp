import 'package:dietapp/data/data.dart';
import 'package:dietapp/data/database.dart';
import 'package:dietapp/style.dart';
import 'package:dietapp/utils.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class FoodAddPage extends StatefulWidget {

  final Food food;

  const FoodAddPage({Key key, this.food,}) : super(key: key);

  @override
  State<FoodAddPage> createState() => _FoodAddPageState();
}

class _FoodAddPageState extends State<FoodAddPage> {
 // Food에 접근할 수 있게 설정
  Food get food => widget.food;
  TextEditingController memoController = TextEditingController();

  @override
  void initState() {
    // 실제 memo 데이블의 데이터를 TextEditingController에 표시하기 위해
    // 첫 실행시 같이 실행 되어야 한다.
    memoController.text = food.memo;
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
            food.memo = memoController.text; // memo에 작성한 데이터를 다시 담아주어야 한다.
            await db.insertFood(food);
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
                margin: EdgeInsets.symmetric(vertical: 16),
                height: cardSize,
                width: cardSize,
                child: InkWell(
                  child: AspectRatio( // 1:1 비율의 이미지로 보이도록 설정
                    child: Align(
                      child: food.image.isEmpty ? Image.asset("assets/img/rice.png") :
                    AssetThumb(asset: Asset(food.image,"rice.png", 0,0),
                        width: cardSize.toInt(), height: cardSize.toInt(),),
                    ),
                    aspectRatio: 1/1,
                  ),
                  onTap: () {
                    selectImage();
                  },
                ),
              );
            }
            else if(index == 1){
              String _t = food.time.toString();
              String _m = _t.substring(_t.length -2);
              String _h = _t.substring(0, _t.length -2);

              TimeOfDay time = TimeOfDay(hour: int.parse(_h), minute: int.parse(_m));

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
                               food.time = int.parse("${_time.hour}${Utils.makeTwoDigit(_time.minute)}");
                              });
                          },
                        ),
                      ],
                    ),
                    Container(height: 12,),
                    GridView.count(
                      // 그리드 뷰 이지만 움직이지 않게 설정
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: List.generate(
                        // utils 파일에 작성한 list 타입의 텍스트를 하나씩 만들어 준다.
                          mealTime.length, (_index) {
                            return InkWell(
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(mealTime[_index],
                                style: TextStyle(
                                  color: food.type == _index ? Colors.white : iTxtColor,
                                ),),
                                // 클릭시 활성화 같은 표시를 위해 설정
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: food.type == _index ? mainColor : ibgColor,
                                ),
                              ),
                              // 클릭시 index로 변경 가능하도록
                              onTap: () {
                                setState(() {
                                  food.type = _index;
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
            else if(index == 2){
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("식단평가"),
                      ],
                    ),
                    Container(height: 12,),
                    GridView.count(
                      // 그리드 뷰 이지만 움직이지 않게 설정
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: List.generate(
                        // utils 파일에 작성한 list 타입의 텍스트를 하나씩 만들어 준다.
                          mealType.length, (_index) {
                        return InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(mealType[_index],
                              style: TextStyle(
                                color: food.meal == _index ? Colors.white : iTxtColor,
                              ),),
                            // 클릭시 활성화 같은 표시를 위해 설정
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: food.meal == _index ? mainColor : ibgColor,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              food.meal = _index;
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
          itemCount: 4,
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
    food.image = _img.first.identifier;
    });
  }
}

class MainFoodCard extends StatelessWidget {
  final Food food;
  const MainFoodCard({Key key, this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _t = food.time.toString();
    String _m = _t.substring(_t.length -2);
    String _h = _t.substring(0, _t.length -2);

    TimeOfDay time = TimeOfDay(hour: int.parse(_h), minute: int.parse(_m));

    return Container(
      child: ClipRRect(
        // 전체 라운드 형태를 만들기 위해 감싼 위젯
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          child: Stack(
            children: [
              // stack의 전체 화면을 채우겠다.
              Positioned.fill(
              child: AssetThumb(asset: Asset(food.image,"rice.png", 0,0),
                    width: cardSize.toInt(), height: cardSize.toInt()),
              ),

              // 이미지 위에 검은색의 필터 쒸우기 글씨가 잘 보이기 위해
              Positioned.fill(
                  child: Container(
                    color: Colors.black12,
                  ),
              ),

              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Text(
                    "${time.hour > 11 ? "오후" : "오전"}"
                    "${Utils.makeTwoDigit(time.hour % 12)}:"
                    "${Utils.makeTwoDigit(time.minute)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              Positioned.fill(
                // 오른쪽 하단으로 설정
                right: 6,
                bottom: 6,
                child: Container(
                  // 텍스트에는 마진을 못 넣어서
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(mealTime[food.time], style: TextStyle(color: Colors.white),),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(8)
                  ),
                ),
              ),

            ],
          ),
          aspectRatio: 1,
        ),
      ),
    );
  }
}
