import 'package:flutter/material.dart';

class Student {
  int id;
  String name;
  int age;
  String gender;
  int course;
  String group;

  Student({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.course,
    required this.group,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      course: json['course'],
      group: json['group'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'course': course,
      'group': group,
    };
  }
}
