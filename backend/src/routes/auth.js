/**
 * Authentication Routes
 * 
 * Handles user registration, login, token refresh, and logout
 * Compatible with Flutter app's AuthNotifier and authentication flow
 */

const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { catchAsync, APIError } = require('../middleware/errorHandler');

const router = express.Router();

/**
 * @route   POST /api/v1/auth/register
 * @desc    Register a new user
 * @access  Public
 * @body    { username, email, password, fullName, age?, height?, weight? }
 */
router.post('/register', catchAsync(async (req, res) => {
  const { username, email, password, fullName, age, height, weight } = req.body;

  // Check if user already exists
  const existingUser = await User.findOne({
    $or: [{ email }, { username }]
  });

  if (existingUser) {
    throw new APIError('User with this email or username already exists', 400);
  }

  // Create new user
  const user = await User.create({
    username,
    email,
    password,
    fullName,
    age,
    height,
    weight
  });

  // Generate tokens
  const accessToken = user.generateAccessToken();
  const refreshToken = user.generateRefreshToken();

  // Store refresh token
  user.refreshTokens.push({
    token: refreshToken,
    createdAt: new Date()
  });
  await user.save();

  // Remove password from response
  user.password = undefined;

  res.status(201).json({
    status: 'success',
    message: 'User registered successfully',
    data: {
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        fullName: user.fullName,
        age: user.age,
        height: user.height,
        weight: user.weight,
        bmi: user.bmi,
        bmiCategory: user.bmiCategory,
        activityLevel: user.activityLevel,
        fitnessGoal: user.fitnessGoal,
        profilePicture: user.profilePicture,
        createdAt: user.createdAt
      },
      tokens: {
        accessToken,
        refreshToken,
        expiresIn: process.env.JWT_EXPIRES_IN || '24h'
      }
    }
  });
}));

/**
 * @route   POST /api/v1/auth/login
 * @desc    Authenticate user & get token
 * @access  Public
 * @body    { email, password }
 */
router.post('/login', catchAsync(async (req, res) => {
  const { email, password } = req.body;

  // Check if email and password are provided
  if (!email || !password) {
    throw new APIError('Please provide email and password', 400);
  }

  // Check if user exists and include password for comparison
  const user = await User.findOne({ email }).select('+password');

  if (!user || !(await user.comparePassword(password))) {
    throw new APIError('Invalid email or password', 401);
  }

  // Check if user is active
  if (!user.isActive) {
    throw new APIError('Your account has been deactivated. Please contact support.', 401);
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

  // Remove password from response
  user.password = undefined;

  res.status(200).json({
    status: 'success',
    message: 'Login successful',
    data: {
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        fullName: user.fullName,
        age: user.age,
        height: user.height,
        weight: user.weight,
        bmi: user.bmi,
        bmiCategory: user.bmiCategory,
        activityLevel: user.activityLevel,
        fitnessGoal: user.fitnessGoal,
        profilePicture: user.profilePicture,
        lastLogin: user.lastLogin
      },
      tokens: {
        accessToken,
        refreshToken,
        expiresIn: process.env.JWT_EXPIRES_IN || '24h'
      }
    }
  });
}));

/**
 * @route   POST /api/v1/auth/refresh
 * @desc    Refresh access token using refresh token
 * @access  Public
 * @body    { refreshToken }
 */
router.post('/refresh', catchAsync(async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    throw new APIError('Refresh token is required', 400);
  }

  try {
    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    
    // Find user and check if refresh token exists
    const user = await User.findById(decoded.id);
    
    if (!user) {
      throw new APIError('Invalid refresh token', 401);
    }

    // Check if refresh token exists in user's stored tokens
    const tokenExists = user.refreshTokens.some(
      (tokenObj) => tokenObj.token === refreshToken
    );

    if (!tokenExists) {
      throw new APIError('Invalid refresh token', 401);
    }

    // Generate new access token
    const newAccessToken = user.generateAccessToken();
    
    res.status(200).json({
      status: 'success',
      message: 'Token refreshed successfully',
      data: {
        accessToken: newAccessToken,
        expiresIn: process.env.JWT_EXPIRES_IN || '24h'
      }
    });

  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      throw new APIError('Refresh token has expired. Please login again.', 401);
    }
    throw new APIError('Invalid refresh token', 401);
  }
}));

/**
 * @route   POST /api/v1/auth/logout
 * @desc    Logout user and remove refresh token
 * @access  Private
 * @body    { refreshToken }
 */
router.post('/logout', catchAsync(async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    throw new APIError('Refresh token is required', 400);
  }

  try {
    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    
    // Find user and remove refresh token
    const user = await User.findById(decoded.id);
    
    if (user) {
      user.refreshTokens = user.refreshTokens.filter(
        (tokenObj) => tokenObj.token !== refreshToken
      );
      await user.save();
    }

    res.status(200).json({
      status: 'success',
      message: 'Logged out successfully'
    });

  } catch (error) {
    // Even if token is invalid, we consider logout successful
    res.status(200).json({
      status: 'success',
      message: 'Logged out successfully'
    });
  }
}));

/**
 * @route   POST /api/v1/auth/logout-all
 * @desc    Logout from all devices (clear all refresh tokens)
 * @access  Private
 * @body    { refreshToken }
 */
router.post('/logout-all', catchAsync(async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    throw new APIError('Refresh token is required', 400);
  }

  try {
    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    
    // Find user and clear all refresh tokens
    const user = await User.findById(decoded.id);
    
    if (user) {
      user.refreshTokens = [];
      await user.save();
    }

    res.status(200).json({
      status: 'success',
      message: 'Logged out from all devices successfully'
    });

  } catch (error) {
    throw new APIError('Invalid refresh token', 401);
  }
}));

/**
 * @route   GET /api/v1/auth/me
 * @desc    Get current user profile
 * @access  Private
 * @headers Authorization: Bearer <accessToken>
 */
router.get('/me', catchAsync(async (req, res) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new APIError('Access token is required', 401);
  }

  const token = authHeader.substring(7);

  try {
    // Verify access token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Find user
    const user = await User.findById(decoded.id);
    
    if (!user || !user.isActive) {
      throw new APIError('User not found or inactive', 401);
    }

    res.status(200).json({
      status: 'success',
      data: {
        user: {
          id: user._id,
          username: user.username,
          email: user.email,
          fullName: user.fullName,
          age: user.age,
          height: user.height,
          weight: user.weight,
          bmi: user.bmi,
          bmiCategory: user.bmiCategory,
          activityLevel: user.activityLevel,
          fitnessGoal: user.fitnessGoal,
          profilePicture: user.profilePicture,
          emailVerified: user.emailVerified,
          lastLogin: user.lastLogin,
          createdAt: user.createdAt
        }
      }
    });

  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      throw new APIError('Access token has expired', 401);
    }
    throw new APIError('Invalid access token', 401);
  }
}));

module.exports = router;