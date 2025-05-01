-- Update quizzes table to properly use user_id for ownership
ALTER TABLE quizzes 
    DROP COLUMN IF EXISTS created_by,
    ADD COLUMN user_id UUID REFERENCES auth.users(id);

-- Re-enable RLS on all tables
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE responses ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Allow full access to quizzes" ON quizzes;
DROP POLICY IF EXISTS "Allow full access to questions" ON questions;
DROP POLICY IF EXISTS "Allow full access to responses" ON responses;

-- Create RLS policies for quizzes
-- Users can view only their own quizzes or public active quizzes
CREATE POLICY "Users can view own quizzes" ON quizzes
    FOR SELECT USING (
        auth.uid() = user_id OR active = true
    );

-- Users can insert their own quizzes
CREATE POLICY "Users can insert own quizzes" ON quizzes
    FOR INSERT WITH CHECK (
        auth.uid() = user_id
    );

-- Users can update their own quizzes
CREATE POLICY "Users can update own quizzes" ON quizzes
    FOR UPDATE USING (
        auth.uid() = user_id
    );

-- Users can delete their own quizzes
CREATE POLICY "Users can delete own quizzes" ON quizzes
    FOR DELETE USING (
        auth.uid() = user_id
    );

-- Create RLS policies for questions
-- Users can view questions from their own quizzes or from public active quizzes
CREATE POLICY "Users can view questions" ON questions
    FOR SELECT USING (
        quiz_id IN (
            SELECT id FROM quizzes 
            WHERE user_id = auth.uid() OR active = true
        )
    );

-- Users can insert/update/delete questions on their own quizzes
CREATE POLICY "Users can modify questions" ON questions
    USING (
        quiz_id IN (
            SELECT id FROM quizzes 
            WHERE user_id = auth.uid()
        )
    )
    WITH CHECK (
        quiz_id IN (
            SELECT id FROM quizzes 
            WHERE user_id = auth.uid()
        )
    );

-- Create RLS policies for responses
-- Users can view responses from their own quizzes or from public active quizzes
CREATE POLICY "Users can view responses" ON responses
    FOR SELECT USING (
        question_id IN (
            SELECT id FROM questions
            WHERE quiz_id IN (
                SELECT id FROM quizzes
                WHERE user_id = auth.uid() OR active = true
            )
        )
    );

-- Anyone can insert responses
CREATE POLICY "Anyone can submit responses" ON responses
    FOR INSERT WITH CHECK (true); 