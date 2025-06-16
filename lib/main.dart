import 'package:flutter/material.dart';
import 'detail_page.dart';
import 'services/database_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseUtil.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZooCare Task Manager',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> animals = [];

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  void _loadAnimals() async {
    var data = await DatabaseUtil.getAllEntries();
    setState(() {
      animals = List<Map<String, dynamic>>.from(data);
    });
  }

  void _addAnimal(String name, String species) async {
    var newAnimal = await DatabaseUtil.insertOrUpdateEntry({
      'name': name,
      'species': species,
    });
    setState(() {
      animals.add(newAnimal);
    });
  }

  void _removeAnimal(int index) async {
    await DatabaseUtil.deleteEntry(animals[index]);
    setState(() {
      animals.removeAt(index);
    });
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final speciesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Add Animal"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Animal Name'),
                ),
                TextField(
                  controller: speciesCtrl,
                  decoration: const InputDecoration(labelText: 'Species'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _addAnimal(nameCtrl.text, speciesCtrl.text);
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
    return Scaffold(
      appBar: AppBar(title: const Text("ZooCare Task Manager")),
      body: ListView.builder(
        itemCount: animals.length,
        itemBuilder:
            (ctx, i) => DetailPage(
              name: animals[i]['name'],
              species: animals[i]['species'],
              animalId: animals[i]['id'],
              onDelete: () => _removeAnimal(i),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
