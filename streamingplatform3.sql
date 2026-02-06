/*
🎧 SQL INTERVIEW SET — ADVANCED (NEW QUESTIONS)
📊 Tables
users(user_id, user_name, signup_date)
artists(artist_id, artist_name)
tracks(track_id, artist_id, genre, duration_sec, release_date)
listens(user_id, track_id, listen_date)
subscriptions(subscription_id, user_id, start_date, end_date)
*/

-- 🔹 SET 1 — JOIN + EXACT WORDING (TRAPS)
-- Q1. “At Least One but Not All”
-- 👉 Return users who listened to at least one Rock track
-- 👉 but NOT all of their listens are Rock
-- ⚠️ Misusing WHERE = wrong answer

-- Q2. LEFT JOIN Preservation
-- 👉 Return all artists
-- 👉 Show total_listens
-- 👉 Artists with zero listens must show 0, not NULL

-- Q3. Multi-Condition Join Trap
-- 👉 Return users who listened to tracks
-- 👉 only during an active subscription period
-- 👉 Ignore listens outside subscription

-- 🔹 SET 2 — WINDOW FUNCTIONS (CORE INTERVIEW)
-- Q4. Median Logic (Hard)
-- 👉 Return median track duration per genre
-- ⚠️ Use window functions
-- ⚠️ No PERCENTILE_CONT if DB doesn’t support it

-- Q5. Relative Performance
-- 👉 Return tracks that are
-- 👉 longer than artist’s average duration
-- 👉 but shorter than global maximum duration

-- Q6. Dense Ranking Logic
-- 👉 Return top 3 genres per artist
-- 👉 based on total listens
-- ⚠️ Handle ties correctly

-- 🔹 SET 3 — DATE & CONSECUTIVE PATTERNS 💀
-- Q7. Broken Streak
-- 👉 Return users who had
-- 👉 at least one 3-day consecutive listening streak
-- 👉 but never a 4-day streak

-- Q8. First-Time Behavior
-- 👉 Return users whose
-- 👉 first ever listen was
-- 👉 during an inactive subscription period

-- 🔹 SET 4 — BUSINESS SQL (REAL WORLD)
-- Q9. Churn Signal
-- 👉 A user is at risk if:
-- listened in previous month
-- did NOT listen in current month
-- subscription is still active
-- Return at-risk users.

-- Q10. Catalog Coverage
-- 👉 Return artists where
-- 👉 every genre they released
-- 👉 has at least 1 listen

-- 🔹 SET 5 — FINAL INTERVIEW KILLERS 🔥
-- Q11. Time-Based Ranking
-- 👉 For each user:
-- rank listens by duration
-- reset ranking every month
-- longest = rank 1

-- Q12. Behavioral Segmentation (Very Hard)
-- Classify users as:
-- POWER → listens on ≥20 distinct days
-- WEEKEND → listens only on Sat/Sun
-- DORMANT → no listens in last 90 days
-- Output:
-- user_id | user_type
