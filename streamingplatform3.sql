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
SELECT l.user_id
FROM listens l
JOIN tracks t ON l.track_id = t.track_id
GROUP BY l.user_id
HAVING
    SUM(CASE WHEN t.genre = 'Rock' THEN 1 ELSE 0 END) >= 1
AND SUM(CASE WHEN t.genre <> 'Rock' THEN 1 ELSE 0 END) >= 1;


-- Q2. LEFT JOIN Preservation
-- 👉 Return all artists
-- 👉 Show total_listens
-- 👉 Artists with zero listens must show 0, not NULL
SELECT a.artist_id, a.artist_name,
       COUNT(l.track_id) AS total_listens
FROM artists a
LEFT JOIN tracks t ON a.artist_id = t.artist_id
LEFT JOIN listens l ON t.track_id = l.track_id
GROUP BY a.artist_id, a.artist_name;

-- Q3. Multi-Condition Join Trap
-- 👉 Return users who listened to tracks
-- 👉 only during an active subscription period
-- 👉 Ignore listens outside subscription
SELECT l.user_id AS users_listening_tracks
FROM tracks t JOIN listens l ON t.track_id = l.track_id
JOIN subscriptions s ON l.user_id = s.user_id
  AND l.listen_date BETWEEN s.start_date AND s.end_date;

-- 🔹 SET 2 — WINDOW FUNCTIONS (CORE INTERVIEW)
-- Q4. Median Logic (Hard)
-- 👉 Return median track duration per genre
-- ⚠️ Use window functions
-- ⚠️ No PERCENTILE_CONT if DB doesn’t support it
WITH ranked AS (
  SELECT genre, duration_sec,
         ROW_NUMBER() OVER(PARTITION BY genre ORDER BY duration_sec) AS rn,
         COUNT(*) OVER(PARTITION BY genre) AS cnt
  FROM tracks
)
SELECT genre,
       AVG(duration_sec) AS median_duration
FROM ranked
WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
GROUP BY genre;

-- MEAN means AVERAGE; MEDIAN means value of middle row of the sorted table; Mode means most frequent value 

-- Q5. Relative Performance
-- 👉 Return tracks that are
-- 👉 longer than artist’s average duration
-- 👉 but shorter than global maximum duration
SELECT DISTINCT track_id 
FROM (
	SELECT track_id, artist_id, duration_sec, 
	  AVG(duration_sec) OVER(PARTITION BY artist_id) AS artist_avg_duration,
	  MAX(duration_sec) OVER() AS global_max_duration 
	FROM tracks 
) t 
WHERE duration_sec > artist_avg_duration
  AND duration_sec < global_max_duration;

-- Q6. Dense Ranking Logic
-- 👉 Return top 3 genres per artist
-- 👉 based on total listens
-- ⚠️ Handle ties correctly
SELECT artist_id, genre
FROM (
  SELECT t.artist_id, t.genre,
         COUNT(*) AS total_listens,
         DENSE_RANK() OVER(
           PARTITION BY t.artist_id
           ORDER BY COUNT(*) DESC
         ) AS rnk
  FROM tracks t
  JOIN listens l ON t.track_id = l.track_id
  GROUP BY t.artist_id, t.genre
) x
WHERE rnk <= 3;


-- 🔹 SET 3 — DATE & CONSECUTIVE PATTERNS 💀
-- Q7. Broken Streak
-- 👉 Return users who had
-- 👉 at least one 3-day consecutive listening streak
-- 👉 but never a 4-day streak
WITH streaks AS (
  SELECT user_id,
         listen_date - ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY listen_date) AS grp
  FROM listens
),
counts AS (
  SELECT user_id, COUNT(*) AS streak_len
  FROM streaks
  GROUP BY user_id, grp
)
SELECT user_id
FROM counts
GROUP BY user_id
HAVING
    MAX(streak_len) = 3;

-- Q8. First-Time Behavior
-- 👉 Return users whose
-- 👉 first ever listen was
-- 👉 during an inactive subscription period
WITH first_listen AS (
  SELECT user_id, MIN(listen_date) AS first_date
  FROM listens
  GROUP BY user_id
)
SELECT f.user_id
FROM first_listen f
LEFT JOIN subscriptions s
  ON f.user_id = s.user_id
 AND f.first_date BETWEEN s.start_date AND s.end_date
WHERE s.user_id IS NULL;


-- 🔹 SET 4 — BUSINESS SQL (REAL WORLD)
-- Q9. Churn Signal
-- 👉 A user is at risk if:
-- listened in previous month
-- did NOT listen in current month
-- subscription is still active
-- Return at-risk users.
SELECT DISTINCT s.user_id
FROM subscriptions s
WHERE CURRENT_DATE BETWEEN s.start_date AND s.end_date
AND EXISTS (
  SELECT 1
  FROM listens l
  WHERE l.user_id = s.user_id
    AND l.listen_date >= date_trunc('month', CURRENT_DATE - INTERVAL '1 month')
    AND l.listen_date <  date_trunc('month', CURRENT_DATE)
)
AND NOT EXISTS (
  SELECT 1
  FROM listens l
  WHERE l.user_id = s.user_id
    AND l.listen_date >= date_trunc('month', CURRENT_DATE)
);


-- Q10. Catalog Coverage
-- 👉 Return artists where
-- 👉 every genre they released
-- 👉 has at least 1 listen
SELECT a.artist_id
FROM artists a
WHERE NOT EXISTS (
  SELECT 1
  FROM tracks t
  WHERE t.artist_id = a.artist_id
    AND NOT EXISTS (
      SELECT 1
      FROM listens l
      WHERE l.track_id = t.track_id
    )
);


-- 🔹 SET 5 — FINAL INTERVIEW KILLERS 🔥
-- Q11. Time-Based Ranking
-- 👉 For each user:
-- rank listens by duration
-- reset ranking every month
-- longest = rank 1
SELECT user_id, listen_date, duration_sec,
       RANK() OVER(
         PARTITION BY user_id,
                      date_trunc('month', listen_date)
         ORDER BY duration_sec DESC
       ) AS rnk
FROM listens l
JOIN tracks t ON l.track_id = t.track_id;


-- Q12. Behavioral Segmentation (Very Hard)
-- Classify users as:
-- POWER → listens on ≥20 distinct days
-- WEEKEND → listens only on Sat/Sun
-- DORMANT → no listens in last 90 days
-- Output:
-- user_id | user_type
WITH activity AS (
  SELECT user_id,
         COUNT(DISTINCT listen_date) AS active_days,
         MAX(listen_date) AS last_listen,
         SUM(CASE WHEN EXTRACT(DOW FROM listen_date) NOT IN (0,6) THEN 1 ELSE 0 END) AS weekday_listens
  FROM listens
  GROUP BY user_id
)
SELECT u.user_id,
       CASE
         WHEN a.active_days >= 20 THEN 'POWER'
         WHEN a.weekday_listens = 0 AND a.active_days > 0 THEN 'WEEKEND'
         WHEN a.last_listen < CURRENT_DATE - INTERVAL '90 days'
              OR a.last_listen IS NULL THEN 'DORMANT'
       END AS user_type
FROM users u
LEFT JOIN activity a ON u.user_id = a.user_id;
