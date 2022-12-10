import 'package:dietapp/data/data.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: txtColor),
        elevation: 1.0,
        actions: [
          TextButton(onPressed: () {
            // 저장하고 종료

          }, child: Text("저장"),
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
                  child: Image.asset("assets/img/rice.png"),
                  onTap: () {
                    selectImage();
                  },
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
                        Text("오후 11:32"),
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

