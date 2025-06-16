import 'dart:convert';
import 'dart:io';

class ApiUtil {
  static const String baseUrl = 'http://localhost:8080';

  static Future<List<dynamic>> fetchAnimals() async {
    final uri = Uri.parse('$baseUrl/animals');
    final res = await HttpClient().getUrl(uri).then((req) => req.close());
    final body = await res.transform(utf8.decoder).join();
    return jsonDecode(body);
  }

  static Future<Map<String, dynamic>> addAnimal(
    String name,
    String species,
  ) async {
    final uri = Uri.parse('$baseUrl/animals');
    final req = await HttpClient().postUrl(uri);
    req.headers.set('Content-Type', 'application/json');
    req.add(utf8.encode(jsonEncode({'name': name, 'species': species})));
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    return jsonDecode(body);
  }

  static Future<void> deleteAnimal(String id) async {
    final uri = Uri.parse('$baseUrl/animals/$id');
    await HttpClient().deleteUrl(uri).then((req) => req.close());
  }

  static Future<List<dynamic>> fetchTasks(String animalId) async {
    final uri = Uri.parse('$baseUrl/tasks/$animalId');
    final res = await HttpClient().getUrl(uri).then((req) => req.close());
    final body = await res.transform(utf8.decoder).join();
    return jsonDecode(body);
  }

  static Future<Map<String, dynamic>> addTask(
    String animalId,
    String description,
  ) async {
    final uri = Uri.parse('$baseUrl/tasks');
    final req = await HttpClient().postUrl(uri);
    req.headers.set('Content-Type', 'application/json');
    req.add(
      utf8.encode(
        jsonEncode({'animal_id': animalId, 'description': description}),
      ),
    );
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    return jsonDecode(body);
  }

  static Future<void> updateTask(
    String id,
    String description,
    bool done,
  ) async {
    final uri = Uri.parse('$baseUrl/tasks/$id');
    final req = await HttpClient().putUrl(uri);
    req.headers.set('Content-Type', 'application/json');
    req.add(
      utf8.encode(
        jsonEncode({'description': description, 'done': done ? 1 : 0}),
      ),
    );
    await req.close();
  }

  static Future<void> deleteTask(String id) async {
    final uri = Uri.parse('$baseUrl/tasks/$id');
    await HttpClient().deleteUrl(uri).then((req) => req.close());
  }
}
