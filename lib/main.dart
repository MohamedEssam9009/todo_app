import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'layout/home_layout.dart';

import 'shared/bloc_observer.dart';

void main() {
  Bloc.observer = MyBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(useMaterial3: false),
      home:  HomeLayout(),
    );
  }
}
