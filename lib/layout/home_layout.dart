import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/components/components.dart';

import '../modules/archived_tasks_screen.dart';
import '../modules/done_tasks_screen.dart';
import '../modules/new_tasks_screen.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
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
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  List<Map> tasks = [];

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(titles[currentIndex]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isBottomSheetShown) {
            if (formKey.currentState!.validate()) {
              insertToDataBase(
                title: titleController.text,
                time: timeController.text,
                date: dateController.text,
              ).then(
                (value) {
                  Navigator.of(context).pop();
                  isBottomSheetShown = false;
                  setState(() {
                    fabIcon = Icons.edit;
                  });
                },
              );
            }
          } else {
            scaffoldKey.currentState!
                .showBottomSheet(
                  elevation: 20.0,
                  (context) => Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          defaultFormField(
                            controller: titleController,
                            type: TextInputType.text,
                            label: 'Task Title',
                            prefix: Icons.title,
                            validate: (value) {
                              if (value == null || value.isEmpty) {
                                return 'title must not be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          defaultFormField(
                            controller: timeController,
                            type: TextInputType.datetime,
                            label: 'Task Time',
                            prefix: Icons.watch_later_outlined,
                            validate: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Time must not be empty';
                              }
                              return null;
                            },
                            onTap: () {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((value) {
                                timeController.text =
                                    value!.format(context).toString();
                                debugPrint(value.format(context));
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          defaultFormField(
                            controller: dateController,
                            type: TextInputType.datetime,
                            label: 'Task Date',
                            prefix: Icons.calendar_today,
                            validate: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Date must not be empty';
                              }
                              return null;
                            },
                            onTap: () {
                              showDatePicker(
                                      context: context,
                                      firstDate: DateTime.now(),
                                      initialDate: DateTime.now(),
                                      lastDate: DateTime.parse('2025-12-12'))
                                  .then((value) {
                                dateController.text =
                                    DateFormat.yMMMd().format(value!);
                                debugPrint(DateFormat.yMMMd().format(value));
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .closed
                .then((value) {
              isBottomSheetShown = false;
              setState(() {
                fabIcon = Icons.edit;
              });
            });
            isBottomSheetShown = true;
            setState(() {
              fabIcon = Icons.add;
            });
          }
        },
        child: Icon(fabIcon),
      ),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          currentIndex = index;
          setState(() {});
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Done',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            label: 'Archived',
          ),
        ],
      ),
    );
  }

  void createDataBase() async {
    database = await openDatabase(
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
        });
        debugPrint('database opened');
      },
    );
  }

  Future<List<Map>> getDataFromDataBase(Database dataBase) async {
    return await dataBase.rawQuery('SELECT * FROM tasks');
  }

  @override
  void initState() {
    super.initState();
    createDataBase();
  }

  Future insertToDataBase({
    required String title,
    required String time,
    required String date,
  }) async {
    return await database!.transaction(
      (txn) async {
        await txn
            .rawInsert(
                'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
            .then(
          (value) {
            debugPrint('inserted successfully');
          },
        ).catchError(
          (error) {
            debugPrint('Error When Inserting New Record ${error.toString()}');
          },
        );
      },
    );
  }
}
