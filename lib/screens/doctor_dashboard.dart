import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
            },
          )
        ],
      ),
      body: const Center(child: Text('Welcome Doctor 👨‍⚕️')),
    );
  }
}
