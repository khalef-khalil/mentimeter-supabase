-- This migration adds documentation for the correct_option field
-- No actual schema changes are needed since we're storing the correct_option in the existing JSONB options field
-- The code already handles this field in the Question model

COMMENT ON TABLE questions IS 'Questions for quizzes with multiple choice or word cloud options';
COMMENT ON COLUMN questions.options IS 'JSONB field containing choices array for options and correct_option for the correct answer'; 