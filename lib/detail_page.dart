import 'package:flutter/material.dart';
import 'services/database_util.dart';

class DetailPage extends StatefulWidget {
  final String name;
  final String species;
  final int animalId;
  final VoidCallback onDelete;

  const DetailPage({
    super.key,
    required this.name,
    required this.species,
    required this.animalId,
    required this.onDelete,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    var data = await DatabaseUtil.getTasks(widget.animalId);
    setState(() {
      tasks = List<Map<String, dynamic>>.from(data);
    });
  }

  void _toggleTask(int index) async {
    var original = tasks[index];
    var task = Map<String, dynamic>.from(original);
    task['done'] = task['done'] == 1 ? 0 : 1;
    await DatabaseUtil.updateTask(task);
    _loadTasks();
  }

  void _addTask(String description) async {
    await DatabaseUtil.insertTask({
      'animal_id': widget.animalId,
      'description': description,
      'done': 0,
    });
    _loadTasks();
  }

  void _removeTask(int index) async {
    await DatabaseUtil.deleteTask(tasks[index]['id']);
    _loadTasks();
  }

  void _showAddTaskDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Add Task"),
            content: TextField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: "Task Description"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _addTask(ctrl.text);
                  Navigator.of(ctx).pop();
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text(widget.name),
        subtitle: Text(widget.species),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: widget.onDelete,
        ),
        children: [
          ...tasks.map(
            (task) => CheckboxListTile(
              title: Text(task['description']),
              value: task['done'] == 1,
              onChanged: (_) => _toggleTask(tasks.indexOf(task)),
              secondary: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeTask(tasks.indexOf(task)),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _showAddTaskDialog,
            icon: const Icon(Icons.add),
            label: const Text("Add Task"),
          ),
        ],
      ),
    );
  }
}
