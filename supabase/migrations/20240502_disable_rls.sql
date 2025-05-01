-- Drop existing RLS policies
DROP POLICY IF EXISTS "Public quizzes are viewable by everyone" ON quizzes;
DROP POLICY IF EXISTS "Public questions are viewable by everyone" ON questions;
DROP POLICY IF EXISTS "Anyone can submit responses" ON responses;
DROP POLICY IF EXISTS "Public responses are viewable by everyone" ON responses;

-- Disable Row Level Security
ALTER TABLE quizzes DISABLE ROW LEVEL SECURITY;
ALTER TABLE questions DISABLE ROW LEVEL SECURITY;
ALTER TABLE responses DISABLE ROW LEVEL SECURITY; 