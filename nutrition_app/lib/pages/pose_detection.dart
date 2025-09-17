import '../core/app_export.dart';
import 'package:camera/camera.dart';

class PoseDetectionPage extends StatefulWidget {
  const PoseDetectionPage({Key? key}) : super(key: key);

  @override
  _PoseDetectionPageState createState() => _PoseDetectionPageState();
}

class _PoseDetectionPageState extends State<PoseDetectionPage>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isDetectionActive = false;
  bool _isLoading = false;
  
  // Pose Detection Placeholders
  String _selectedExercise = 'Push-ups';
  int _repCount = 0;
  int _targetReps = 10;
  double _poseAccuracy = 0.0;
  List<String> _detectionFeedback = [];
  
  // Available exercises for pose detection
  final List<String> _exercises = [
    'Push-ups',
    'Squats', 
    'Lunges',
    'Jumping Jacks',
    'Burpees',
    'Plank Hold',
  ];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _simulationTimer; // Store timer reference

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: ML POSE DETECTION INTEGRATION POINT
      // Replace this placeholder with actual camera initialization
      // Required: camera permission handling, ML model loading
      
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        
        await _cameraController!.initialize();
        
        // TODO: Initialize ML pose detection model here
        // Example: await _initializePoseDetectionModel();
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Show error dialog or fallback UI
        _showCameraErrorDialog();
      }
    }
  }

  void _showCameraErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Error'),
        content: const Text('Unable to initialize camera. Please check permissions and try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startPoseDetection() {
    setState(() {
      _isDetectionActive = true;
      _repCount = 0;
      _poseAccuracy = 0.0;
      _detectionFeedback.clear();
    });

    // TODO: ML POSE DETECTION INTEGRATION POINT
    // Start real-time pose detection processing
    // Example: _startPoseDetectionStream();
    
    // Placeholder: Simulate pose detection feedback
    _simulatePoseDetection();
  }

  void _stopPoseDetection() {
    setState(() {
      _isDetectionActive = false;
    });

    // TODO: ML POSE DETECTION INTEGRATION POINT
    // Stop pose detection processing and cleanup resources
    // Example: _stopPoseDetectionStream();
  }

  // Placeholder method to simulate pose detection behavior
  void _simulatePoseDetection() {
    if (!_isDetectionActive) return;
    
    // Cancel existing timer if any
    _simulationTimer?.cancel();
    
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isDetectionActive || !mounted) {
        timer.cancel();
        _simulationTimer = null;
        return;
      }
      
      // Simulate pose detection feedback
      setState(() {
        if (_repCount < _targetReps) {
          _repCount++;
          _poseAccuracy = (70 + (30 * (_repCount / _targetReps))); // Simulate improving accuracy
          
          List<String> feedbackMessages = [
            'Good form! Keep your back straight.',
            'Excellent depth on that rep!',
            'Try to control the movement.',
            'Perfect! Maintain this pace.',
            'Focus on your breathing.',
          ];
          
          _detectionFeedback.add(feedbackMessages[_repCount % feedbackMessages.length]);
          if (_detectionFeedback.length > 3) {
            _detectionFeedback.removeAt(0);
          }
        } else {
          timer.cancel();
          _simulationTimer = null;
          _onWorkoutComplete();
        }
      });
    });
  }

  void _onWorkoutComplete() {
    if (!mounted) return;
    setState(() {
      _isDetectionActive = false;
    });

    // Show completion dialog and award tokens
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workout Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text('Completed $_repCount $_selectedExercise'),
            Text('Average Accuracy: ${_poseAccuracy.toStringAsFixed(1)}%'),
            const SizedBox(height: 12),
            const Text('Earned 15 tokens!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetWorkout();
            },
            child: const Text('New Set'),
          ),
        ],
      ),
    );
  }

  void _resetWorkout() {
    setState(() {
      _repCount = 0;
      _poseAccuracy = 0.0;
      _detectionFeedback.clear();
      _isDetectionActive = false;
    });
  }

  @override
  void dispose() {
    // Cancel timer to prevent setState after dispose
    _simulationTimer?.cancel();
    _cameraController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Pose Detection'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Exercise Selection
                _buildExerciseSelector(),
                
                // Camera Preview with Overlay
                Expanded(
                  flex: 3,
                  child: _buildCameraPreview(),
                ),
                
                // Detection Info Panel
                _buildDetectionInfoPanel(),
                
                // Control Buttons
                _buildControlButtons(),
              ],
            ),
    );
  }

  Widget _buildExerciseSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          const Icon(Icons.fitness_center),
          const SizedBox(width: 12),
          const Text('Exercise:'),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedExercise,
              isExpanded: true,
              items: _exercises.map((exercise) {
                return DropdownMenuItem<String>(
                  value: exercise,
                  child: Text(exercise),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && !_isDetectionActive) {
                  setState(() {
                    _selectedExercise = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDetectionActive 
              ? Colors.green 
              : Theme.of(context).colorScheme.outline,
          width: 3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: _isCameraInitialized && _cameraController != null
            ? Stack(
                children: [
                  CameraPreview(_cameraController!),
                  _buildPoseOverlay(),
                ],
              )
            : _buildCameraPlaceholder(),
      ),
    );
  }

  Widget _buildPoseOverlay() {
    if (!_isDetectionActive) return const SizedBox.shrink();

    return Stack(
      children: [
        // TODO: ML POSE DETECTION INTEGRATION POINT
        // Replace this with actual pose landmark visualization
        // Example: CustomPaint(painter: PosePainter(poses: detectedPoses))
        
        // Placeholder: Simulated pose indicators
        Positioned(
          top: 50,
          left: 50,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
        
        // Rep Counter Overlay
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  '$_repCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/ $_targetReps',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Accuracy Indicator
        if (_poseAccuracy > 0)
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Accuracy: ${_poseAccuracy.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _poseAccuracy > 80 ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Camera Preview',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ML Pose Detection will appear here',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionInfoPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isDetectionActive ? Icons.visibility : Icons.visibility_off,
                color: _isDetectionActive ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                _isDetectionActive ? 'Detection Active' : 'Detection Inactive',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isDetectionActive ? Colors.green : Colors.grey,
                ),
              ),
              const Spacer(),
              if (_isDetectionActive)
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Feedback Messages
          if (_detectionFeedback.isNotEmpty) ...[
            const Text(
              'Form Feedback:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...(_detectionFeedback.reversed.take(2).map((feedback) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• $feedback',
                  style: const TextStyle(fontSize: 14),
                ),
              )
            )),
          ] else
            const Text(
              'Start detection to receive real-time form feedback',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isCameraInitialized 
                  ? (_isDetectionActive ? _stopPoseDetection : _startPoseDetection)
                  : null,
              icon: Icon(
                _isDetectionActive ? Icons.stop : Icons.play_arrow,
              ),
              label: Text(
                _isDetectionActive ? 'Stop Detection' : 'Start Detection',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDetectionActive 
                    ? Colors.red 
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _isDetectionActive ? null : _resetWorkout,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detection Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Target Reps'),
              trailing: DropdownButton<int>(
                value: _targetReps,
                items: [5, 10, 15, 20, 25].map((reps) {
                  return DropdownMenuItem<int>(
                    value: reps,
                    child: Text('$reps'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _targetReps = value;
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            const Divider(),
            const ListTile(
              title: Text('ML Model Settings'),
              subtitle: Text('Confidence threshold, detection sensitivity'),
              trailing: Icon(Icons.settings),
            ),
            const ListTile(
              title: Text('Camera Settings'),
              subtitle: Text('Resolution, frame rate, exposure'),
              trailing: Icon(Icons.camera_alt),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
