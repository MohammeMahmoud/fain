import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:nctu/screens/subjects.dart';
import 'package:nctu/screens/tasks.dart';
import 'package:nctu/screens/profile.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

import '../screens/Home.dart';

class AppRoutes extends StatefulWidget {
  @override
  _AppRoutesState createState() => _AppRoutesState();
}

class _AppRoutesState extends State<AppRoutes> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {'page': HomePage(), 'title': 'Home'},
    {'page': TaskPage(), 'title': 'Tasks'},
    {'page': SubjectsPage(), 'title': 'Subjects'},
    {'page': ProfileScreen(), 'title': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _pages[_selectedIndex]['title'],
          style: const TextStyle(
            color: Color(0xFF3366FF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages.map<Widget>((page) => page['page']).toList(),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GNav(
            gap: 8,
            activeColor: Colors.white,
            color: Colors.grey,
            tabBackgroundColor: Colors.blue.shade300,
            padding: const EdgeInsets.all(16),
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: const [
              GButton(
                icon: Icons.home_filled,
                text: "Home",
              ),
              GButton(icon: Icons.task, text: 'Tasks'),
              GButton(icon: Icons.subject, text: 'Subjects'),
              GButton(icon: Icons.person, text: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}