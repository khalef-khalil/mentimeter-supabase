-- Create quizzes table
CREATE TABLE quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  created_by TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  active BOOLEAN DEFAULT false
);

-- Create questions table
CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  question_type TEXT NOT NULL, -- 'multiple_choice', 'word_cloud', etc.
  options JSONB, -- For multiple choice options
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  position INTEGER DEFAULT 0 -- Order of questions in the quiz
);

-- Create responses table
CREATE TABLE responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  response_data JSONB NOT NULL, -- The answer data
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create RLS Policies
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE responses ENABLE ROW LEVEL SECURITY;

-- Public access policies (for anonymous users)
CREATE POLICY "Public quizzes are viewable by everyone"
  ON quizzes FOR SELECT
  USING (active = true);

CREATE POLICY "Public questions are viewable by everyone"
  ON questions FOR SELECT
  USING (
    quiz_id IN (
      SELECT id FROM quizzes WHERE active = true
    )
  );

CREATE POLICY "Anyone can submit responses"
  ON responses FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Public responses are viewable by everyone"
  ON responses FOR SELECT
  USING (
    question_id IN (
      SELECT id FROM questions WHERE 
        quiz_id IN (
          SELECT id FROM quizzes WHERE active = true
        )
    )
  ); 