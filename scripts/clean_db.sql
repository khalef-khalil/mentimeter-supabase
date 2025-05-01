-- Script to clean all tables except user data
-- This will delete all data from quiz-related tables

-- First, disable RLS temporarily to allow deletion
ALTER TABLE quiz_sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes DISABLE ROW LEVEL SECURITY;
ALTER TABLE questions DISABLE ROW LEVEL SECURITY;
ALTER TABLE responses DISABLE ROW LEVEL SECURITY;

-- Delete all data, preserving users
TRUNCATE TABLE quiz_sessions CASCADE;
TRUNCATE TABLE responses CASCADE;
TRUNCATE TABLE questions CASCADE;
TRUNCATE TABLE quizzes CASCADE;

-- Re-enable RLS
ALTER TABLE quiz_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE responses ENABLE ROW LEVEL SECURITY;

-- Confirm the cleanup
SELECT 'Database cleaned successfully. User data preserved.' as result; 