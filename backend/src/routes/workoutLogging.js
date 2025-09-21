/**
 * Frontend-Compatible Workout Logging Routes
 * 
 * These routes match the existing Flutter app's expectations
 * while using our new Workout model for data storage
 */

const express = require('express');
const mongoose = require('mongoose');
const Workout = require('../models/Workout');
const User = require('../models/User');
const { catchAsync, APIError } = require('../middleware/errorHandler');
const { protect } = require('../middleware/auth');

const router = express.Router();

/**
 * @route   POST /api/v1/workout_logging/workout_search
 * @desc    Search for workout exercises (frontend-compatible)
 * @access  Public
 * @body    { workout_query: string, username: string }
 */
router.post('/workout_search', catchAsync(async (req, res) => {
  const { workout_query, username } = req.body;

  if (!workout_query) {
    throw new APIError('Workout query is required', 400);
  }

  // Predefined workout database for search
  const workoutDatabase = [
    {
      name: 'Running',
      category: 'Cardio',
      calories_per_hour: 400,
      description: 'Running at moderate pace',
      effort_levels: ['Low', 'Moderate', 'High', 'Extreme']
    },
    {
      name: 'Walking',
      category: 'Cardio',
      calories_per_hour: 200,
      description: 'Brisk walking',
      effort_levels: ['Low', 'Moderate']
    },
    {
      name: 'Cycling',
      category: 'Cardio',
      calories_per_hour: 300,
      description: 'Cycling at moderate pace',
      effort_levels: ['Low', 'Moderate', 'High']
    },
    {
      name: 'Swimming',
      category: 'Cardio',
      calories_per_hour: 350,
      description: 'Swimming laps',
      effort_levels: ['Moderate', 'High', 'Extreme']
    },
    {
      name: 'Weight Training',
      category: 'Strength Training',
      calories_per_hour: 250,
      description: 'General weight training',
      effort_levels: ['Moderate', 'High', 'Extreme']
    },
    {
      name: 'Push-ups',
      category: 'Strength Training',
      calories_per_hour: 200,
      description: 'Push-up exercises',
      effort_levels: ['Low', 'Moderate', 'High']
    },
    {
      name: 'Yoga',
      category: 'Flexibility',
      calories_per_hour: 150,
      description: 'Yoga practice',
      effort_levels: ['Low', 'Moderate']
    },
    {
      name: 'Stretching',
      category: 'Flexibility',
      calories_per_hour: 100,
      description: 'Stretching exercises',
      effort_levels: ['Low']
    },
    {
      name: 'Basketball',
      category: 'Sports',
      calories_per_hour: 400,
      description: 'Playing basketball',
      effort_levels: ['Moderate', 'High', 'Extreme']
    },
    {
      name: 'Tennis',
      category: 'Sports',
      calories_per_hour: 350,
      description: 'Playing tennis',
      effort_levels: ['Moderate', 'High']
    },
    {
      name: 'Soccer',
      category: 'Sports',
      calories_per_hour: 450,
      description: 'Playing soccer',
      effort_levels: ['High', 'Extreme']
    },
    {
      name: 'Bench Press',
      category: 'Strength Training',
      calories_per_hour: 220,
      description: 'Bench press exercise',
      effort_levels: ['Moderate', 'High', 'Extreme']
    },
    {
      name: 'Squats',
      category: 'Strength Training',
      calories_per_hour: 240,
      description: 'Squat exercises',
      effort_levels: ['Moderate', 'High']
    },
    {
      name: 'Deadlifts',
      category: 'Strength Training',
      calories_per_hour: 280,
      description: 'Deadlift exercises',
      effort_levels: ['High', 'Extreme']
    },
    {
      name: 'Jumping Jacks',
      category: 'Cardio',
      calories_per_hour: 300,
      description: 'Jumping jack exercises',
      effort_levels: ['Low', 'Moderate', 'High']
    }
  ];

  // Search workouts based on query
  const searchResults = workoutDatabase.filter(workout =>
    workout.name.toLowerCase().includes(workout_query.toLowerCase()) ||
    workout.category.toLowerCase().includes(workout_query.toLowerCase()) ||
    workout.description.toLowerCase().includes(workout_query.toLowerCase())
  );

  res.status(200).json({
    result: 'STATUS_OK',
    workout_search_results: searchResults,
    message: `Found ${searchResults.length} workout(s) matching "${workout_query}"`
  });
}));

/**
 * @route   POST /api/v1/workout_logging/fetch_workout_info
 * @desc    Get detailed workout information (frontend-compatible)
 * @access  Public
 * @body    { selected_workout: string, effort_level?: string, duration_min?: string }
 */
router.post('/fetch_workout_info', catchAsync(async (req, res) => {
  const { selected_workout, effort_level, duration_min } = req.body;

  if (!selected_workout) {
    throw new APIError('Selected workout is required', 400);
  }

  // Find workout in database
  const workoutDatabase = [
    { name: 'Running', base_calories_per_hour: 400, category: 'Cardio' },
    { name: 'Walking', base_calories_per_hour: 200, category: 'Cardio' },
    { name: 'Cycling', base_calories_per_hour: 300, category: 'Cardio' },
    { name: 'Swimming', base_calories_per_hour: 350, category: 'Cardio' },
    { name: 'Weight Training', base_calories_per_hour: 250, category: 'Strength Training' },
    { name: 'Push-ups', base_calories_per_hour: 200, category: 'Strength Training' },
    { name: 'Yoga', base_calories_per_hour: 150, category: 'Flexibility' },
    { name: 'Stretching', base_calories_per_hour: 100, category: 'Flexibility' },
    { name: 'Basketball', base_calories_per_hour: 400, category: 'Sports' },
    { name: 'Tennis', base_calories_per_hour: 350, category: 'Sports' },
    { name: 'Soccer', base_calories_per_hour: 450, category: 'Sports' },
    { name: 'Bench Press', base_calories_per_hour: 220, category: 'Strength Training' },
    { name: 'Squats', base_calories_per_hour: 240, category: 'Strength Training' },
    { name: 'Deadlifts', base_calories_per_hour: 280, category: 'Strength Training' },
    { name: 'Jumping Jacks', base_calories_per_hour: 300, category: 'Cardio' }
  ];

  const workout = workoutDatabase.find(w => w.name.toLowerCase() === selected_workout.toLowerCase());

  if (!workout) {
    throw new APIError('Workout not found', 404);
  }

  // Calculate calories based on effort level
  const effortMultipliers = {
    'Low': 0.7,
    'Moderate': 1.0,
    'High': 1.3,
    'Extreme': 1.6
  };

  const multiplier = effortMultipliers[effort_level] || 1.0;
  const calories_per_hour = Math.round(workout.base_calories_per_hour * multiplier);
  
  // Calculate total calories if duration provided
  let total_calories = 0;
  if (duration_min) {
    const duration_hours = parseInt(duration_min) / 60;
    total_calories = Math.round(calories_per_hour * duration_hours);
  }

  const workoutInfo = {
    workout_name: workout.name,
    category: workout.category,
    calories_per_hour: calories_per_hour,
    total_calories: total_calories,
    duration_minutes: duration_min ? parseInt(duration_min) : 0,
    effort_level: effort_level || 'Moderate',
    recommendations: {
      beginner: `Start with ${Math.round(calories_per_hour * 0.5)} calories/hour`,
      intermediate: `Target ${calories_per_hour} calories/hour`,
      advanced: `Challenge yourself with ${Math.round(calories_per_hour * 1.2)} calories/hour`
    }
  };

  res.status(200).json({
    result: 'STATUS_OK',
    workout_info: workoutInfo,
    message: 'Workout information retrieved successfully'
  });
}));

/**
 * @route   POST /api/v1/workout_logging/log_workout_info
 * @desc    Log workout information (frontend-compatible, saves to database)
 * @access  Private (requires authentication)
 * @body    { 
 *   username: string,
 *   selected_workout: string,
 *   duration_min: string,
 *   energy_burned: string,
 *   current_date: string,
 *   time_of_day: string,
 *   workout_notes: string,
 *   effort_level: string,
 *   diary_group: string
 * }
 */
router.post('/log_workout_info', protect, catchAsync(async (req, res) => {
  const {
    username,
    selected_workout,
    duration_min,
    energy_burned,
    current_date,
    time_of_day,
    workout_notes,
    effort_level,
    diary_group
  } = req.body;

  if (!username || !selected_workout || !duration_min) {
    throw new APIError('Username, workout name, and duration are required', 400);
  }

  try {
    // Map frontend data to our Workout model
    const workoutTypeMap = {
      'Cardio': 'cardio',
      'Strength Training': 'strength',
      'Flexibility': 'flexibility',
      'Sports': 'sports',
      'General': 'other'
    };

    // Determine workout type based on exercise name
    let workoutType = 'other';
    const cardioExercises = ['running', 'walking', 'cycling', 'swimming', 'jumping jacks'];
    const strengthExercises = ['weight training', 'push-ups', 'bench press', 'squats', 'deadlifts'];
    const flexibilityExercises = ['yoga', 'stretching'];
    const sportsExercises = ['basketball', 'tennis', 'soccer'];

    const exerciseLower = selected_workout.toLowerCase();
    if (cardioExercises.some(ex => exerciseLower.includes(ex))) workoutType = 'cardio';
    else if (strengthExercises.some(ex => exerciseLower.includes(ex))) workoutType = 'strength';
    else if (flexibilityExercises.some(ex => exerciseLower.includes(ex))) workoutType = 'flexibility';
    else if (sportsExercises.some(ex => exerciseLower.includes(ex))) workoutType = 'sports';

    // Map effort level to intensity level
    const intensityMap = {
      'Low': 'low',
      'Moderate': 'moderate', 
      'High': 'high',
      'Extreme': 'extreme'
    };

    // Parse date
    let workoutDate = new Date();
    if (current_date) {
      // Try to parse the date from frontend format
      const parsedDate = new Date(current_date);
      if (!isNaN(parsedDate.getTime())) {
        workoutDate = parsedDate;
      }
    }

    // For now, we'll create a workout without user authentication
    // In production, you'd want to authenticate the user first
    const workoutData = {
      // Use the authenticated user's ID from the protect middleware
      userId: req.user._id,
      exerciseName: selected_workout,
      workoutType: workoutType,
      duration: parseInt(duration_min) || 0,
      caloriesBurned: parseInt(energy_burned) || 0,
      date: workoutDate,
      notes: workout_notes || '',
      intensityLevel: intensityMap[effort_level] || 'moderate'
    };

    // Create the workout with proper user association
    const workout = await Workout.create(workoutData);

    // Return success with actual workout data
    res.status(200).json({
      result: 'STATUS_OK',
      message: 'Workout logged successfully',
      data: {
        workout_id: workout._id,
        logged_at: workout.date.toISOString(),
        username: req.user.username,
        exercise: selected_workout,
        duration: duration_min,
        calories: energy_burned,
        date: current_date,
        workout: workout
      }
    });

  } catch (error) {
    console.error('Error logging workout:', error);
    throw new APIError('Failed to log workout', 500);
  }
}));

/**
 * @route   GET /api/v1/workout_logging/history
 * @desc    Get workout history for user (additional endpoint)
 * @access  Public
 * @query   ?username=string&limit=number&page=number
 */
router.get('/history', catchAsync(async (req, res) => {
  const { username, limit = 20, page = 1 } = req.query;

  if (!username) {
    throw new APIError('Username is required', 400);
  }

  // For now, return mock data since we need proper user authentication
  const mockHistory = [
    {
      id: '1',
      exercise_name: 'Running',
      duration: 30,
      calories: 300,
      date: new Date().toISOString(),
      effort_level: 'Moderate'
    },
    {
      id: '2', 
      exercise_name: 'Weight Training',
      duration: 45,
      calories: 250,
      date: new Date(Date.now() - 86400000).toISOString(), // Yesterday
      effort_level: 'High'
    }
  ];

  res.status(200).json({
    result: 'STATUS_OK',
    workout_history: mockHistory,
    pagination: {
      current_page: parseInt(page),
      total_pages: 1,
      total_count: mockHistory.length
    },
    message: 'Workout history retrieved successfully'
  });
}));

module.exports = router;