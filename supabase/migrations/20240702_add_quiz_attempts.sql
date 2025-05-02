-- Create quiz_attempts table
CREATE TABLE quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  completed_at TIMESTAMP WITH TIME ZONE,
  correct_answers INT DEFAULT 0,
  total_questions INT DEFAULT 0,
  quiz_title TEXT NOT NULL
);

-- Add RLS policies
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

-- Users can view only their own attempts
CREATE POLICY "Users can view their own attempts"
  ON quiz_attempts FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own attempts
CREATE POLICY "Users can insert their own attempts"
  ON quiz_attempts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own attempts
CREATE POLICY "Users can update their own attempts"
  ON quiz_attempts FOR UPDATE
  USING (auth.uid() = user_id);

-- Create an index for faster user-based queries
CREATE INDEX idx_quiz_attempts_user_id ON quiz_attempts(user_id);

-- Add a view that joins quiz_attempts with quizzes
CREATE OR REPLACE VIEW quiz_attempts_view AS
  SELECT
    qa.id,
    qa.quiz_id,
    qa.user_id,
    qa.started_at,
    qa.completed_at,
    qa.correct_answers,
    qa.total_questions,
    qa.quiz_title,
    q.title as original_quiz_title,
    CASE WHEN qa.total_questions > 0 
      THEN (qa.correct_answers::float / qa.total_questions::float) * 100 
      ELSE 0 
    END as score_percentage
  FROM
    quiz_attempts qa
  LEFT JOIN
    quizzes q ON qa.quiz_id = q.id; 