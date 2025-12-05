import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _aiModelVersion = 'Standard (Default)';
  double _confidenceThreshold = 0.8;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _buildSettingsSection(
            context,
            title: 'General Settings',
            children: [
              _buildSwitchSetting(
                context,
                title: 'Enable Notifications',
                subtitle:
                    'Receive notifications for new reclamations and detections',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              _buildSwitchSetting(
                context,
                title: 'Dark Mode',
                subtitle: 'Toggle between light and dark theme',
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Theme settings would update app-wide in a real implementation',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            title: 'AI Model Settings',
            children: [
              _buildDropdownSetting(
                context,
                title: 'AI Model Version',
                subtitle: 'Select the AI model version for disease detection',
                value: _aiModelVersion,
                items: const [
                  'Standard (Default)',
                  'High Precision',
                  'Fast Detection',
                  'Experimental',
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _aiModelVersion = value;
                    });
                  }
                },
              ),
              _buildSliderSetting(
                context,
                title: 'Confidence Threshold',
                subtitle:
                    'Minimum confidence level for disease detection (${(_confidenceThreshold * 100).toInt()}%)',
                value: _confidenceThreshold,
                min: 0.5,
                max: 0.95,
                onChanged: (value) {
                  setState(() {
                    _confidenceThreshold = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            title: 'System Information',
            children: [
              _buildInfoSetting(context, title: 'App Version', value: '1.0.0'),
              _buildInfoSetting(
                context,
                title: 'Database Version',
                value: '2.1.3',
              ),
              _buildInfoSetting(
                context,
                title: 'Last Sync',
                value: 'Today, 12:45 PM',
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings saved successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildDropdownSetting(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderSetting(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(title: Text(title), subtitle: Text(subtitle)),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 9,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInfoSetting(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
