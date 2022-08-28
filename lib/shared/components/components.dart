// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, avoid_print, prefer_is_empty

import 'package:bloc/bloc.dart';
import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../cubit/cubit.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  void Function(String)? onSubmit,
  void Function(String)? onChanged,
  void Function()? onTap,
  required String? Function(String?)? validate,
  required String? label,
  required IconData? prefix,
  bool isClickable = true,

}) => TextFormField(
  controller: controller,
  enabled: isClickable,
  keyboardType: type,
  onFieldSubmitted: onSubmit,
  onTap: onTap,
  onChanged: onChanged,
  validator: validate,
  decoration: InputDecoration(
    labelText: label,
    prefixIcon: Icon(prefix),
    border: OutlineInputBorder(),

  ),

);





Widget buildTaskItem(Map model,context,) => Dismissible(
  key: Key('${model['id']}'),
  child:   Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      children:
      [
        CircleAvatar(
          radius: 45,
          child: Text(
            '${model['time']}',
            style: TextStyle(fontSize: 25),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children:
            [
              Text(
                '${model['title']}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 15,),
              Text(
                '${model['date']}',
                style: TextStyle(
                    color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 20,
        ),
        IconButton(
            onPressed: ()
            {
              AppCubit.get(context).updateData(
                  status: 'Done',
                  id: model['id'],
              );
              print('task complete');
            },
            icon: Icon(Icons.check_circle_outline),
          color: Colors.grey,
        ),
        IconButton(
            onPressed: ()
            {
              AppCubit.get(context).updateData(
                status: 'Archive',
                id: model['id'],
              );
              print('task archived');
            },
            icon: Icon(Icons.archive_outlined),
          color: Colors.black54,
        ),
  
      ],
    ),
  ),
  onDismissed: (direction)
  {
    AppCubit.get(context).deleteData(id: model['id'],);
  },
);

Widget myDivider() => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 15),
  child:   Container(
    color: Colors.grey,
    height: 1,
    width: double.infinity,
  ),
);


Widget taskBuilder({required List<Map> tasks}) => ConditionalBuilder(
  condition: tasks.length > 0,
  builder: (context) => ListView.separated(
    itemBuilder: (context, index) => buildTaskItem(tasks[index],context),
    separatorBuilder: (context, index) => myDivider(),
    itemCount: tasks.length,
  ),
  fallback: (context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
      [
        Icon(Icons.menu,
          size: 100,
          color: Colors.grey,),
        Text('Add Tasks',style: TextStyle(fontSize: 40,color: Colors.grey,fontWeight: FontWeight.bold),),
      ],
    ),
  ),

);