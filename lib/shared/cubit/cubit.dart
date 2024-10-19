import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/cubit/states.dart';

import '../../modules/archived_tasks_screen.dart';
import '../../modules/done_tasks_screen.dart';
import '../../modules/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;

  List<Widget> screens = const [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];
  Database? database;

  List<Map> tasks = [];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDataBase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (dataBase, version) {
        debugPrint('database created');
        dataBase
            .execute(
                'CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then(
          (value) {
            debugPrint('table created');
          },
        ).catchError(
          (error) {
            debugPrint('Error When Creating Table ${error.toString()}');
          },
        );
      },
      onOpen: (dataBase) {
        getDataFromDataBase(dataBase).then((value) {
          tasks = value;
          emit(AppGetDatabaseState());
          debugPrint(tasks.toString());
        }).catchError((error) {
          debugPrint('Error When Getting Data From Table ${error.toString()}');
        });
        debugPrint('database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  Future<List<Map>> getDataFromDataBase(Database dataBase) async {
    emit(AppGetDatabaseLoadingState());
    return await dataBase.rawQuery('SELECT * FROM tasks');
  }

  insertToDataBase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database!.transaction(
      (txn) async {
        await txn
            .rawInsert(
                'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
            .then(
          (value) {
            debugPrint('inserted successfully');
            emit(AppInsertDatabaseState());
            getDataFromDataBase(database!).then(
              (value) {
                tasks = value;
                emit(AppGetDatabaseState());
            });
          },
        ).catchError(
          (error) {
            debugPrint('Error When Inserting New Record ${error.toString()}');
          },
        );
      },
    );
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }
}
