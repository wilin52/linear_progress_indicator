import 'package:flutter/material.dart';

import 'linear_progress_indicator.dart' as ProgressIndicator;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  double value;
  bool isLoading = true;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  void startAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    _controller.addListener(() {
      setState(() {
        value = _controller.value;
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 28.0),
              child: ProgressIndicator.LinearProgressIndicator(
                  key: Key("$isLoading}"),
                  value: value,
                  loopAround: isLoading,
                  showInCenter: isLoading,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red)),
            ),
            RawMaterialButton(
              onPressed: () {
                setState(() {
                  isLoading = !isLoading;
                  value = isLoading ? null : 0;
                  if (isLoading) {
                    _controller.stop(canceled: false);
                  } else {
                    _controller.reset();
                    _controller.forward();
                  }
                });
              },
              child: Text(value == null ? "stop loading" : "press to load"),
            )
          ],
        ),
      ),
    );
  }
}
