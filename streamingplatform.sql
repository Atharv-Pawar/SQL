/*
🎧 SQL INTERVIEW SET — STREAMING PLATFORM DOMAIN
📊 Tables
users(user_id, user_name, country)
artists(artist_id, artist_name)
tracks(track_id, artist_id, genre, duration_sec)
listens(user_id, track_id, listen_date)
subscriptions(user_id, start_date, end_date)
*/

--🔹 SET 1 — JOIN LOGIC (Interview Traps)
-- Q1. ⚠️ LEFT JOIN Filter Trap
-- 👉 Return all users
-- 👉 Show artist_name only if the user listened to tracks of genre = 'Rock'
-- 👉 Users with no listens must still appear
SELECT u.user_id, u.user_name, a.artist_name
FROM users u 
LEFT JOIN listens l 
  ON u.user_id = l.user_id 
LEFT JOIN tracks t 
  ON l.track_id = t.track_id
    AND t.genre = 'Rock'
LEFT JOIN artists a 
  ON t.artist_id = a.artist_id;
	

-- Q2. Anti-Join (Must Know)
-- 👉 Return users who never listened to any track
-- ⚠️ Use JOIN
-- ⚠️ No NOT IN / NOT EXISTS
SELECT u.user_id, u.user_name
FROM users u
LEFT JOIN listens l
  ON u.user_id = l.user_id
WHERE l.track_id IS NULL;

-- Q3. Multi-Join Accuracy
-- 👉 Return:
-- user_name | artist_name | total_listens
-- 👉 Count listens per user per artist
SELECT u.user_name, a.artist_name, COUNT(*) AS total_listens
FROM users u
JOIN listens l ON u.user_id = l.user_id
JOIN tracks t ON l.track_id = t.track_id
JOIN artists a ON t.artist_id = a.artist_id
GROUP BY u.user_name, a.artist_name;


-- 🔹 SET 2 — JOIN + AGGREGATION (Business Logic)
-- Q4.
-- 👉 Return artists who have more than 3 unique listeners
SELECT a.artist_id, a.artist_name 
FROM artist a 
JOIN tracks t ON a.artist_id = t.artist_id 
JOIN listen l ON t.track_id = l.track_id
GROUP BY a.artist_id, a.artist_name
HAVING COUNT(DISTINCT l.user_id) > 3;

-- Q5. ⚠️ Interview Favorite
-- 👉 Return users whose average track duration listened
-- 👉 is greater than overall average track duration
-- ⚠️ Window function required
-- ⚠️ No GROUP BY in outer query
SELECT DISTINCT user_id, user_name
FROM (
  SELECT u.user_id, u.user_name,
         AVG(t.duration_sec) OVER(PARTITION BY u.user_id) AS user_avg,
         AVG(t.duration_sec) OVER() AS overall_avg
  FROM users u
  JOIN listens l ON u.user_id = l.user_id
  JOIN tracks t ON l.track_id = t.track_id
) x
WHERE user_avg > overall_avg;


-- 🔹 SET 3 — WINDOW FUNCTIONS (Core)
-- Q6. Ranking Logic
-- 👉 For each genre, return the longest track
-- ⚠️ Handle ties correctly
-- ⚠️ Window function only
SELECT genre, track_id, duration_sec
FROM (
  SELECT genre, track_id, duration_sec,
         RANK() OVER(PARTITION BY genre ORDER BY duration_sec DESC) AS rnk
  FROM tracks
) t
WHERE rnk = 1;


-- Q7. Comparison Logic
-- 👉 Return tracks whose duration is less than genre maximum
-- ⚠️ No subquery in WHERE
SELECT track_id
FROM (
  SELECT track_id, genre, duration_sec,
         MAX(duration_sec) OVER(PARTITION BY genre) AS max_dur
  FROM tracks
) t
WHERE duration_sec < max_dur;


-- Q8. Consecutive Days Logic ⚠️
-- 👉 Return users who listened to tracks on at least 4 consecutive days
-- 💡 Hint: date - row_number() pattern
SELECT DISTINCT user_id, user_name 
FROM (
	SELECT u.user_id, u.user_name,
	  (l.listen_date - ROW_NUMBER() OVER(PARTITION BY l.user_id ORDER BY l.listen_date)) AS gaps 
	FROM users u 
	JOIN listens l ON u.user_id = l.user_id 
) t 
GROUP BY user_id, user_name, gaps 
HAVING COUNT(*) >= 4;

-- 🔹 SET 4 — DATE + WINDOW (Logic Heavy)
-- Q9.
-- 👉 For each user, return:
-- user_id | listen_date | daily_listens | running_total_listens
-- 👉 Running total ordered by listen_date
SELECT user_id, listen_date, daily_listens,
       SUM(daily_listens) OVER(PARTITION BY user_id ORDER BY listen_date) AS running_total
FROM (
  SELECT user_id, listen_date, COUNT(*) AS daily_listens
  FROM listens
  GROUP BY user_id, listen_date
) t;


-- Q10. ⚠️ Subscription Trap
-- 👉 Return users who were active yesterday but NOT active today
-- 📌 Active = listen exists AND subscription valid on that day
SELECT DISTINCT u.user_id, u.user_name
FROM users u
JOIN listens l
  ON u.user_id = l.user_id
JOIN subscriptions s
  ON u.user_id = s.user_id
WHERE l.listen_date = CURRENT_DATE - INTERVAL '1 day'
  AND CURRENT_DATE NOT BETWEEN s.start_date AND s.end_date;


-- 🔹 SET 5 — ADVANCED INTERVIEW QUESTIONS 💀
-- Q11.
-- 👉 Return artists whose latest track duration
-- 👉 is greater than their first track duration
-- ⚠️ Window functions required
-- ⚠️ No GROUP BY in outer query
SELECT DISTINCT artist_id, artist_name
FROM (
  SELECT a.artist_id, a.artist_name,
         FIRST_VALUE(t.duration_sec)
           OVER(PARTITION BY a.artist_id ORDER BY t.release_date) AS first_dur,
         FIRST_VALUE(t.duration_sec)
           OVER(PARTITION BY a.artist_id ORDER BY t.release_date DESC) AS last_dur
  FROM artists a
  JOIN tracks t ON a.artist_id = t.artist_id
) x
WHERE last_dur > first_dur;

	  

-- Q12. FINAL BOSS 🔥
-- 👉 Return users who:
-- listened on exactly 3 consecutive days
-- and no other days
-- ⚠️ Window functions only
-- ⚠️ No GROUP BY in outer query
SELECT user_id
FROM (
  SELECT user_id,
         listen_date - ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY listen_date) AS grp
  FROM listens
) t
GROUP BY user_id
HAVING COUNT(DISTINCT grp) = 1
   AND COUNT(*) = 3;

/*
🧠 Interviewer Expectations
Correct ON vs WHERE usage
Proper window partitioning
No accidental row loss
Exact interpretation of words like:
--exactly
--at least
--never
--only
*/
