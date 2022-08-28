// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/cubit/states.dart';

import '../../modules/archived_tasks.dart';
import '../../modules/done_tasks.dart';
import '../../modules/new_tasks.dart';
import '../components/constants.dart';



class AppCubit extends Cubit<AppStates>{

  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);


  int currentIndex = 0;

  List<Widget> screens = [
    NewTasks(),
    DoneTasks(),
    ArchivedTasks(),
  ];

  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeIndex(int index)
  {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }


  IconData fabIcon = Icons.edit;

  Database? database;
  bool isBottomSheetShown = false;

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database.execute(
            'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('error ${error.toString()}');
        });
      },
      onOpen: (database)
      {
        getDateFromDatabase(database);
        print('database opened');
      },
    ).then((value)
    {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database!.transaction((txn) {
      return txn
          .rawInsert(
          'INSERT INTO tasks(title,date,time,status) VALUES("$title","$date","$time","new")'
      ).then((value) {
        print('$value inserted successfully');
        emit(AppInsertDatabaseState());
        getDateFromDatabase(database);
      }).catchError((error) {
        print(error.toString());
      });
    });
  }


  void getDateFromDatabase(database)
  {
    newTasks =[];
    doneTasks =[];
    archivedTasks =[];

    emit(AppGetDatabaseLoadingState());
    database!.rawQuery('SELECT * FROM tasks').then((value){


      value.forEach((element) {
        if(element['status'] == 'new')
        {
          newTasks.add(element);
        }else if(element['status']== 'Done')
        {
          doneTasks.add(element);
        }else
        {
          archivedTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  void changeBottomSheetState({
  required bool isShow,
    required IconData icon,
})
  {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }

  void updateData({
    required String status,
    required int id,
}) async
  {
    database!.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        [status, id]).then(
        (value)
        {
          getDateFromDatabase(database);
          emit(AppUpdateDatabaseState());
        }
    );


  }

  void deleteData({
    required int id,
  }) async
  {
    database!.rawDelete('DELETE FROM tasks WHERE id = ?', [id],)
         .then(
            (value)
        {
          getDateFromDatabase(database);
          emit(AppDeleteDatabaseState());
        }
    );


  }
}