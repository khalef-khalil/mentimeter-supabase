-- Add timer field to questions
ALTER TABLE questions
ADD COLUMN timer_seconds INTEGER DEFAULT 30;

-- Create quiz_sessions table
CREATE TABLE quiz_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  host_id UUID REFERENCES auth.users(id),
  join_code TEXT NOT NULL UNIQUE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create RLS policies for quiz_sessions
ALTER TABLE quiz_sessions ENABLE ROW LEVEL SECURITY;

-- Hosts can manage their sessions
CREATE POLICY "Hosts can manage their sessions" ON quiz_sessions
    USING (host_id = auth.uid())
    WITH CHECK (host_id = auth.uid());

-- Anyone can view active sessions
CREATE POLICY "Anyone can view active sessions" ON quiz_sessions
    FOR SELECT USING (is_active = true OR host_id = auth.uid());

-- Create a function to generate random join codes
CREATE OR REPLACE FUNCTION generate_join_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  result TEXT := '';
  i INTEGER;
BEGIN
  FOR i IN 1..6 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql; 