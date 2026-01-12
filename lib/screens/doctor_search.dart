import 'package:flutter/material.dart';

class DoctorSearchScreen extends StatelessWidget {
  const DoctorSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Patient')),
      body: const Center(
        child: Text('Patient search goes here'),
      ),
    );
  }
}
