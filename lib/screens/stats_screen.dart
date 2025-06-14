
// screens/stats_screen.dart
import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep up the good work!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            _buildWeeklyProgress(),
            const SizedBox(height: 24),
            _buildSubjectProgress(),
            const SizedBox(height: 24),
            _buildAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Streak',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDayProgress('M', true),
                _buildDayProgress('T', true),
                _buildDayProgress('W', true),
                _buildDayProgress('T', false),
                _buildDayProgress('F', false),
                _buildDayProgress('S', false),
                _buildDayProgress('S', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayProgress(String day, bool completed) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: completed ? Colors.purple : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: completed
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: completed ? Colors.purple : Colors.grey,
            fontWeight: completed ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectProgress() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subject Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressBar('Math', 0.8, Colors.blue),
            const SizedBox(height: 12),
            _buildProgressBar('Science', 0.6, Colors.green),
            const SizedBox(height: 12),
            _buildProgressBar('History', 0.4, Colors.orange),
            const SizedBox(height: 12),
            _buildProgressBar('Literature', 0.3, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String subject, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(subject),
            Text('${(progress * 100).toInt()}%'),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAchievementItem(
              'Early Bird',
              'Complete 5 lessons before 9am',
              Icons.wb_sunny,
              Colors.orange,
            ),
            const Divider(),
            _buildAchievementItem(
              'Math Wizard',
              'Complete all Math lessons in Term 1',
              Icons.calculate,
              Colors.blue,
            ),
            const Divider(),
            _buildAchievementItem(
              'Perfect Score',
              'Get 100% on 3 consecutive quizzes',
              Icons.military_tech,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(
      String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}