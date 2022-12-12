
import 'package:dietapp/data/data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "dietapp.db";
  static final _databaseVersion = 1;
  static final foodTable = "food";
  static final workoutTable = "workout";
  static final bodyTable = "body";
  static final weightTable = "weight";

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    // DB가 null이 아니면 기존의 DB를 넘겨 주세요.
    if (_database != null) return _database;
    // DB가 없으면 DB 초기화 함수를 실행
    _database = await _initDatabase();
    return _database;
  }
  // 없으면 데이터 베이스를 생성하겠다.
  _initDatabase() async {
    var databasePath = await getDatabasesPath(); // DB의 경로를 가져오기
    String path = join(databasePath, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }

  // 앱이 처음 실행될때 데이터 베이스를 생성
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $foodTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date INTEGER DEFAULT 0,
      type INTEGER DEFAULT 0,
      meal INTEGER DEFAULT 0,
      kcal INTEGER DEFAULT 0,
      time INTEGER DEFAULT 0,
      image String,
      memo String
    )
    ''');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $workoutTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date INTEGER DEFAULT 0,
      time INTEGER DEFAULT 0,
      type INTEGER DEFAULT 0,
      distance INTEGER DEFAULT 0,
      kcal INTEGER DEFAULT 0,
      intense INTEGER DEFAULT 0,
      part INTEGER DEFAULT,
      name String,
      memo String
    )
    ''');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $bodyTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date INTEGER DEFAULT 0,
      image String,
      memo String
    )
    ''');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $weightTable (
      date INTEGER DEFAULT 0,
      weight INTEGER DEFAULT 0,
      fat INTEGER DEFAULT 0,
      muscle INTEGER DEFAULT 0
    )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) {
    // 기존의 만들었던 테이블을 업그레이드 할 수 있다.
    /*
    if(newVersion == 2){
      await db.execute("""
      ALTER TABLE $workoutTable
     
      """);

      await db.execute("""
      ALTER TABLE $workoutTable
      
      """);
    }
     */
  }

  //음식
  Future<int> insertFood(Food food) async {
    Database db = await instance.database;

    if(food.id == null) {
      //생성
      final _map = food.toMap();

      return await db.insert(foodTable, _map);
    }else{
      //변경
      final _map = food.toMap();
      return await db.update(foodTable, _map, where: "id = ?", whereArgs: [food.id]);
    }

  }

  Future<List<Food>> queryFoodByDate(int date) async {
    Database db = await instance.database;
    List<Food> foods = [];

    // foodTable 특정 date의 데이터를 가져와라
    var query = await db.query(foodTable, where: "date = ?", whereArgs: [date]);

    // 리스트에 다 담아주고
    for(var q in query){
      foods.add(Food.fromDB(q));
    }

    return foods;
  }

  Future<List<Food>> queryAllFood() async {
    Database db = await instance.database;
    List<Food> foods = [];

    // foodTable 있는 데이터를 다 가져와라
    var query = await db.query(foodTable);

    // 리스트에 다 담아주고
    for(var q in query){
      foods.add(Food.fromDB(q));
    }

    return foods;
  }

  //운동
  Future<int> insertWorkout(Workout workout) async {
    Database db = await instance.database;

    if(workout.id == null) {
      //생성
      final _map = workout.toMap();

      return await db.insert(workoutTable, _map);
    }else{
      //변경
      final _map = workout.toMap();
      return await db.update(workoutTable, _map, where: "id = ?", whereArgs: [workout.id]);
    }

  }

  Future<List<Workout>> queryWorkoutByDate(int date) async {
    Database db = await instance.database;
    List<Workout> workouts = [];

    // workoutTable 특정 date의 데이터를 가져와라
    var query = await db.query(workoutTable, where: "date = ?", whereArgs: [date]);

    // 투두 리스트에 다 담아주고
    for(var q in query){
      workouts.add(Workout.fromDB(q));
    }

    return workouts;
  }

  Future<List<Workout>> queryAllWorkout() async {
    Database db = await instance.database;
    List<Workout> workouts = [];

    // workoutTable 있는 데이터를 다 가져와라
    var query = await db.query(workoutTable);

    // 투두 리스트에 다 담아주고
    for(var q in query){
      workouts.add(Workout.fromDB(q));
    }

    return workouts;
  }

  //바디
  Future<int> insertEyeBody(EyeBody body) async {
    Database db = await instance.database;

    if(body.id == null) {
      //생성
      final _map = body.toMap();

      return await db.insert(bodyTable, _map);
    }else{
      //변경
      final _map = body.toMap();
      return await db.update(bodyTable, _map, where: "id = ?", whereArgs: [body.id]);
    }

  }

  Future<List<EyeBody>> queryEyeBodyByDate(int date) async {
    Database db = await instance.database;
    List<EyeBody> eyeBodys = [];

    // eyeBodyTable 특정 date의 데이터를 가져와라
    var query = await db.query(bodyTable, where: "date = ?", whereArgs: [date]);

    // 리스트에 다 담아주고
    for(var q in query){
      eyeBodys.add(EyeBody.fromDB(q));
    }

    return eyeBodys;
  }

  Future<List<EyeBody>> queryAllEyeBody() async {
    Database db = await instance.database;
    List<EyeBody> eyeBodys = [];

    // eyeBodyTable 있는 데이터를 다 가져와라
    var query = await db.query(bodyTable);

    // 리스트에 다 담아주고
    for(var q in query){
      eyeBodys.add(EyeBody.fromDB(q));
    }

    return eyeBodys;
  }

  //무게
  Future<int> insertWeight(Weight weight) async {
    Database db = await instance.database;

    List<Weight> _d = await queryWeightByDate(weight.date);

    if(_d.isEmpty) {
      //생성
      final _map = weight.toMap();

      return await db.insert(weightTable, _map);
    }else{
      //변경
      final _map = weight.toMap();
      return await db.update(weightTable, _map, where: "date = ?", whereArgs: [weight.date]);
    }

  }

  Future<List<Weight>> queryWeightByDate(int date) async {
    Database db = await instance.database;
    List<Weight> weights = [];

    // weightTable 특정 date의 데이터를 가져와라
    var query = await db.query(weightTable, where: "date = ?", whereArgs: [date]);

    // 리스트에 다 담아주고
    for(var q in query){
      weights.add(Weight.fromDB(q));
    }

    return weights;
  }

  Future<List<Weight>> queryAllWeight() async {
    Database db = await instance.database;
    List<Weight> weights = [];

    // weightTable 있는 데이터를 다 가져와라
    var query = await db.query(weightTable);

    // 리스트에 다 담아주고
    for(var q in query){
      weights.add(Weight.fromDB(q));
    }

    return weights;
  }
}