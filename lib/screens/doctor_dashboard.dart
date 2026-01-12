import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Doctor 👨‍⚕️',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              _dashboardButton(
                context,
                label: 'Create Prescription',
                icon: Icons.note_add,
                route: '/doctor-create',
              ),

              _dashboardButton(
                context,
                label: 'Search Patient',
                icon: Icons.search,
                route: '/doctor-search',
              ),

              _dashboardButton(
                context,
                label: 'Search Medicine',
                icon: Icons.medical_services,
                route: '/doctor-med-search',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}
