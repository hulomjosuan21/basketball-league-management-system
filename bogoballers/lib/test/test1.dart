import 'package:flutter/material.dart';

class SportsDashboardCard extends StatelessWidget {
  const SportsDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          width: 350,
          height: 200,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53), Color(0xFFFFA366)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withAlpha((0.3 * 255).toInt()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background basketball icon
              Positioned(
                right: -100,
                top: -20,
                child: Icon(
                  Icons.sports_basketball,
                  size: 200,
                  color: Colors.white.withAlpha((0.1 * 255).toInt()),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // League Points
                    const Text(
                      'League Points: 24k',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    // Main number and label
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '4',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Scheduled Games',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.circle, color: Colors.white, size: 6),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Bottom navigation tabs
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _buildNavTab('League', Icons.emoji_events, true),
                          _buildNavTab('Team', Icons.group, false),
                          _buildNavTab('Records', Icons.bar_chart, false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab(String title, IconData icon, bool isActive) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withAlpha((0.2 * 255).toInt())
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example usage in a screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Sports Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(child: SportsDashboardCard()),
    );
  }
}
