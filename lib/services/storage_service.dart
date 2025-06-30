import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:optical_power_budget/models/project.dart';

class StorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/projects.json');
  }

  Future<List<Project>> loadProjects() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> json = jsonDecode(contents);
      return json.map((e) => Project.fromJson(e)).toList();
    } catch (e) {
      print('Error loading projects: $e');
      return [];
    }
  }

  Future<void> saveProjects(List<Project> projects) async {
    try {
      final file = await _localFile;
      final json = projects.map((e) => e.toJson()).toList();
      await file.writeAsString(jsonEncode(json));
    } catch (e) {
      print('Error saving projects: $e');
    }
  }

  Future<void> saveProject(Project project) async {
    final projects = await loadProjects();
    // Remove existing project with the same name to avoid duplicates
    projects.removeWhere((p) => p.name == project.name);
    projects.add(project);
    await saveProjects(projects);
  }
}
