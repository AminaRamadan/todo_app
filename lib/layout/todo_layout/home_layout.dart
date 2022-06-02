import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/layout/todo_layout/cubit/cubit.dart';
import 'package:todo_app/layout/todo_layout/cubit/states.dart';


//1.create Database
//11.cteate tables
//2. open database
//3.insert to database
//4.get from database
//5.update in database
//6.delete from database

class HomeLayout  extends StatelessWidget
{

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit , CubitStates>(
        listener: (BuildContext context,CubitStates state) {
          if(state is AppInsertDatabaseState){
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, CubitStates? state)
        {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) =>cubit.screens[cubit.currentIndex] ,
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),

            floatingActionButton: FloatingActionButton(
              onPressed: ()
              {
                if(cubit.isBottomSheetShown){
                  if(formKey.currentState!.validate()){
                    cubit.insertToDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text
                    );
                  }
                }
                else{
                  scaffoldKey.currentState!.showBottomSheet(
                        (context)=> Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: titleController,
                              keyboardType: TextInputType.text,
                              validator: (String? value){
                                if(value!.isEmpty){
                                  return 'title must not be empty';
                                }
                                return null;
                              },
                              decoration : const InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.title),
                                labelText: 'Task Title',
                              ),

                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            TextFormField(
                              controller: timeController,
                              keyboardType: TextInputType.datetime,
                              onTap: () {
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((value) {
                                  timeController.text = value!.format(context).toString();
                                });
                              },
                              validator: (String? value){
                                if(value!.isEmpty){
                                  return 'time must not be empty';
                                }
                                return null;
                              },
                              decoration : const InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.access_time,
                                ),
                                labelText: 'Task Time',
                              ),

                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            TextFormField(
                              controller: dateController,
                              keyboardType: TextInputType.datetime,
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.parse('2022-07-01'),
                                ).then((value) {
                                  dateController.text = DateFormat.yMMMd().format(value!);
                                });
                              },
                              validator: (String? value){
                                if(value!.isEmpty){
                                  return 'date must not be empty';
                                }
                                return null;
                              },
                              decoration : const InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.calendar_today,
                                ),
                                labelText: 'Task Date',
                              ),

                            ),
                          ],
                        ),
                      ),
                    ),
                    elevation: 20.0,
                  ).closed.then((value)
                  {
                    cubit.ChangeBottomSheetState(isShow: false, icon: Icons.edit);

                  });
                  cubit.ChangeBottomSheetState(isShow: true, icon: Icons.add);

                }
              },

              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar (
                type: BottomNavigationBarType.fixed,
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changeIndex(index);

                },
                items:[
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.menu,
                    ),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.check_circle_outline,
                    ),
                    label: 'Done',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.archive_outlined,
                    ),
                    label: 'Archive',
                  ),
                ]
            ),


          );
        },

      ),
    );
  }


}




