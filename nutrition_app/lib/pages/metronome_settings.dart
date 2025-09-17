import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/metronome_service.dart';
import '../widgets/metronome_widget.dart';

/// Settings page for customizing metronome preferences
class MetronomeSettingsPage extends StatefulWidget {
  const MetronomeSettingsPage({Key? key}) : super(key: key);

  @override
  State<MetronomeSettingsPage> createState() => _MetronomeSettingsPageState();
}

class _MetronomeSettingsPageState extends State<MetronomeSettingsPage> {
  late SharedPreferences _prefs;
  bool _hapticFeedbackEnabled = true;
  bool _audioFeedbackEnabled = true;
  int _defaultBpm = 120;
  String _defaultPreset = 'Cardio';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _hapticFeedbackEnabled = _prefs.getBool('metronome_haptic') ?? true;
      _audioFeedbackEnabled = _prefs.getBool('metronome_audio') ?? true;
      _defaultBpm = _prefs.getInt('metronome_default_bpm') ?? 120;
      _defaultPreset = _prefs.getString('metronome_default_preset') ?? 'Cardio';
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metronome Settings'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Metronome Preferences',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize your workout metronome experience',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Feedback Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback Options',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Haptic Feedback Toggle
                  SwitchListTile(
                    title: const Text('Haptic Feedback'),
                    subtitle: const Text('Feel the beat through vibrations'),
                    value: _hapticFeedbackEnabled,
                    onChanged: (value) {
                      setState(() {
                        _hapticFeedbackEnabled = value;
                      });
                      _saveSetting('metronome_haptic', value);
                    },
                    secondary: const Icon(Icons.vibration),
                  ),
                  
                  // Audio Feedback Toggle
                  SwitchListTile(
                    title: const Text('Audio Feedback'),
                    subtitle: const Text('Hear the beat through system sounds'),
                    value: _audioFeedbackEnabled,
                    onChanged: (value) {
                      setState(() {
                        _audioFeedbackEnabled = value;
                      });
                      _saveSetting('metronome_audio', value);
                    },
                    secondary: const Icon(Icons.volume_up),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Default Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Default Settings',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Default BPM
                  Text(
                    'Default BPM: $_defaultBpm',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _defaultBpm.toDouble(),
                    min: 40,
                    max: 200,
                    divisions: 32,
                    label: _defaultBpm.toString(),
                    onChanged: (value) {
                      setState(() {
                        _defaultBpm = value.round();
                      });
                    },
                    onChangeEnd: (value) {
                      _saveSetting('metronome_default_bpm', value.round());
                    },
                  ),
                  const SizedBox(height: 16),

                  // Default Preset
                  Text(
                    'Default Preset',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _defaultPreset,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: MetronomeService.presetBPMs.keys.map((preset) {
                      return DropdownMenuItem(
                        value: preset,
                        child: Text('$preset (${MetronomeService.presetBPMs[preset]} BPM)'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _defaultPreset = value;
                          _defaultBpm = MetronomeService.presetBPMs[value] ?? 120;
                        });
                        _saveSetting('metronome_default_preset', value);
                        _saveSetting('metronome_default_bpm', MetronomeService.presetBPMs[value] ?? 120);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Usage Tips
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Usage Tips',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('• Use slower BPM (60-80) for stretching and yoga'),
                  const SizedBox(height: 4),
                  const Text('• Medium BPM (100-120) works well for strength training'),
                  const SizedBox(height: 4),
                  const Text('• Higher BPM (140-160) is perfect for cardio and HIIT'),
                  const SizedBox(height: 4),
                  const Text('• Every 4th beat has stronger haptic feedback for rhythm'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Test Metronome Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showTestMetronome(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Test Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTestMetronome(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Metronome'),
        content: SizedBox(
          height: 300,
          width: double.maxFinite,
          child: ChangeNotifierProvider(
            create: (context) => MetronomeService()..setBpm(_defaultBpm),
            child: const MetronomeWidget(compact: false),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
