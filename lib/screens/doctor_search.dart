import 'package:flutter/material.dart';

class DoctorSearchScreen extends StatelessWidget {
  const DoctorSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 58, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(color: Color(0xD9FFFFFF), fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Dr. Sharma',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Let's take care of your patients today",
                    style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardShell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: const [
                              Expanded(
                                child: _GradientActionButton(
                                  title: 'Create\nPrescription',
                                  icon: Icons.add_circle_outline_rounded,
                                  colors: [
                                    Color(0xFF0891B2),
                                    Color(0xFF06B6D4)
                                  ],
                                  route: '/doctor-create',
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _GradientActionButton(
                                  title: 'Search\nMedicine',
                                  icon: Icons.search_rounded,
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFF059669)
                                  ],
                                  route: '/doctor-med-search',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: null,
                            icon: Icon(Icons.list_alt_rounded),
                            label: Text('View All Prescriptions'),
                            style: ButtonStyle(
                              minimumSize: WidgetStatePropertyAll(Size(0, 46)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        "Today's Overview",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            icon: Icons.description_outlined,
                            iconColor: Color(0xFF0891B2),
                            label: 'Total Prescriptions',
                            value: '124',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _StatTile(
                            icon: Icons.groups_rounded,
                            iconColor: Color(0xFF10B981),
                            label: "Today's Patients",
                            value: '18',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const _StatTile(
                      icon: Icons.trending_up_rounded,
                      iconColor: Color(0xFF06B6D4),
                      label: 'This Week',
                      value: '67 Prescriptions',
                    ),
                    const SizedBox(height: 18),
                    _CardShell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Recent Prescriptions',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 12),
                          _RecentTile(
                            patientName: 'Sarah Johnson',
                            timeLabel: 'Today, 2:30 PM',
                            medicineCount: 3,
                          ),
                          SizedBox(height: 10),
                          _RecentTile(
                            patientName: 'Michael Chen',
                            timeLabel: 'Today, 11:45 AM',
                            medicineCount: 2,
                          ),
                          SizedBox(height: 10),
                          _RecentTile(
                            patientName: 'Emma Williams',
                            timeLabel: 'Yesterday, 4:15 PM',
                            medicineCount: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> colors;
  final String route;

  const _GradientActionButton({
    required this.title,
    required this.icon,
    required this.colors,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final String patientName;
  final String timeLabel;
  final int medicineCount;

  const _RecentTile({
    required this.patientName,
    required this.timeLabel,
    required this.medicineCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF0891B2),
            child: Text(
              patientName.substring(0, 1),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patientName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(timeLabel,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          Text(
            '$medicineCount meds',
            style: const TextStyle(
              color: Color(0xFF0891B2),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
