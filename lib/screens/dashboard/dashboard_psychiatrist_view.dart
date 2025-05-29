import 'package:flutter/material.dart';

class DashboardPsychiatristPage extends StatelessWidget {
  const DashboardPsychiatristPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy patient data (all strings)
    final List<Map<String, String>> patients = [
      {
        'name': 'John Doe',
        'age': '28',
        'patientId': 'PT1001',
        'moodAverage': '3.8',
        'profilePic': 'https://i.pravatar.cc/100?img=8',
      },
      {
        'name': 'Jane Smith',
        'age': '34',
        'patientId': 'PT1002',
        'moodAverage': '4.2',
        'profilePic':
            'https://img.freepik.com/free-psd/portrait-man-teenager-isolated_23-2151745771.jpg',
      },
      {
        'name': 'Michael Lee',
        'age': '40',
        'patientId': 'PT1003',
        'moodAverage': '3.5',
        'profilePic':
            'https://img.freepik.com/free-psd/portrait-man-teenager-isolated_23-2151745771.jpg',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF3F51B5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Patients',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Patient cards
                ...patients.map((patient) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(patient['profilePic']!),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text('Age: ${patient['age']}'),
                              Text('ID: ${patient['patientId']}'),
                              Text(
                                'Mood Avg: ${patient['moodAverage']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 30),

                // Two action buttons in a row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _actionButton('Treatment Plan'),
                    const SizedBox(width: 20),
                    _actionButton('Medication Management'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable square button
  Widget _actionButton(String label) {
    return ElevatedButton(
      onPressed: () {
        // You can add real navigation here later
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        minimumSize: const Size(130, 130),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
      ),
      child: SizedBox(
        width: 100, // control width to allow wrapping
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          softWrap: true,
        ),
      ),
    );
  }
}
