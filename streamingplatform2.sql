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
SELECT u.user_id, u.user_name, COUNT(t.track_id) AS total_pop_listens
FROM users u 
LEFT JOIN listens l ON u.user_id = l.user_id
LEFT JOIN tracks t ON l.track_id = t.track_id AND t.genre = 'Pop'
GROUP BY u.user_id, u.user_name;

-- Q2. “ONLY” Keyword Trap
-- 👉 Return users who listened only Rock tracks
-- 👉 If user listened to Rock + any other genre → exclude
-- 📌 Think carefully: NOT EXISTS vs HAVING
SELECT u.user_id
FROM users u
JOIN listens l ON u.user_id = l.user_id
JOIN tracks t ON l.track_id = t.track_id
GROUP BY u.user_id
HAVING
  SUM(CASE WHEN t.genre = 'Rock' THEN 1 ELSE 0 END) > 0
  AND
  SUM(CASE WHEN t.genre <> 'Rock' THEN 1 ELSE 0 END) = 0;

-- Q3. Missing Data Logic
-- 👉 Return artists who have tracks
-- 👉 But no one has ever listened to any of their tracks
-- ⚠️ Use JOIN logic only (no NOT IN)
SELECT a.artist_id, a.artist_name
FROM artists a 
JOIN tracks t ON a.artist_id = t.artist_id
LEFT JOIN listens l ON t.track_id = l.track_id
WHERE l.user_id IS NULL;

-- 🔹 SET 7 — AGGREGATION + BUSINESS THINKING
-- Q4. Revenue-style Question
-- 👉 Assume 1 listen = ₹1
-- 👉 Return:
-- artist_name | total_revenue
-- 👉 Only include artists with revenue > overall average revenue
-- ⚠️ No GROUP BY in outer query
SELECT DISTINCT artist_name
FROM (
  SELECT a.artist_name,
         COUNT(l.user_id) OVER (PARTITION BY a.artist_id) AS total_revenue,
         AVG(COUNT(l.user_id)) OVER () AS avg_revenue
  FROM artists a
  JOIN tracks t ON a.artist_id = t.artist_id
  JOIN listens l ON t.track_id = l.track_id
) t
WHERE total_revenue > avg_revenue;

-- Q5. Per-user Behavior
-- 👉 Return users whose listening pattern is increasing
-- 👉 Meaning: listens per day is strictly increasing day-by-day
-- 📌 Window functions required
WITH daily AS (
  SELECT l.user_id, l.listen_date,
         SUM(t.duration_sec) AS daily_duration
  FROM listens l
  JOIN tracks t ON l.track_id = t.track_id
  GROUP BY l.user_id, l.listen_date
),
comp AS (
  SELECT *,
         LAG(daily_duration) OVER (PARTITION BY user_id ORDER BY listen_date) AS prev_dur
  FROM daily
)
SELECT DISTINCT user_id
FROM comp
GROUP BY user_id
HAVING SUM(CASE WHEN daily_duration <= prev_dur THEN 1 ELSE 0 END) = 0;	

-- 🔹 SET 8 — WINDOW FUNCTIONS (INTERVIEW FAVORITES)
-- Q6. Ranking Without Gaps
-- 👉 For each artist, rank tracks by duration
-- 👉 Longest track = rank 1
-- 👉 No gaps in ranking
-- 📌 Difference between RANK() vs DENSE_RANK()

-- RANK() ranking with gap in case of handling ties | DENSE_RANK() ranking without gap 
SELECT track_id, artist_id, genre, duration_sec, release_date, 
  DENSE_RANK() OVER(PARTITION BY artist_id ORDER BY duration_sec DESC) AS rank_track_duration
FROM tracks;

-- Q7. Second Best per Group ⚠️
-- 👉 Return the second longest track per genre
-- 👉 If genre has only one track → exclude
SELECT genre, duration_sec
FROM (
	SELECT track_id, artist_id, genre, duration_sec, release_date, 
	  DENSE_RANK() OVER(PARTITION BY genre ORDER BY duration_sec DESC) AS rank_track_duration
	FROM tracks
) t1
WHERE rank_track_duration = 2;

-- Q8. Compare Against Previous Row
-- 👉 Return listens where:
-- current listen duration > previous listen duration (same user)
-- 📌 LAG() mandatory
WITH daily AS (
  SELECT l.user_id, l.listen_date,
         SUM(t.duration_sec) AS daily_duration
  FROM listens l
  JOIN tracks t ON l.track_id = t.track_id
  GROUP BY l.user_id, l.listen_date
)
SELECT DISTINCT user_id
FROM (
  SELECT *,
         LAG(daily_duration) OVER (PARTITION BY user_id ORDER BY listen_date) AS prev_dur
  FROM daily
) t
WHERE daily_duration > prev_dur;

-- 🔹 SET 9 — DATE + CONSECUTIVE LOGIC 💀
-- Q9. Exact Consecutive Days
-- 👉 Return users who listened on exactly 5 consecutive days
-- 👉 And never before or after
-- 📌 One of the most asked patterns
SELECT user_id
FROM (
  SELECT user_id,
         listen_date - ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY listen_date) AS grp
  FROM listens
) t
GROUP BY user_id, grp
HAVING COUNT(*) = 5;

-- Q10. Subscription Overlap Trap ⚠️
-- 👉 Return users who listened on a day
-- 👉 When two subscriptions overlapped (bad data scenario)
-- 📌 Self-join on subscriptions
SELECT DISTINCT s1.user_id
FROM subscriptions s1
JOIN subscriptions s2
  ON s1.user_id = s2.user_id
 AND s1.start_date < s2.end_date
 AND s2.start_date < s1.end_date
 AND s1.start_date <> s2.start_date;

-- 🔹 SET 10 — FINAL INTERVIEW KILLERS 🔥
-- Q11. First vs Last Activity
-- 👉 Return users whose first ever listen
-- 👉 was shorter than their latest listen
-- ⚠️ Window functions only
-- ⚠️ No GROUP BY outer query
SELECT DISTINCT user_id 
FROM (
	SELECT l.user_id, t.duration_sec,
	  FIRST_VALUE(t.duration_sec) OVER(PARTITION BY l.user_id ORDER BY l.listen_date) AS first_listen,
	  FIRST_VALUE(t.duration_sec) OVER(PARTITION BY l.user_id ORDER BY l.listen_date DESC) AS latest_listen
	FROM listens l 
	JOIN tracks t ON l.track_id = t.track_id 
) t 
WHERE first_listen < latest_listen;

-- Q12. Behavioral Segmentation (Very Hard)
-- 👉 Classify users as:
-- BINGE → ≥10 listens in a single day
-- CASUAL → listens spread across ≥10 different days
-- INACTIVE → no listens
-- 👉 Output:
-- user_id | user_type
-- 📌 Multiple window + conditional logic
SELECT u.user_id,
       CASE
         WHEN MAX(daily_cnt) >= 10 THEN 'BINGE'
         WHEN COUNT(DISTINCT l.listen_date) >= 10 THEN 'CASUAL'
         WHEN COUNT(l.user_id) IS NULL THEN 'INACTIVE'
       END AS user_type
FROM users u
LEFT JOIN (
  SELECT user_id, listen_date, COUNT(*) AS daily_cnt
  FROM listens
  GROUP BY user_id, listen_date
) l ON u.user_id = l.user_id
GROUP BY u.user_id;
