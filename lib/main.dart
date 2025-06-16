import 'package:flutter/material.dart';
import 'detail_page.dart';
import 'services/database_util.dart';
import 'services/api_util.dart';

bool useApi = false;

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
  int _currentIndex = 0;

  final _pages = [const AnimalListPage(), const SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.pets), label: "Animals"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

class AnimalListPage extends StatefulWidget {
  const AnimalListPage({super.key});

  @override
  State<AnimalListPage> createState() => _AnimalListPageState();
}

class _AnimalListPageState extends State<AnimalListPage> {
  List<Map<String, dynamic>> animals = [];

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  void _loadAnimals() async {
    if (useApi) {
      final data = await ApiUtil.fetchAnimals();
      setState(() => animals = List<Map<String, dynamic>>.from(data));
    } else {
      final data = await DatabaseUtil.getAllEntries();
      setState(() => animals = List<Map<String, dynamic>>.from(data));
    }
  }

  void _addAnimal(String name, String species) async {
    Map<String, dynamic> newAnimal;
    if (useApi) {
      newAnimal = await ApiUtil.addAnimal(name, species);
    } else {
      newAnimal = await DatabaseUtil.insertOrUpdateEntry({
        'name': name,
        'species': species,
      });
    }
    setState(() => animals.add(newAnimal));
  }

  void _removeAnimal(int index) async {
    final id = animals[index]['id'];
    if (useApi) {
      await ApiUtil.deleteAnimal(id);
    } else {
      await DatabaseUtil.deleteEntry(animals[index]);
    }
    setState(() => animals.removeAt(index));
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
      appBar: AppBar(title: Text("ZooCare (${useApi ? 'API' : 'Local'})")),
      body: ListView.builder(
        itemCount: animals.length,
        itemBuilder:
            (ctx, i) => DetailPage(
              name: animals[i]['name'],
              species: animals[i]['species'],
              animalId: animals[i]['id'].toString(),
              onDelete: () => _removeAnimal(i),
              useApi: useApi,
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SwitchListTile(
        title: const Text("Use Remote API"),
        value: useApi,
        onChanged: (val) {
          setState(() => useApi = val);
        },
      ),
    );
  }
}
