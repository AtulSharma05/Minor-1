import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// Service class to handle metronome functionality
/// Provides precise timing for workout beats with BPM control
class MetronomeService extends ChangeNotifier {
  Timer? _timer;
  bool _isRunning = false;
  int _bpm = 120; // Default beats per minute
  int _beatCount = 0;
  DateTime? _lastBeatTime;
  
  // Audio player for metronome sounds
  late AudioPlayer _audioPlayer;
  bool _audioEnabled = true;
  bool _hapticEnabled = true;

  // Preset BPM values for different workout types
  static const Map<String, int> presetBPMs = {
    'Slow Stretch': 60,
    'Yoga Flow': 80,
    'Strength Training': 100,
    'Cardio': 120,
    'HIIT': 140,
    'Sprint Interval': 160,
  };

  // Getters
  bool get isRunning => _isRunning;
  int get bpm => _bpm;
  int get beatCount => _beatCount;
  DateTime? get lastBeatTime => _lastBeatTime;
  bool get audioEnabled => _audioEnabled;
  bool get hapticEnabled => _hapticEnabled;

  // Constructor
  MetronomeService() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  /// Start the metronome with current BPM
  void start() {
    if (_isRunning) return;
    
    _isRunning = true;
    _beatCount = 0;
    _startTimer();
    notifyListeners();
  }

  /// Stop the metronome
  void stop() {
    if (!_isRunning) return;
    
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  /// Toggle metronome on/off
  void toggle() {
    if (_isRunning) {
      stop();
    } else {
      start();
    }
  }

  /// Set BPM (beats per minute)
  /// Valid range: 40-200 BPM
  void setBpm(int newBpm) {
    if (newBpm < 40 || newBpm > 200) return;
    
    _bpm = newBpm;
    
    // Restart timer with new interval if running
    if (_isRunning) {
      _timer?.cancel();
      _startTimer();
    }
    
    notifyListeners();
  }

  /// Set BPM from preset
  void setPresetBpm(String presetName) {
    if (presetBPMs.containsKey(presetName)) {
      setBpm(presetBPMs[presetName]!);
    }
  }

  /// Enable or disable audio feedback
  void setAudioEnabled(bool enabled) {
    _audioEnabled = enabled;
    notifyListeners();
  }

  /// Enable or disable haptic feedback
  void setHapticEnabled(bool enabled) {
    _hapticEnabled = enabled;
    notifyListeners();
  }

  /// Reset beat count
  void resetBeatCount() {
    _beatCount = 0;
    notifyListeners();
  }

  /// Start the internal timer
  void _startTimer() {
    // Calculate interval in milliseconds
    // 60,000 ms per minute / BPM = ms per beat
    final intervalMs = (60000 / _bpm).round();
    
    _timer = Timer.periodic(
      Duration(milliseconds: intervalMs),
      (timer) => _onBeat(),
    );
  }

  /// Handle each beat
  void _onBeat() {
    _beatCount++;
    _lastBeatTime = DateTime.now();
    
    // Debug print to show metronome is working
    if (kDebugMode) {
      print('🎵 Metronome Beat: $_beatCount (${getBeatPosition()}) - ${_bpm} BPM');
    }
    
    // Haptic feedback for beat
    if (_hapticEnabled) {
      _triggerHapticFeedback();
    }
    
    // Audio feedback for beat
    if (_audioEnabled) {
      _playBeatSound();
    }
    
    notifyListeners();
  }

  /// Trigger haptic feedback for beat
  void _triggerHapticFeedback() {
    try {
      // Use different feedback for accent beats (every 4th beat)
      if (_beatCount % 4 == 1) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Haptic feedback not supported on platform
      debugPrint('Haptic feedback not available: $e');
    }
  }

  /// Play audio beat sound
  Future<void> _playBeatSound() async {
    try {
      // Use different sounds for accent beats (every 4th beat)
      if (_beatCount % 4 == 1) {
        // Accent beat - double system sound for emphasis
        await _playAccentBeat();
      } else {
        // Regular beat - single system sound
        await _playRegularBeat();
      }
    } catch (e) {
      // Audio not available, fall back to system sound
      debugPrint('Audio playback failed: $e, using system sound');
      _triggerSystemSound();
    }
  }

  /// Play accent beat (1st beat of measure)
  Future<void> _playAccentBeat() async {
    try {
      SystemSound.play(SystemSoundType.click);
      // Small delay to create double-click effect
      await Future.delayed(const Duration(milliseconds: 40));
      SystemSound.play(SystemSoundType.click);
    } catch (e) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Play regular beat (2nd, 3rd, 4th beats)
  Future<void> _playRegularBeat() async {
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (e) {
      debugPrint('Regular beat sound failed: $e');
    }
  }

  /// Trigger system sound for beat
  void _triggerSystemSound() {
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // System sound not supported on platform
      debugPrint('System sound not available: $e');
    }
  }

  /// Get current tempo description
  String getTempoDescription() {
    if (_bpm <= 60) return 'Very Slow';
    if (_bpm <= 80) return 'Slow';
    if (_bpm <= 100) return 'Moderate';
    if (_bpm <= 120) return 'Medium';
    if (_bpm <= 140) return 'Fast';
    if (_bpm <= 160) return 'Very Fast';
    return 'Extremely Fast';
  }

  /// Calculate time signature display (4/4 time)
  String getBeatPosition() {
    final position = ((_beatCount - 1) % 4) + 1;
    return '$position/4';
  }

  @override
  void dispose() {
    stop();
    _audioPlayer.dispose();
    super.dispose();
  }
}
