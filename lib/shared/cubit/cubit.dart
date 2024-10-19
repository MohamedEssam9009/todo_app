import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'states.dart';

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

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

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
        getDataFromDataBase(dataBase);
        debugPrint('database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  void getDataFromDataBase(Database dataBase) {
    
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppGetDatabaseLoadingState());

    dataBase.rawQuery('SELECT * FROM tasks').then((value) {
      for (var element in value) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      }

      emit(AppGetDatabaseState());
    }).catchError((error) {
      debugPrint('Error When Getting Data From Table ${error.toString()}');
    });
  }

  void updateData({required String status, required int id}) async {
    database!.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        [status, '$id']).then((value) {
      getDataFromDataBase(database!);
      emit(AppUpdateDatabaseState());
    });
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
            getDataFromDataBase(database!);
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
