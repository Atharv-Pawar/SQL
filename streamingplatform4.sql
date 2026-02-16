/*
🎧 SQL INTERVIEW SET — MAANG LEVEL (PRACTICAL LOGIC)
📊 Tables (same)
users(user_id, signup_date, country)
events(user_id, event_date, event_type)
tracks(track_id, artist_id, genre, duration_sec)
plays(user_id, track_id, play_date, seconds_played)
subscriptions(user_id, start_date, end_date)
*/

-- 🔹 SET 1 — JOIN + EXACT WORDING
-- Q1. Active but Not Engaged
-- Return users who:
-- logged in on at least 3 distinct days
-- but never played a track
-- ⚠️ Must be JOIN-based
-- ⚠️ Users table must drive result

-- Q2. Paid Activity Only
-- Return users who:
-- played tracks only during active subscription
-- and never outside subscription
-- ⚠️ Anti-join logic required

-- Q3. Artist With Zero Paid Plays
-- Return artists whose tracks:
-- have plays
-- but none from paid users

-- 🔹 SET 2 — AGGREGATION (ANALYST THINKING)
-- Q4. Country Engagement Leader
-- For each country:
-- Return the user with highest total seconds played
-- Output:
-- country | user_id | total_seconds
-- ⚠️ Handle ties

-- Q5. Genre Loyalty
-- Return users who:
-- listened to only one genre
-- and have ≥ 10 plays

-- Q6. Underplayed Tracks
-- Return tracks where:
-- total seconds played < 30% of track duration × play count
-- 👉 Detect “skipped-heavy” tracks

-- 🔹 SET 3 — WINDOW FUNCTIONS (CORE)
-- Q7. First Paid Play
-- Return for each user:
-- the first play that happened during an active subscription
-- Output:
-- user_id | play_date | track_id
-- ⚠️ Must use window, not MIN + join

-- Q8. Monthly Top Listener per Artist
-- For each artist and month:
-- return the top user by total seconds played
-- Output:
-- artist_id | month | user_id | seconds

-- Q9. Increasing Monthly Usage
-- Return users whose:
-- total monthly seconds played is strictly increasing month-over-month

-- 🔹 SET 4 — DATE + STREAK LOGIC
-- Q10. Exactly 3-Day Play Streak
-- Return users who had:
-- at least one streak of exactly 3 consecutive play days
-- but never 4+
-- ⚠️ Classic row_number date trick

-- Q11. Reactivated Users
-- A reactivated user:
-- had a play
-- then no plays for ≥ 30 days
-- then played again
-- Return those users.

-- 🔹 SET 5 — DATA ENGINEER QUALITY CHECKS
-- Q12. Overlapping Subscriptions With Plays
-- Return users who:
-- have overlapping subscriptions
-- and made a play during the overlap period
-- ⚠️ Self-join + date intersection

-- Q13. Duplicate Event Detection
-- Find users who:
-- have multiple identical events
-- (same user_id, event_type, event_date)
-- Return duplicates with count > 1.

-- Q14. Missing Dimension Check
-- Return plays where:
-- track_id does not exist in tracks table
-- (Data quality anti-join)
