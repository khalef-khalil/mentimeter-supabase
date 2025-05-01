-- Re-enable RLS but with permissive policies
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE responses ENABLE ROW LEVEL SECURITY;

-- Create permissive policies for all users
-- Quizzes table policies
CREATE POLICY "Allow full access to quizzes" ON quizzes
    USING (true)
    WITH CHECK (true);

-- Questions table policies
CREATE POLICY "Allow full access to questions" ON questions
    USING (true)
    WITH CHECK (true);

-- Responses table policies
CREATE POLICY "Allow full access to responses" ON responses
    USING (true)
    WITH CHECK (true); 