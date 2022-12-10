import 'package:dietapp/data/data.dart';
import 'package:dietapp/style.dart';
import 'package:dietapp/utils.dart';
import 'package:flutter/material.dart';

class FoodAddPage extends StatefulWidget {

  final Food food;

  const FoodAddPage({Key key, this.food,}) : super(key: key);

  @override
  State<FoodAddPage> createState() => _FoodAddPageState();
}

class _FoodAddPageState extends State<FoodAddPage> {
 // Food에 접근할 수 있게 설정
  Food get food => widget.food;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: ListView.builder(
          itemBuilder: (context, index) {
            if(index == 0){
              return Container(
                child: InkWell(
                  child: Image.asset(""),
                  onTap: () {

                  },
                ),
              );
            }
            else if( index == 1){
              return Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("식사시간"),
                        Text("오후 11:32"),
                      ],
                    ),
                    GridView.count(
                      // 그리드 뷰 이지만 움직이지 않게 설정
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: List.generate(
                        // utils 파일에 작성한 list 타입의 텍스트를 하나씩 만들어 준다.
                          mealTime.length, (_index) {
                            return Container(
                              child: Text(mealTime[_index],
                              style: TextStyle(
                                color: food.type == _index ? Colors.white : iTxtColor,
                              ),),
                              // 클릭시 활성화 같은 표시를 위해 설정
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: food.type == _index ? mainColor : ibgColor,
                              ),
                            );
                        }
                        ),
                      crossAxisCount: 4, // 4개 만큼만 표시 넘으면 밑으로
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 2,
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
}

