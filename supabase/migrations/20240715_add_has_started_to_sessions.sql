-- Add has_started column to quiz_sessions table
ALTER TABLE quiz_sessions ADD COLUMN has_started BOOLEAN NOT NULL DEFAULT FALSE;

-- Create session_participants table for tracking participants in a session
CREATE TABLE IF NOT EXISTS session_participants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID NOT NULL REFERENCES quiz_sessions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  is_host BOOLEAN NOT NULL DEFAULT FALSE,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(session_id, user_id)
);

-- Create session_results table for storing quiz results
CREATE TABLE IF NOT EXISTS session_results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID NOT NULL REFERENCES quiz_sessions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  score INTEGER NOT NULL DEFAULT 0,
  time_spent INTEGER NOT NULL DEFAULT 0,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(session_id, user_id)
);

-- Enable Row Level Security
ALTER TABLE session_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_results ENABLE ROW LEVEL SECURITY;

-- Create policies for session_participants
CREATE POLICY "Anyone can view session participants"
  ON session_participants FOR SELECT
  USING (true);

CREATE POLICY "Users can add themselves as participants"
  ON session_participants FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create policies for session_results
CREATE POLICY "Anyone can view session results"
  ON session_results FOR SELECT
  USING (true);

CREATE POLICY "Users can add their own results"
  ON session_results FOR INSERT
  WITH CHECK (auth.uid() = user_id); 