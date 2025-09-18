/**
 * Frontend-Compatible Authentication Routes
 * 
 * Routes designed to match the existing Flutter app's expected API structure
 * Compatible with AuthDataSource endpoints and response format
 */

const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { catchAsync, APIError } = require('../middleware/errorHandler');

const router = express.Router();

/**
 * @route   POST /api/v1/auth_user/signup_user
 * @desc    Register a new user (Frontend compatible)
 * @access  Public
 * @body    { username, email_id, password, token? }
 */
router.post('/signup_user', catchAsync(async (req, res) => {
  const { username, email_id, password, token } = req.body;

  // Check if user already exists (using email_id to match frontend)
  const existingUser = await User.findOne({
    $or: [{ email: email_id }, { username }]
  });

  if (existingUser) {
    return res.status(400).json({
      message: 'User with this email or username already exists'
    });
  }

  // Validate required fields
  if (!username || !email_id || !password) {
    return res.status(400).json({
      message: 'Username, email_id, and password are required'
    });
  }

  // Create new user (map email_id to email for backend)
  const user = new User({
    username,
    email: email_id, // Map email_id from frontend to email in backend
    password,
    fullName: username // Use username as fullName for simplicity
  });

  await user.save();

  // Generate token for immediate login
  const accessToken = user.generateAccessToken();

  // Return success response (status 200 as expected by frontend)
  res.status(200).json({
    message: 'User created successfully',
    user: {
      username: user.username,
      email_id: user.email, // Map back to email_id for frontend
      token: accessToken
    }
  });
}));

/**
 * @route   POST /api/v1/auth_user/client_login
 * @desc    Authenticate user (Frontend compatible)
 * @access  Public
 * @body    { username?, email_id?, password, token? }
 */
router.post('/client_login', catchAsync(async (req, res) => {
  const { username, email_id, password, token } = req.body;

  // Check if password is provided
  if (!password) {
    return res.status(400).json({
      message: 'Password is required'
    });
  }

  // Find user by username or email_id (flexible login)
  let user;
  if (email_id) {
    user = await User.findOne({ email: email_id }).select('+password');
  } else if (username) {
    user = await User.findOne({ username }).select('+password');
  } else {
    return res.status(400).json({
      message: 'Username or email_id is required'
    });
  }

  // Verify user exists and password is correct
  if (!user || !(await user.comparePassword(password))) {
    return res.status(401).json({
      message: 'Invalid credentials'
    });
  }

  // Check if user is active
  if (!user.isActive) {
    return res.status(401).json({
      message: 'Your account has been deactivated. Please contact support.'
    });
  }

  // Generate tokens
  const accessToken = user.generateAccessToken();
  const refreshToken = user.generateRefreshToken();

  // Store refresh token
  user.refreshTokens.push({
    token: refreshToken,
    createdAt: new Date()
  });

  // Update last login
  user.lastLogin = new Date();
  await user.save();

  // Return success response (status 200 as expected by frontend)
  res.status(200).json({
    message: 'Login successful',
    user: {
      username: user.username,
      email_id: user.email, // Map back to email_id for frontend
      token: accessToken
    },
    refreshToken // Additional token for advanced features
  });
}));

/**
 * @route   POST /api/v1/auth_user/client_logout
 * @desc    Logout user (Frontend compatible)
 * @access  Public
 * @body    { username?, token? }
 */
router.post('/client_logout', catchAsync(async (req, res) => {
  const { username, token } = req.body;

  // If token is provided, try to invalidate it
  if (token) {
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id);
      
      if (user) {
        // Remove refresh tokens (if any)
        user.refreshTokens = [];
        await user.save();
      }
    } catch (error) {
      // Token might be invalid, but that's okay for logout
      console.log('Token verification failed during logout:', error.message);
    }
  }

  // Return success response (status 200 as expected by frontend)
  res.status(200).json({
    message: 'Logout successful'
  });
}));

module.exports = router;