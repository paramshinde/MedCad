import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterDoctorScreen extends StatelessWidget {
  const RegisterDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final specCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            TextField(controller: specCtrl, decoration: const InputDecoration(labelText: 'Specialization')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await AuthService().registerDoctor(
                  name: nameCtrl.text,
                  email: emailCtrl.text,
                  password: passCtrl.text,
                  specialization: specCtrl.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
