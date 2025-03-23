-- User roles with hierarchical permissions
CREATE TABLE IF NOT EXISTS user_roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  reach_level INTEGER NOT NULL CHECK (reach_level >= 0)
);

-- Users table with improved structure
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  control_number VARCHAR(20) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  role_id INTEGER REFERENCES user_roles(id) NOT NULL,
  primary_group_id INTEGER REFERENCES groups(id), -- Primary association (optional)
  schedule JSONB DEFAULT '{}'::JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Groups (departments, grades, etc.)
CREATE TABLE IF NOT EXISTS groups (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  type VARCHAR(30) NOT NULL, -- 'grade', 'department', etc.
  parent_id INTEGER REFERENCES groups(id), -- For hierarchical grouping
  UNIQUE (name, type)
);

-- User-Group associations (many-to-many)
-- This is necessary despite seeming redundant, as it allows users to belong to multiple groups
CREATE TABLE IF NOT EXISTS user_groups (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  group_id INTEGER REFERENCES groups(id) ON DELETE CASCADE,
  UNIQUE (user_id, group_id)
);

-- Classes table
CREATE TABLE IF NOT EXISTS classes (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(20) NOT NULL,
  group_id INTEGER REFERENCES groups(id), -- Which group this class belongs to
  description TEXT,
  UNIQUE (code)
);

-- User-Class enrollments (many-to-many)
CREATE TABLE IF NOT EXISTS user_classes (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  class_id INTEGER REFERENCES classes(id) ON DELETE CASCADE,
  role VARCHAR(20) NOT NULL, -- 'student', 'teacher', 'assistant', etc.
  UNIQUE (user_id, class_id)
);

-- Notices with improved visibility control
CREATE TABLE IF NOT EXISTS notices (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  author_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  category VARCHAR(30) DEFAULT 'General',
  min_role_level INTEGER NOT NULL, -- Minimum role level that can see this notice
  target_groups INTEGER[], -- Array of group IDs this notice targets
  target_classes INTEGER[], -- Array of class IDs this notice targets
  has_attachment BOOLEAN DEFAULT FALSE,
  attachment_url TEXT,
  attachment_key TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  publish_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  expiry_date TIMESTAMP WITH TIME ZONE
);

-- Polls with simplified structure
CREATE TABLE IF NOT EXISTS polls (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  question TEXT NOT NULL,
  options JSONB NOT NULL, -- Store poll options as JSON array
  author_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  min_role_level INTEGER NOT NULL, -- Minimum role level that can see/vote
  target_groups INTEGER[], -- Array of group IDs this poll targets
  target_classes INTEGER[], -- Array of class IDs this poll targets
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  expiry_date TIMESTAMP WITH TIME ZONE
);

-- Poll responses
CREATE TABLE IF NOT EXISTS poll_responses (
  id SERIAL PRIMARY KEY,
  poll_id INTEGER REFERENCES polls(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  selected_option INTEGER NOT NULL, -- Index of the selected option
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (poll_id, user_id)
);

-- Resources (combines scholarships and job board)
CREATE TABLE IF NOT EXISTS resources (
  id SERIAL PRIMARY KEY,
  type VARCHAR(30) NOT NULL, -- 'scholarship', 'job', 'event', etc.
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  details JSONB NOT NULL, -- Flexible JSON for different resource types
  min_role_level INTEGER NOT NULL,
  target_groups INTEGER[],
  target_classes INTEGER[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  expiry_date TIMESTAMP WITH TIME ZONE
);