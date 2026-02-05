/*
🎧 SQL INTERVIEW SET — STREAMING PLATFORM (SET 6)
📊 Tables (same as before)
users(user_id, user_name, country)
artists(artist_id, artist_name)
tracks(track_id, artist_id, genre, duration_sec, release_date)
listens(user_id, track_id, listen_date)
subscriptions(user_id, start_date, end_date)
*/

-- 🔹 SET 6 — JOIN + NULL + EXACT WORDING (Tricky)
-- Q1. LEFT JOIN + WHERE Trap ⚠️
-- 👉 Return all users
-- 👉 Show total_listens only for Pop genre
-- 👉 Users with zero Pop listens must still appear
-- 📌 One wrong WHERE clause = instant rejection

-- Q2. “ONLY” Keyword Trap
-- 👉 Return users who listened only Rock tracks
-- 👉 If user listened to Rock + any other genre → exclude
-- 📌 Think carefully: NOT EXISTS vs HAVING

-- Q3. Missing Data Logic
-- 👉 Return artists who have tracks
-- 👉 But no one has ever listened to any of their tracks
-- ⚠️ Use JOIN logic only (no NOT IN)

-- 🔹 SET 7 — AGGREGATION + BUSINESS THINKING
-- Q4. Revenue-style Question
-- 👉 Assume 1 listen = ₹1
-- 👉 Return:
-- artist_name | total_revenue
-- 👉 Only include artists with revenue > overall average revenue
-- ⚠️ No GROUP BY in outer query

-- Q5. Per-user Behavior
-- 👉 Return users whose listening pattern is increasing
-- 👉 Meaning: listens per day is strictly increasing day-by-day
-- 📌 Window functions required

-- 🔹 SET 8 — WINDOW FUNCTIONS (INTERVIEW FAVORITES)
-- Q6. Ranking Without Gaps
-- 👉 For each artist, rank tracks by duration
-- 👉 Longest track = rank 1
-- 👉 No gaps in ranking
-- 📌 Difference between RANK() vs DENSE_RANK()

-- Q7. Second Best per Group ⚠️
-- 👉 Return the second longest track per genre
-- 👉 If genre has only one track → exclude

-- Q8. Compare Against Previous Row
-- 👉 Return listens where:
-- current listen duration > previous listen duration (same user)
-- 📌 LAG() mandatory

-- 🔹 SET 9 — DATE + CONSECUTIVE LOGIC 💀
-- Q9. Exact Consecutive Days
-- 👉 Return users who listened on exactly 5 consecutive days
-- 👉 And never before or after
-- 📌 One of the most asked patterns

-- Q10. Subscription Overlap Trap ⚠️
-- 👉 Return users who listened on a day
-- 👉 When two subscriptions overlapped (bad data scenario)
-- 📌 Self-join on subscriptions

-- 🔹 SET 10 — FINAL INTERVIEW KILLERS 🔥
-- Q11. First vs Last Activity
-- 👉 Return users whose first ever listen
-- 👉 was shorter than their latest listen
-- ⚠️ Window functions only
-- ⚠️ No GROUP BY outer query

-- Q12. Behavioral Segmentation (Very Hard)
-- 👉 Classify users as:
-- BINGE → ≥10 listens in a single day
-- CASUAL → listens spread across ≥10 different days
-- INACTIVE → no listens
-- 👉 Output:
-- user_id | user_type
-- 📌 Multiple window + conditional logic
