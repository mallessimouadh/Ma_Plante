import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(context) {
    return Container(
      color: Colors.grey[900],
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/homepage');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.white),
            title: const Text(
              'User Management',
              style: TextStyle(color: Colors.white),
            ),
            selected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          ListTile(
            leading: const Icon(Icons.report, color: Colors.white),
            title: const Text(
              'Reclamations',
              style: TextStyle(color: Colors.white),
            ),
            selected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),
        ],
      ),
    );
  }
}
