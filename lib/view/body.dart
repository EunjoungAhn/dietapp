import 'package:dietapp/data/data.dart';
import 'package:dietapp/data/database.dart';
import 'package:dietapp/style.dart';
import 'package:dietapp/utils.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class EyeBodyAddPage extends StatefulWidget {

  final EyeBody body;

  const EyeBodyAddPage({Key key, this.body,}) : super(key: key);

  @override
  State<EyeBodyAddPage> createState() => _EyeBodyAddPageState();
}

class _EyeBodyAddPageState extends State<EyeBodyAddPage> {
 // EyeBody에 접근할 수 있게 설정
  EyeBody get body => widget.body;
  TextEditingController memoController = TextEditingController();

  @override
  void initState() {
    // 실제 memo 데이블의 데이터를 TextEditingController에 표시하기 위해
    // 첫 실행시 같이 실행 되어야 한다.
    memoController.text = body.memo;
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
            body.memo = memoController.text; // memo에 작성한 데이터를 다시 담아주어야 한다.
            await db.insertEyeBody(body);
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
                      child: body.image.isEmpty ? Image.asset("assets/img/rice.png") :
                    AssetThumb(asset: Asset(body.image,"rice.png", 0,0),
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
          itemCount: 3,
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
    body.image = _img.first.identifier;
    });
  }
}

class MainEyeBodyCard extends StatelessWidget {
  final EyeBody eyeBody;
  const MainEyeBodyCard({Key key, this.eyeBody}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      child: ClipRRect(
        // 전체 라운드 형태를 만들기 위해 감싼 위젯
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          child: Stack(
            children: [
              // stack의 전체 화면을 채우겠다.
              Positioned.fill(
                child: AssetThumb(asset: Asset(eyeBody.image,"rice.png", 0,0),
                    width: cardSize.toInt(), height: cardSize.toInt()),
              ),

              // 이미지 위에 검은색의 필터 쒸우기 글씨가 잘 보이기 위해
              Positioned.fill(
                child: Container(
                  color: Colors.black12,
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