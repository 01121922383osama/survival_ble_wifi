import 'package:flutter/material.dart';
import 'package:survival/core/theme/theme.dart'; // Import theme

// Placeholder for specific report detail pages
class ReportDetailPagePlaceholder extends StatelessWidget {
  final String reportTitle;
  const ReportDetailPagePlaceholder({super.key, required this.reportTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(reportTitle)),
      body: Center(child: Text('Details for $reportTitle')),
    );
  }
}

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a background color consistent with the reference image (e.g., a shade of green)
    // Or use the default scaffold background and style cards

    return Scaffold(
      backgroundColor: accentGreen.withValues(alpha: 0.9),
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: accentGreen,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildReportCard(
            context,
            title: 'Movement Report',
            subtitle: 'Daily movement and activity levels',
            icon: Icons.directions_run,
            iconBackgroundColor: Colors.blue.shade100,
            iconColor: Colors.blue.shade800,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportDetailPagePlaceholder(
                    reportTitle: 'Movement Report',
                  ),
                ),
              );
            },
          ),
          _buildReportCard(
            context,
            title: 'Fall Report',
            subtitle: 'Log of fall incidents and alerts',
            icon: Icons.warning_amber_rounded, // Example icon
            iconBackgroundColor: Colors.orange.shade100,
            iconColor: Colors.orange.shade800,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportDetailPagePlaceholder(
                    reportTitle: 'Fall Report',
                  ),
                ),
              );
            },
          ),
          _buildReportCard(
            context,
            title: 'Occupancy Report',
            subtitle: 'Room and area occupancy rates',
            icon: Icons.people_outline, // Example icon
            iconBackgroundColor: Colors.purple.shade100,
            iconColor: Colors.purple.shade800,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportDetailPagePlaceholder(
                    reportTitle: 'Occupancy Report',
                  ),
                ),
              );
            },
          ),
          _buildReportCard(
            context,
            title: 'Maintenance Report',
            subtitle: 'Device status and maintenance schedules',
            icon: Icons.build_outlined, // Example icon
            iconBackgroundColor: Colors.grey.shade300,
            iconColor: Colors.grey.shade800,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportDetailPagePlaceholder(
                    reportTitle: 'Maintenance Report',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    // Use Card styling from the theme, but override color if needed
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      // Use a darker card color if on a light background, or light on dark
      color: Theme.of(context).cardTheme.color ?? Colors.white,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        leading: CircleAvatar(
          backgroundColor: iconBackgroundColor,
          radius: 24,
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
