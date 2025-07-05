import 'package:flutter/material.dart';
import '../services/audio_manager.dart';
import '../services/game_manager.dart';
import '../services/save_system.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Audio'),
          _buildAudioSettings(),
          SizedBox(height: 24),
          
          _buildSectionHeader('Game'),
          _buildGameSettings(),
          SizedBox(height: 24),
          
          _buildSectionHeader('Data'),
          _buildDataSettings(),
          SizedBox(height: 24),
          
          _buildSectionHeader('About'),
          _buildAboutSettings(),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.purple.shade700,
        ),
      ),
    );
  }
  
  Widget _buildAudioSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text('Sound Effects'),
            subtitle: Text('Button clicks and notifications'),
            value: AudioManager.instance.soundEnabled,
            onChanged: (value) {
              setState(() {
                AudioManager.instance.setSoundEnabled(value);
              });
            },
            activeColor: Colors.purple,
          ),
          Divider(height: 1),
          SwitchListTile(
            title: Text('Background Music'),
            subtitle: Text('Ambient music while playing'),
            value: AudioManager.instance.musicEnabled,
            onChanged: (value) {
              setState(() {
                AudioManager.instance.setMusicEnabled(value);
              });
            },
            activeColor: Colors.purple,
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.purple),
            title: Text('Notifications'),
            subtitle: Text('Content completion alerts'),
            trailing: Switch(
              value: true, // TODO: Implement notification settings
              onChanged: (value) {
                // TODO: Handle notification toggle
              },
              activeColor: Colors.purple,
            ),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.speed, color: Colors.purple),
            title: Text('Animation Speed'),
            subtitle: Text('UI animation speed'),
            trailing: DropdownButton<String>(
              value: 'Normal',
              items: ['Slow', 'Normal', 'Fast'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                // TODO: Implement animation speed setting
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.save, color: Colors.green),
            title: Text('Export Save Data'),
            subtitle: Text('Backup your progress'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showExportDialog();
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.upload, color: Colors.blue),
            title: Text('Import Save Data'),
            subtitle: Text('Restore from backup'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showImportDialog();
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text('Reset Game'),
            subtitle: Text('Delete all progress'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showResetDialog();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.info, color: Colors.purple),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.star, color: Colors.orange),
            title: Text('Rate the Game'),
            subtitle: Text('Help us improve'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showRateDialog();
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.privacy_tip, color: Colors.blue),
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showPrivacyDialog();
            },
          ),
        ],
      ),
    );
  }
  
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Save Data'),
        content: Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import Save Data'),
        content: Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Game'),
        content: Text('Are you sure you want to delete all your progress? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement game reset
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Game reset functionality coming soon!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }
  
  void _showRateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate Influencer Academy'),
        content: Text('Enjoying the game? Please rate us on the app store!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open app store rating
            },
            child: Text('Rate Now'),
          ),
        ],
      ),
    );
  }
  
  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'Influencer Academy Privacy Policy\n\n'
            'We respect your privacy and are committed to protecting your personal data.\n\n'
            'Data Collection:\n'
            '• Game progress is stored locally on your device\n'
            '• No personal information is collected\n'
            '• Anonymous usage analytics may be collected\n\n'
            'Ads:\n'
            '• We use Google AdMob for advertisements\n'
            '• Ad providers may collect anonymous data\n\n'
            'Contact:\n'
            'For questions about this policy, contact us at privacy@influenceracademy.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}