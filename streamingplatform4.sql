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
SELECT u.user_id
FROM users u
LEFT JOIN events e 
  ON u.user_id = e.user_id 
  AND e.event_type = 'login'
LEFT JOIN plays p 
  ON u.user_id = p.user_id
WHERE p.user_id IS NULL
GROUP BY u.user_id
HAVING COUNT(DISTINCT e.event_date) >= 3;

-- Q2. Paid Activity Only
-- Return users who:
-- played tracks only during active subscription
-- and never outside subscription
-- ⚠️ Anti-join logic required
SELECT u.user_id
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM plays p
    JOIN subscriptions s 
      ON p.user_id = s.user_id
     AND p.play_date BETWEEN s.start_date AND s.end_date
    WHERE p.user_id = u.user_id
)
AND NOT EXISTS (
    SELECT 1
    FROM plays p
    WHERE p.user_id = u.user_id
      AND NOT EXISTS (
          SELECT 1
          FROM subscriptions s
          WHERE s.user_id = p.user_id
            AND p.play_date BETWEEN s.start_date AND s.end_date
      )
);

-- Q3. Artist With Zero Paid Plays
-- Return artists whose tracks:
-- have plays
-- but none from paid users
SELECT t.artist_id
FROM tracks t
JOIN plays p ON t.track_id = p.track_id
GROUP BY t.artist_id
HAVING SUM(
  CASE 
    WHEN EXISTS (
      SELECT 1
      FROM subscriptions s
      WHERE s.user_id = p.user_id
        AND p.play_date BETWEEN s.start_date AND s.end_date
    ) THEN 1 ELSE 0 
  END
) = 0;

-- 🔹 SET 2 — AGGREGATION (ANALYST THINKING)
-- Q4. Country Engagement Leader
-- For each country:
-- Return the user with highest total seconds played
-- Output:
-- country | user_id | total_seconds
-- ⚠️ Handle ties
WITH user_totals AS (
  SELECT u.country, u.user_id,
         SUM(p.seconds_played) AS total_seconds
  FROM users u
  JOIN plays p ON u.user_id = p.user_id
  GROUP BY u.country, u.user_id
),
ranked AS (
  SELECT *,
         DENSE_RANK() OVER(PARTITION BY country ORDER BY total_seconds DESC) AS rnk
  FROM user_totals
)
SELECT country, user_id, total_seconds
FROM ranked
WHERE rnk = 1;

-- Q5. Genre Loyalty
-- Return users who:
-- listened to only one genre
-- and have ≥ 10 plays
SELECT p.user_id, 
COUNT(p.track_id) AS numberOfPlays 
FROM plays p 
JOIN tracks t ON p.track_id = t.track_id 
GROUP BY p.user_id 
HAVING COUNT(p.track_id) >= 10 
AND COUNT(DISTINCT t.genre) = 1;

-- 🔹 SET 3 — WINDOW FUNCTIONS (CORE)
-- Q7. First Paid Play
-- Return for each user:
-- the first play that happened during an active subscription
-- Output:
-- user_id | play_date | track_id
-- ⚠️ Must use window, not MIN + join
SELECT user_id, play_date, track_id
FROM (
  SELECT p.user_id, p.play_date, p.track_id,
         ROW_NUMBER() OVER(PARTITION BY p.user_id ORDER BY p.play_date) AS rn
  FROM plays p
  JOIN subscriptions s
    ON p.user_id = s.user_id
   AND p.play_date BETWEEN s.start_date AND s.end_date
) t
WHERE rn = 1;

-- Q8. Monthly Top Listener per Artist
-- For each artist and month:
-- return the top user by total seconds played
-- Output:
-- artist_id | month | user_id | seconds
WITH monthly AS (
  SELECT t.artist_id,
         p.user_id,
         DATE_TRUNC('month', p.play_date) AS month,
         SUM(p.seconds_played) AS total_sec
  FROM plays p
  JOIN tracks t ON p.track_id = t.track_id
  GROUP BY t.artist_id, p.user_id, DATE_TRUNC('month', p.play_date)
),
ranked AS (
  SELECT *,
         DENSE_RANK() OVER(PARTITION BY artist_id, month ORDER BY total_sec DESC) AS rnk
  FROM monthly
)
SELECT artist_id, month, user_id, total_sec
FROM ranked
WHERE rnk = 1;

-- Q9. Increasing Monthly Usage
-- Return users whose:
-- total monthly seconds played is strictly increasing month-over-month
WITH monthly AS (
  SELECT user_id,
         DATE_TRUNC('month', play_date) AS month,
         SUM(seconds_played) AS total_sec
  FROM plays
  GROUP BY user_id, DATE_TRUNC('month', play_date)
),
lagged AS (
  SELECT *,
         LAG(total_sec) OVER(PARTITION BY user_id ORDER BY month) AS prev_sec
  FROM monthly
)
SELECT user_id
FROM lagged
GROUP BY user_id
HAVING SUM(CASE WHEN total_sec <= prev_sec THEN 1 ELSE 0 END) = 0;

-- 🔹 SET 4 — DATE + STREAK LOGIC
-- Q10. Exactly 3-Day Play Streak
-- Return users who had:
-- at least one streak of exactly 3 consecutive play days
-- but never 4+
-- ⚠️ Classic row_number date trick
WITH grp AS (
  SELECT user_id,
         play_date,
         play_date - ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY play_date) AS g
  FROM plays
),
cnt AS (
  SELECT user_id, g, COUNT(*) AS c
  FROM grp
  GROUP BY user_id, g
)
SELECT user_id
FROM cnt
GROUP BY user_id
HAVING SUM(CASE WHEN c = 3 THEN 1 ELSE 0 END) >= 1
   AND SUM(CASE WHEN c >= 4 THEN 1 ELSE 0 END) = 0;

-- Q11. Reactivated Users
-- A reactivated user:
-- had a play
-- then no plays for ≥ 30 days
-- then played again
-- Return those users.
WITH lagged AS (
  SELECT user_id, play_date,
         LAG(play_date) OVER(PARTITION BY user_id ORDER BY play_date) AS prev_date
  FROM plays
)
SELECT DISTINCT user_id
FROM lagged
WHERE play_date >= prev_date + INTERVAL '30 days';

-- 🔹 SET 5 — DATA ENGINEER QUALITY CHECKS
-- Q12. Overlapping Subscriptions With Plays
-- Return users who:
-- have overlapping subscriptions
-- and made a play during the overlap period
-- ⚠️ Self-join + date intersection
SELECT DISTINCT s1.user_id
FROM subscriptions s1
JOIN subscriptions s2
  ON s1.user_id = s2.user_id
 AND s1.subscription_id <> s2.subscription_id
 AND s1.start_date <= s2.end_date
 AND s2.start_date <= s1.end_date
JOIN plays p
  ON p.user_id = s1.user_id
 AND p.play_date BETWEEN GREATEST(s1.start_date, s2.start_date)
                     AND LEAST(s1.end_date, s2.end_date);

-- Q13. Duplicate Event Detection
-- Find users who:
-- have multiple identical events
-- (same user_id, event_type, event_date)
-- Return duplicates with count > 1.
SELECT user_id, event_type, event_date, COUNT(*) AS cnt
FROM events
GROUP BY user_id, event_type, event_date
HAVING COUNT(*) > 1;

-- Q14. Missing Dimension Check
-- Return plays where:
-- track_id does not exist in tracks table
-- (Data quality anti-join)
SELECT user_id, event_type, event_date, COUNT(*) AS cnt
FROM events
GROUP BY user_id, event_type, event_date
HAVING COUNT(*) > 1;
