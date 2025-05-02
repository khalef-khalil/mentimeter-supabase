-- Create view for session_results that includes participant information
CREATE OR REPLACE VIEW session_results_with_participants AS
SELECT 
  sr.*,
  sp.username,
  sp.is_host
FROM 
  session_results sr
JOIN 
  session_participants sp ON sr.session_id = sp.session_id AND sr.user_id = sp.user_id; 