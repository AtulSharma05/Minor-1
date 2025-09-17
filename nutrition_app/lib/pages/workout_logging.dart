import '../core/app_export.dart';
// import '../core/services/metronome_service.dart';
// import '../widgets/metronome_widget.dart';
// import 'package:provider/provider.dart';

class WorkoutLoggingPage extends StatefulWidget {
  const WorkoutLoggingPage({Key? key}) : super(key: key);

  @override
  _WorkoutLoggingPageState createState() => _WorkoutLoggingPageState();
}

class _WorkoutLoggingPageState extends State<WorkoutLoggingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedCategory = 'Strength Training';
  final List<String> _categories = [
    'Strength Training',
    'Cardio',
    'Flexibility',
    'Sports',
    'General',
  ];

  List<Exercise> _exercises = [];
  bool _isLoading = false;
  int _currentTokens = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentTokens();
  }

  Future<void> _loadCurrentTokens() async {
    try {
      final tokens = await DataService.getUserTokens();
      setState(() {
        _currentTokens = tokens;
      });
    } catch (e) {
      print('Error loading tokens: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addExercise() {
    setState(() {
      _exercises.add(Exercise(
        name: '',
        sets: 1,
        reps: 1,
        weight: 0,
        duration: 0,
      ));
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate() || _exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and add at least one exercise'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate total duration and calories from exercises
      int totalDuration = 0;
      int totalCalories = 0;
      
      for (final exercise in _exercises) {
        // Simple calorie calculation - can be improved with proper formulas
        if (exercise.duration > 0) {
          totalDuration += exercise.duration;
          totalCalories += (exercise.duration * 0.1).round(); // Very basic calculation
        } else {
          totalDuration += exercise.sets * exercise.reps * 30; // Assume 30 seconds per rep
          totalCalories += (exercise.sets * exercise.reps * 0.5).round(); // Basic calculation
        }
      }

      // Convert exercises to Map format
      final exercisesList = _exercises.map((e) => {
        'name': e.name,
        'sets': e.sets,
        'reps': e.reps,
        'weight': e.weight,
        'duration': e.duration,
        'notes': e.notes,
      }).toList();

      // Log workout using DataService
      final result = await DataService.logWorkout(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        duration: (totalDuration / 60).round(), // Convert to minutes
        calories: totalCalories,
        category: _selectedCategory,
        exercises: exercisesList,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (result['success'] == true) {
        final tokenRewards = result['token_rewards'];
        final totalTokens = tokenRewards['total_tokens_awarded'] ?? 0;
        final rewards = tokenRewards['rewards'] as List<dynamic>? ?? [];
        
        String message = 'Workout logged successfully! Earned $totalTokens tokens!';
        if (rewards.isNotEmpty) {
          final bonusMessages = rewards.skip(1).map((r) => r['message']).join(', ');
          if (bonusMessages.isNotEmpty) {
            message += '\nBonuses: $bonusMessages';
          }
        }
        
        // Refresh token display
        _loadCurrentTokens();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        throw Exception(result['error'] ?? 'Failed to save workout');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log workout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Token display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_currentTokens',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Rewards navigation
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.pushNamed(context, '/rewards').then((_) {
                // Refresh tokens when returning from rewards page
                _loadCurrentTokens();
              });
            },
            tooltip: 'View Rewards',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress and motivation card
                      Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Keep it up! Every workout counts!',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.monetization_on,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$_currentTokens',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber[800],
                                        ),
                                      ),
                                      Text(
                                        'Tokens',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 40,
                                    width: 1,
                                    color: Colors.grey[400],
                                  ),
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.add_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '+10',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                      Text(
                                        'Per workout',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // AI Pose Detection Card
                      Card(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI Pose Detection',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Use your camera for real-time form correction and automatic rep counting',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/pose_detection');
                                  },
                                  icon: const Icon(Icons.smart_toy),
                                  label: const Text('Start AI Training'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Workout Metronome Card - Temporarily commented out due to camera crash
                      /*
                      Card(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.music_note,
                                    color: Theme.of(context).colorScheme.tertiary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Workout Metronome',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Keep perfect tempo with visual and haptic beats for your workouts',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              
                              // Compact Metronome Widget with Settings - TEMPORARILY DISABLED
                              /*
                              Row(
                                children: [
                                  Expanded(
                                    child: ChangeNotifierProvider(
                                      create: (context) => MetronomeService(),
                                      child: const MetronomeWidget(compact: true),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/metronome_settings');
                                    },
                                    icon: const Icon(Icons.settings),
                                    tooltip: 'Metronome Settings',
                                    style: IconButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                                      foregroundColor: Theme.of(context).colorScheme.tertiary,
                                    ),
                                  ),
                                ],
                              ),
                              */
                            ],
                          ),
                        ),
                      ),
                      */
                      const SizedBox(height: 16),
                      // Basic workout info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Workout Details',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Workout Name *',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Please enter a workout name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(),
                                ),
                                items: _categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Exercises section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Exercises',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _addExercise,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Exercise'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_exercises.isEmpty)
                                const Center(
                                  child: Text('No exercises added yet. Add your first exercise!'),
                                )
                              else
                                ..._exercises.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final exercise = entry.value;
                                  return _buildExerciseCard(index, exercise);
                                }).toList(),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Notes section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notes',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _notesController,
                                decoration: const InputDecoration(
                                  labelText: 'Additional notes (optional)',
                                  border: OutlineInputBorder(),
                                  hintText: 'How did you feel? Any observations?',
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Save button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Log Workout',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      // METRONOME FAB - TEMPORARILY DISABLED
      /*
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFullMetronome(context),
        icon: const Icon(Icons.music_note),
        label: const Text('Metronome'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Colors.white,
      ),
      */
    );
  }

  // METRONOME FUNCTIONALITY - TEMPORARILY DISABLED TO FIX CAMERA CRASH
  /*
  void _showFullMetronome(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 4,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            // Full Metronome Widget
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ChangeNotifierProvider(
                  create: (context) => MetronomeService(),
                  child: const MetronomeWidget(compact: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  */

  Widget _buildExerciseCard(int index, Exercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercise ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _removeExercise(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: exercise.name,
              decoration: const InputDecoration(
                labelText: 'Exercise Name *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                exercise.name = value;
              },
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Please enter exercise name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.sets.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      exercise.sets = int.tryParse(value) ?? 1;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.reps.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      exercise.reps = int.tryParse(value) ?? 1;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.weight.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      exercise.weight = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.duration.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Duration (sec)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      exercise.duration = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Exercise {
  String name;
  int sets;
  int reps;
  double weight;
  int duration;
  String? notes;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.duration,
    this.notes,
  });
}
