/**
 * Main Server Entry Point for Workout Tracker Backend
 * 
 * This file initializes the Express server, sets up middleware,
 * connects to MongoDB, and defines API routes.
 * 
 * Base URL: http://localhost:3000/api/v1
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// Import configuration and utilities
const connectDB = require('./config/database');
const { globalErrorHandler, notFound } = require('./middleware/errorHandler');

// Import routes (will be created in next steps)
const authRoutes = require('./routes/auth');
const frontendAuthRoutes = require('./routes/frontendAuth'); // Frontend-compatible routes
const workoutRoutes = require('./routes/workout');
const workoutLoggingRoutes = require('./routes/workoutLogging'); // Frontend-compatible workout routes
// const userRoutes = require('./routes/users');
// const blogRoutes = require('./routes/blogs');

const app = express();
const PORT = process.env.PORT || 3000;
const API_VERSION = process.env.API_VERSION || 'v1';

// Connect to MongoDB
connectDB();

// Security middleware
app.use(helmet());

// CORS configuration for Flutter app
app.use(cors({
  origin: ['http://localhost:3000', 'http://10.0.2.2:3000'], // Flutter emulator
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging middleware
app.use(morgan('combined'));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'Workout Tracker API is running',
    timestamp: new Date().toISOString(),
    version: API_VERSION,
    environment: process.env.NODE_ENV
  });
});

// API Routes
const apiRouter = express.Router();

// Welcome endpoint
apiRouter.get('/', (req, res) => {
  res.json({
    message: 'Welcome to Workout Tracker API',
    version: API_VERSION,
    endpoints: {
      auth: `/api/${API_VERSION}/auth`,
      'auth_user (frontend)': `/api/${API_VERSION}/auth_user`, // Frontend-compatible routes
      workouts: `/api/${API_VERSION}/workouts`,
      'workout_logging (frontend)': `/api/${API_VERSION}/workout_logging`, // Frontend-compatible workout routes
      users: `/api/${API_VERSION}/users`,
      blogs: `/api/${API_VERSION}/blogs`
    },
    documentation: 'Coming soon...'
  });
});

// Mount API routes (will be uncommented as routes are created)
apiRouter.use('/auth', authRoutes);
apiRouter.use('/auth_user', frontendAuthRoutes); // Frontend-compatible auth routes
apiRouter.use('/workouts', workoutRoutes);
apiRouter.use('/workout_logging', workoutLoggingRoutes); // Frontend-compatible workout routes
// apiRouter.use('/users', userRoutes);
// apiRouter.use('/blogs', blogRoutes);

app.use(`/api/${API_VERSION}`, apiRouter);

// Error handling middleware
app.use(notFound);
app.use(globalErrorHandler);

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Workout Tracker Backend Server running on port ${PORT}`);
  console.log(`📍 Base URL: http://localhost:${PORT}/api/${API_VERSION}`);
  console.log(`🏥 Health Check: http://localhost:${PORT}/health`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;