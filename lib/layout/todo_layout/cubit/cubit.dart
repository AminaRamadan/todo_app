import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/layout/todo_layout/cubit/states.dart';
import 'package:todo_app/modules/todo_app/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/todo_app/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/todo_app/new_tasks/new_tasks_screen.dart';


class AppCubit extends Cubit<CubitStates>
{
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> screens =[
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeIndex (int index){
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }
  Database? database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void createDatabase()
  {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version)
      {
        /* id integer
        title string
        date string
        time string
        status string
         */
        print('database created');
        database.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY,title TEXT , date TEXT , time TEXT ,status TEXT)').then((value){
          print('table created');
        }).catchError((error){
          print('Error when creating table ${error.toString()}');
        });
      },
      onOpen: (database)
      {
        getDataFromDatabase(database);
        print('database opened');
      },
    ).then((value)
    {
      database = value;
      emit(AppCreateDatabaseState());
    });

  }

  insertToDatabase({
    required String? title,
    required String? time,
    required String? date,
  }) async{
    await database!.transaction((txn) {
      return txn.rawInsert('INSERT INTO tasks (title,date,time,status) VALUES("$title","$date","$time","new")')
          .then((value){
        print('$value inserted successfully');
        emit(AppInsertDatabaseState());

        getDataFromDatabase(database);
      }).catchError((error){
        print('Error when inserting new record table ${error.toString()}');
      });

    });

  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDatabaseState());
    database.rawQuery('SELECT * FROM tasks').then((value){

      value.forEach((element){
        if(element['status'] == 'new')
          newTasks.add(element);
        else if(element['status'] == 'done')
          doneTasks.add(element);
        else archivedTasks.add(element);

      });

      emit(AppGetDatabaseState());
    });

  }

  void UpdateData({
    required String? status,
    required int id,
  }) async
  {
    database!.rawUpdate(
      'UPDATE tasks SET status =? WHERE id = ?',
      ['$status' , id ],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({
    required int id,
  }) async
  {
    database!.rawUpdate('DELETE FROM tasks WHERE id = ? ',[id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  bool isBottomSheetShown = false ;
  IconData fabIcon = Icons.edit;

  void ChangeBottomSheetState ({
    required bool isShow,
    required IconData icon,
  }){
    isBottomSheetShown = isShow ;
    fabIcon =icon;
    emit(AppChangeBottomSheetState());
  }
}