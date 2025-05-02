-- Create enum types for difficulty and category
CREATE TYPE quiz_difficulty AS ENUM ('easy', 'medium', 'hard');
CREATE TYPE quiz_category AS ENUM ('general', 'science', 'history', 'geography', 'entertainment', 'sports', 'technology');

-- Add difficulty and category fields to quizzes table
ALTER TABLE quizzes
ADD COLUMN difficulty quiz_difficulty DEFAULT 'medium'::quiz_difficulty,
ADD COLUMN category quiz_category DEFAULT 'general'::quiz_category;

-- Create favorites table
CREATE TABLE quiz_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(quiz_id, user_id)
);

-- Add RLS policies for favorites
ALTER TABLE quiz_favorites ENABLE ROW LEVEL SECURITY;

-- Users can view only their own favorites
CREATE POLICY "Users can view their own favorites"
  ON quiz_favorites FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own favorites
CREATE POLICY "Users can insert their own favorites"
  ON quiz_favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own favorites
CREATE POLICY "Users can delete their own favorites"
  ON quiz_favorites FOR DELETE
  USING (auth.uid() = user_id);

-- Create index for faster favorites lookup
CREATE INDEX idx_quiz_favorites_user_id ON quiz_favorites(user_id);
CREATE INDEX idx_quiz_favorites_quiz_id ON quiz_favorites(quiz_id);

-- Create view for easier favorites queries
CREATE OR REPLACE VIEW user_favorites_view AS
SELECT 
  f.id as favorite_id,
  f.user_id,
  f.quiz_id,
  f.created_at as favorited_at,
  q.title as quiz_title,
  q.difficulty,
  q.category,
  q.created_at as quiz_created_at,
  u.email as creator_email
FROM 
  quiz_favorites f
JOIN 
  quizzes q ON f.quiz_id = q.id
LEFT JOIN 
  auth.users u ON q.user_id = u.id;

-- Add RLS policy to allow quiz deletion by owners
CREATE POLICY "Users can delete their own quizzes"
  ON quizzes FOR DELETE
  USING (auth.uid() = user_id); 