import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

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

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Студенты',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
      ),
      home: const LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

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

    if (response.statusCode == 200) {
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

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Войти'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _login(String username, String password) async {
    final url = Uri.parse('https://воображаемый_сервак.com/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Ошибка входа'),
            content: const Text('Неверное имя пользователя или пароль.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Логин'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите имя пользователя';
              }
              return null;
            },
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Пароль'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите пароль';
              }
              return null;
            },
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                String username = _usernameController.text;
                String password = _passwordController.text;
                _login(username, password);
              }
            },
            child: const Text('Вход'),
          ),
        ],
      ),
    );
  }
}

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: RegistrationForm(),
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({Key? key});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _register(String username, String password) async {
    final url = Uri.parse('https://воображаемый_сервак.com/api/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

 if (response.statusCode == 200) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const HomePage()),
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Успешная регистрация'),
        content: const Text('Пользователь успешно зарегистрирован.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
} else {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Ошибка регистрации'),
        content: const Text('Не удалось зарегистрировать пользователя.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
}

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Имя пользователя'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите имя пользователя';
              }
              return null;
            },
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Пароль'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите пароль';
              }
              return null;
            },
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                String username = _usernameController.text;
                String password = _passwordController.text;
                _register(username, password);
              }
            },
            child: const Text('Регистрация'),
          ),
        ],
      ),
    );
  }
}
