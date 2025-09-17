import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/metronome_service.dart';

/// Interactive metronome widget with visual beat indicator and controls
class MetronomeWidget extends StatefulWidget {
  final bool compact;
  final Color? accentColor;

  const MetronomeWidget({
    Key? key,
    this.compact = false,
    this.accentColor,
  }) : super(key: key);

  @override
  State<MetronomeWidget> createState() => _MetronomeWidgetState();
}

class _MetronomeWidgetState extends State<MetronomeWidget>
    with TickerProviderStateMixin {
  late AnimationController _beatAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _beatAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Beat animation for visual feedback
    _beatAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _beatAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _beatAnimationController, curve: Curves.elasticOut),
    );

    // Pulse animation for running indicator
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _beatAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MetronomeService>(
      builder: (context, metronome, child) {
        // Trigger beat animation when beat count changes
        if (metronome.isRunning) {
          // Trigger animation on beat change
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _beatAnimationController.forward().then((_) {
                if (mounted) {
                  _beatAnimationController.reverse();
                }
              });
            }
          });
          
          if (!_pulseAnimationController.isAnimating) {
            _pulseAnimationController.repeat(reverse: true);
          }
        } else {
          _pulseAnimationController.stop();
          _pulseAnimationController.reset();
        }

        return widget.compact ? _buildCompactWidget(metronome) : _buildFullWidget(metronome);
      },
    );
  }

  Widget _buildFullWidget(MetronomeService metronome) {
    final theme = Theme.of(context);
    final accentColor = widget.accentColor ?? theme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Workout Metronome',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 20),

          // Visual Beat Indicator
          _buildBeatIndicator(metronome, accentColor),
          const SizedBox(height: 20),

          // BPM Display and Controls
          _buildBpmControls(metronome, accentColor),
          const SizedBox(height: 20),

          // Preset Buttons
          _buildPresetButtons(metronome),
          const SizedBox(height: 20),

          // Audio and Haptic Controls
          _buildFeedbackControls(metronome, accentColor),
          const SizedBox(height: 20),

          // Main Control Button
          _buildControlButton(metronome, accentColor),
          const SizedBox(height: 10),

          // Beat Counter
          _buildBeatCounter(metronome),
        ],
      ),
    );
  }

  Widget _buildCompactWidget(MetronomeService metronome) {
    final theme = Theme.of(context);
    final accentColor = widget.accentColor ?? theme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact Beat Indicator
          AnimatedBuilder(
            animation: _beatAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _beatAnimation.value,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: metronome.isRunning ? accentColor : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),

          // BPM Display
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${metronome.bpm} BPM',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                metronome.getTempoDescription(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              if (metronome.isRunning)
                Text(
                  'Beat: ${metronome.beatCount}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Compact Control Button
          IconButton(
            onPressed: metronome.toggle,
            icon: Icon(
              metronome.isRunning ? Icons.pause : Icons.play_arrow,
            ),
            color: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBeatIndicator(MetronomeService metronome, Color accentColor) {
    return AnimatedBuilder(
      animation: _beatAnimation,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _beatAnimation.value * _pulseAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: metronome.isRunning ? accentColor : Colors.grey,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metronome.getBeatPosition(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBpmControls(MetronomeService metronome, Color accentColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => metronome.setBpm(metronome.bpm - 5),
              icon: const Icon(Icons.remove),
              color: accentColor,
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                Text(
                  '${metronome.bpm}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const Text('BPM'),
                Text(
                  metronome.getTempoDescription(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: () => metronome.setBpm(metronome.bpm + 5),
              icon: const Icon(Icons.add),
              color: accentColor,
            ),
          ],
        ),
        const SizedBox(height: 10),
        
        // BPM Slider
        Slider(
          value: metronome.bpm.toDouble(),
          min: 40,
          max: 200,
          divisions: 32,
          activeColor: accentColor,
          onChanged: (value) => metronome.setBpm(value.round()),
        ),
      ],
    );
  }

  Widget _buildPresetButtons(MetronomeService metronome) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MetronomeService.presetBPMs.entries.map((entry) {
        final isSelected = metronome.bpm == entry.value;
        return ChoiceChip(
          label: Text(entry.key),
          selected: isSelected,
          onSelected: (_) => metronome.setPresetBpm(entry.key),
          selectedColor: widget.accentColor?.withOpacity(0.2),
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackControls(MetronomeService metronome, Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Audio Toggle
        Column(
          children: [
            IconButton(
              onPressed: () => metronome.setAudioEnabled(!metronome.audioEnabled),
              icon: Icon(
                metronome.audioEnabled ? Icons.volume_up : Icons.volume_off,
                color: metronome.audioEnabled ? accentColor : Colors.grey,
              ),
            ),
            Text(
              'Audio',
              style: TextStyle(
                fontSize: 12,
                color: metronome.audioEnabled ? accentColor : Colors.grey,
              ),
            ),
          ],
        ),
        
        // Haptic Toggle  
        Column(
          children: [
            IconButton(
              onPressed: () => metronome.setHapticEnabled(!metronome.hapticEnabled),
              icon: Icon(
                metronome.hapticEnabled ? Icons.vibration : Icons.phonelink_erase,
                color: metronome.hapticEnabled ? accentColor : Colors.grey,
              ),
            ),
            Text(
              'Haptic',
              style: TextStyle(
                fontSize: 12,
                color: metronome.hapticEnabled ? accentColor : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton(MetronomeService metronome, Color accentColor) {
    return ElevatedButton.icon(
      onPressed: metronome.toggle,
      icon: Icon(
        metronome.isRunning ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
      ),
      label: Text(
        metronome.isRunning ? 'Pause' : 'Start',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  Widget _buildBeatCounter(MetronomeService metronome) {
    return Column(
      children: [
        Text(
          'Beat Count: ${metronome.beatCount}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        if (metronome.beatCount > 0)
          TextButton(
            onPressed: metronome.resetBeatCount,
            child: const Text('Reset'),
          ),
      ],
    );
  }
}
