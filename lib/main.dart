import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'model/location.dart';
Map<String, dynamic> _parseAndDecode(String response) {
  return jsonDecode(response) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> parseJson(String text) {
  return compute(_parseAndDecode, text);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Future<List<Weather>> weatherArr = Future<List<Weather>>.value(<Weather>[]);
  String data = '';
  final dio = Dio();
  final weatherMap =<String,Weather>{};
  String? citySelected;
void bind(dynamic v) {
  if(v != null) {
    for(var t in v['time']) {
      final key = '${t['startTime']}~${t['endTime']}';

      weatherMap[key] = Weather.fromJson(t);
      if(!weatherMap.containsKey(key)) {
        weatherMap[key] = Weather.fromJson(t);
      }

      //weatherList['$startTime~$endTime']?.startTime = startTime;
      //weatherList['$startTime~$endTime']?.endTime = endTime;
      if(v['elementName'] == 'MaxT') {
        weatherMap[key]?.maxT = t['parameter']['parameterName'];
      }
      else if(v['elementName'] == 'MinT') {
        print(t['parameter']['parameterName']);
        weatherMap[key]?.minT = t['parameter']['parameterName'];
        print('d');
        print(t['parameter']['parameterName']);
        print(weatherMap[key]?.minT);
      }
    }
  }

}
  void getHttp() async {
    final apiUrl = 'https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001?Authorization=CWA-677AE195-EFD7-4597-9F04-9692AA714760&format=JSON&locationName=$citySelected';
    final response = await dio.get(apiUrl);

    Map<String, dynamic> data = jsonDecode(response.toString()) as Map<String, dynamic>;


    for(var v in data['records']['location'][0]['weatherElement']) {
        bind(v);
    }
    print('weatherList');

    final weatherList = <Weather>[];
    weatherMap.forEach((k, v) {
      weatherList.add(v);
      print(v.minT);
    });
    //print(weatherList);
    setState(() {
      weatherArr = Future<List<Weather>>.value(weatherList);
    });

  }
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body:  Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              hint: const Text('請選擇'),
              isExpanded: false,
              items: const [
                DropdownMenuItem(child: Text('台北市'), value: '台北市'),
                DropdownMenuItem(child: Text('新北市'), value: '新北市'),
                DropdownMenuItem(child: Text('桃園市'), value: '桃園市'),
                DropdownMenuItem(child: Text('彰化縣'), value: '彰化縣'),
                DropdownMenuItem(child: Text('高雄市'), value: '高雄市'),
              ],

              onChanged: (value) {                                  /// 当用户从下拉菜单中选中某项后触发的事件
                setState(() {
                  citySelected = value;
                });
                getHttp();
              },
            ),
            FutureBuilder<List<Weather>>(
              future: weatherArr,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView(
                      shrinkWrap: true,
                    children: snapshot.data!.map((data) {
                      return Card(
                        child: ListTile(
                          title: Text('${data.startTime!}~${data.endTime!}'),
                          subtitle: Text('最高溫 ${data.maxT.toString()}  最低溫${data.minT.toString()}'),
                          //trailing: Text(),
                        ),
                      );
                    }).toList(),
                  );
                }
                return const Center(
                  // child: CircularProgressIndicator(
                  //   color: Colors.black,
                  // ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
