import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('tasks');
  runApp(const MyApp());
}

/* -------------------- APP ROOT -------------------- */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hive Todo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const TodoPage(),
    );
  }
}

/* -------------------- MODEL -------------------- */

class Task {
  String title;
  bool isDone;

  Task({required this.title, required this.isDone});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
    };
  }

  factory Task.fromMap(Map map) {
    return Task(
      title: map['title'],
      isDone: map['isDone'],
    );
  }
}

/* -------------------- TODO PAGE -------------------- */

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final Box tasksBox = Hive.box('tasks');
  final TextEditingController _controller = TextEditingController();

  void addTask(String title) {
    if (title.trim().isEmpty) return;

    final task = Task(title: title, isDone: false);
    tasksBox.add(task.toMap());
    _controller.clear();
    setState(() {});
  }

  void toggleTask(int index) {
    final taskMap = tasksBox.getAt(index);
    final task = Task.fromMap(taskMap);
    task.isDone = !task.isDone;
    tasksBox.putAt(index, task.toMap());
    setState(() {});
  }

  void deleteTask(int index) {
    tasksBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Todo'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add a new task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => addTask(_controller.text),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: tasksBox.listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tasks yet',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final task = Task.fromMap(box.getAt(index));

                    return ListTile(
                      leading: Checkbox(
                        value: task.isDone,
                        onChanged: (_) => toggleTask(index),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTask(index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
