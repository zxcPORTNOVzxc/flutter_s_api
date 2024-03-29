import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'student_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Student> students = [];

  Future<void> fetchStudents() async {
    final response = await http.get(Uri.parse('https://воображаемый_сервак.com/api/students'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        students = responseData.map((data) => Student.fromJson(data)).toList();
      });
    } else {
      throw Exception('Ошибка загрузки списка');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Главная'),
        ),
        body: ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Студент ${index + 1}'),
                    const SizedBox(height: 8.0),
                    Text('ФИО: ${students[index].name}'),
                    Text('Возраст: ${students[index].age}'),
                    Text('Пол: ${students[index].gender}'),
                    Text('Курс: ${students[index].course}'),
                    Text('Группа: ${students[index].group}'),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showEditStudentDialog(context, students[index], index);
                          },
                          child: const Text('Изменить'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _deleteStudent(students[index]);
                          },
                          child: const Text('Удалить'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddStudentDialog(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _addStudent(Student student) async {
    final response = await http.post(
      Uri.parse('https://воображаемый_сервак.com/api/students/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(student.toJson()),
    );

    if (response.statusCode == 201) {
      fetchStudents();
    } else {
      throw Exception('Ошибка добавления студента');
    }
  }

  Future<void> _editStudent(Student student, int index) async {
    final response = await http.put(
      Uri.parse('https://воображаемый_сервак.com/api/students/${student.id}/update'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(student.toJson()),
    );

    if (response.statusCode == 200) {
      fetchStudents();
    } else {
      throw Exception('Ошибка изменения студента');
    }
  }

  Future<void> _deleteStudent(Student student) async {
    final response = await http.delete(
      Uri.parse('https://воображаемый_сервак.com/api/students/${student.id}/delete'),
    );

    if (response.statusCode == 200) {
      fetchStudents();
    } else {
      throw Exception('Ошибка удаления студента');
    }
  }

 void _showAddStudentDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController genderController = TextEditingController();
    final TextEditingController courseController = TextEditingController();
    final TextEditingController groupController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Добавить студента'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'ФИО'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Возраст'),
                ),
                TextField(
                  controller: genderController,
                  decoration: const InputDecoration(labelText: 'Пол'),
                ),
                TextField(
                  controller: courseController,
                  decoration: const InputDecoration(labelText: 'Курс'),
                ),
                TextField(
                  controller: groupController,
                  decoration: const InputDecoration(labelText: 'Группа'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    ageController.text.isNotEmpty &&
                    int.tryParse(ageController.text) != null &&
                    genderController.text.isNotEmpty &&
                    courseController.text.isNotEmpty &&
                    int.tryParse(courseController.text) != null &&
                    groupController.text.isNotEmpty) {
                  final newStudent = Student(
                    id: 0, 
                    name: nameController.text,
                    age: int.tryParse(ageController.text) ?? 0,
                    gender: genderController.text,
                    course: int.tryParse(courseController.text) ?? 0,
                    group: groupController.text,
                  );
                  _addStudent(newStudent); 
                  Navigator.pop(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Ошибка'),
                        content: const Text('Заполните все поля формы и введите корректные значения.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _showEditStudentDialog(BuildContext context, Student student, int index) async {
    final TextEditingController nameController = TextEditingController(text: student.name);
    final TextEditingController ageController = TextEditingController(text: student.age.toString());
    final TextEditingController genderController = TextEditingController(text: student.gender);
    final TextEditingController courseController = TextEditingController(text: student.course.toString());
    final TextEditingController groupController = TextEditingController(text: student.group);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Изменить данные студента'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'ФИО'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Возраст'),
                ),
                TextField(
                  controller: genderController,
                  decoration: const InputDecoration(labelText: 'Пол'),
                ),
                TextField(
                  controller: courseController,
                  decoration: const InputDecoration(labelText: 'Курс'),
                ),
                TextField(
                  controller: groupController,
                  decoration: const InputDecoration(labelText: 'Группа'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    ageController.text.isNotEmpty &&
                    int.tryParse(ageController.text) != null &&
                    genderController.text.isNotEmpty &&
                    courseController.text.isNotEmpty &&
                    int.tryParse(courseController.text) != null &&
                    groupController.text.isNotEmpty) {
                  final editedStudent = Student(
                    id: student.id,
                    name: nameController.text,
                    age: int.tryParse(ageController.text) ?? student.age,
                    gender: genderController.text,
                    course: int.tryParse(courseController.text) ?? student.course,
                    group: groupController.text,
                  );
                  _editStudent(editedStudent, index); 
                  Navigator.pop(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Ошибка'),
                        content: const Text('Заполните все поля формы и введите корректные значения.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}

