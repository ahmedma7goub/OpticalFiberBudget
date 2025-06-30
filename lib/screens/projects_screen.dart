import 'package:flutter/material.dart';
import 'package:optical_power_budget/models/project.dart';
import 'package:optical_power_budget/services/storage_service.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final StorageService _storageService = StorageService();
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = _storageService.loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Projects'),
      ),
      body: FutureBuilder<List<Project>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No saved projects found.'));
          }

          final projects = snapshot.data!;
          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return ListTile(
                title: Text(project.name),
                subtitle: Text('Wavelength: ${project.wavelength}nm'),
                onTap: () {
                  Navigator.of(context).pop(project);
                },
              );
            },
          );
        },
      ),
    );
  }
}
