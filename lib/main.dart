import 'package:flutter/material.dart';

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

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

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
}
