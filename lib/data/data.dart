
class Food{
  int id;
  int date;
  int type;
  int meal;
  int kcal;
  int time;
  String memo;
  String image;

  Food({this.id, this.date, this.meal, this.type, this.kcal, this.time, this.memo,
      this.image});

  //food를 데이터 베이스에서 불러올때 사용
  factory Food.fromDB(Map<String, dynamic> data){
    return Food(
        id: data["id"],
        date: data["date"],
        type: data["type"],
        meal: data["meal"],
        kcal: data["kcal"],
        time: data["time"],
        memo: data["memo"],
        image: data["image"],
    );
  }
  
  // 객체를 실제로 저장할때는 map으로 변환해서 저장
  Map<String, dynamic> toMap(){
    return {
      "id": this.id,
      "date": this.date,
      "type": this.type,
      "meal": this.meal,
      "kcal": this.kcal,
      "time": this.time,
      "memo": this.memo,
      "image": this.image,
    };
  }
}

class Workout{
  int id;
  int date;
  int time;
  int calorie;
  int intense; // 강도
  int part; // 부위

  String name;
  String memo;

  Workout({this.id, this.date, this.time, this.calorie, this.intense, this.part,
      this.name, this.memo});

  factory Workout.fromDB(Map<String, dynamic> data){
    return Workout(
      id: data["id"],
      date: data["date"],
      time: data["time"],
      calorie: data["calorie"],
      intense: data["intense"],
      part: data["part"],
      name: data["name"],
      memo: data["memo"],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      "id": this.id,
      "date": this.date,
      "time": this.time,
      "calorie": this.calorie,
      "intense": this.intense,
      "part": this.part,
      "name": this.name,
      "memo": this.memo,
    };
  }
}

class EyeBody{
  int id;
  int date;
  String image;
  String memo;

  EyeBody({this.id, this.date, this.image, this.memo});

  factory EyeBody.fromDB(Map<String, dynamic> data){
    return EyeBody(
      id: data["id"],
      date: data["date"],
      image: data["image"],
      memo: data["memo"],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      "id": this.id,
      "date": this.date,
      "image": this.image,
      "memo": this.memo,
    };
  }
}

class Weight{
  int date;
  int weight;
  int fat;
  int muscle;

  Weight({this.date, this.weight, this.fat, this.muscle});

  factory Weight.fromDB(Map<String, dynamic> data){
    return Weight(
      date: data["date"],
      weight: data["weight"],
      fat: data["fat"],
      muscle: data["muscle"],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      "date": this.date,
      "weight": this.weight,
      "fat": this.fat,
      "muscle": this.muscle,
    };
  }
}