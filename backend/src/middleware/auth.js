/**
 * Authentication Middleware
 * 
 * Middleware to protect routes and extract user information from JWT tokens
 */

const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { catchAsync, APIError } = require('./errorHandler');

/**
 * Protect routes - require valid JWT token
 * Adds user object to req.user
 */
const protect = catchAsync(async (req, res, next) => {
  // Get token from header
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new APIError('Access token is required', 401);
  }

  const token = authHeader.substring(7); // Remove 'Bearer ' prefix

  try {
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Find user and check if still exists
    const user = await User.findById(decoded.id);
    
    if (!user || !user.isActive) {
      throw new APIError('User not found or inactive', 401);
    }

    // Add user to request
    req.user = user;
    next();
    
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      throw new APIError('Invalid token', 401);
    } else if (error.name === 'TokenExpiredError') {
      throw new APIError('Token expired', 401);
    } else {
      throw error;
    }
  }
});

/**
 * Optional auth - doesn't throw error if no token
 * Adds user to req.user if valid token is provided
 */
const optionalAuth = catchAsync(async (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(); // Continue without user
  }

  const token = authHeader.substring(7);

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id);
    
    if (user && user.isActive) {
      req.user = user;
    }
  } catch (error) {
    // Ignore errors in optional auth
  }
  
  next();
});

/**
 * Restrict to certain roles
 * Must be used after protect middleware
 */
const restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      throw new APIError('Authentication required', 401);
    }
    
    if (!roles.includes(req.user.role)) {
      throw new APIError('You do not have permission to perform this action', 403);
    }
    
    next();
  };
};

module.exports = {
  protect,
  optionalAuth,
  restrictTo
};