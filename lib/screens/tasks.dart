import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Models/task_model.dart';
import '../provider/auth_provider.dart';
import '../web_service/task_service.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Data> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final username = authProvider.user!.username!;
        print('Fetching tasks for username: $username');
        final fetchedTasks = await TaskService.fetchTasks(username);
        if (fetchedTasks != null) {
          setState(() {
            tasks = fetchedTasks;
          });
          print('Number of tasks loaded: ${tasks.length}');
        }
      }
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Data> _getFilteredTasks() {
    return tasks; // Remove filtering logic, just return all tasks
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Remove filter tabs section entirely
          const SizedBox(height: 16),

          // Task list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTasks.isEmpty
                    ? const Center(child: Text('No tasks available'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskCard(filteredTasks[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Data task) {
    final dueDate = task.deadline != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(task.deadline!)) : 'No deadline';
    final daysLeft = task.deadline != null ? DateTime.parse(task.deadline!).difference(DateTime.now()).inDays : 0;
    final isOverdue = daysLeft < 0; //&& !task.isCompleted;

    // Determine due date badge color
    Color badgeColor;
    if (isOverdue) {
      badgeColor = Colors.red.shade400; // Red for overdue
    } else if (daysLeft <= 7) {
      badgeColor = Colors.orange.shade400; // Orange for due soon (within 7 days)
    } else {
      badgeColor = Colors.grey.shade400; // Grey for distant due dates
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 18, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${task.createdBy}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: badgeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due: $dueDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Task title
            Text(
              task.title ?? 'Untitled Task',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Task description
            Text(
              task.description ?? 'No description',
              style: TextStyle(
                color: Colors.grey[600],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            // No explicit specifications field in API, omitting for now
          ],
        ),
      ),
    );
  }
}
