/*
🎵 SQL INTERVIEW SET — MUSIC DOMAIN
📀 Tables Used
singers(singer_id, singer_name)
albums(album_id, singer_id, album_name, release_year)
songs(song_id, album_id, song_name, duration_seconds, release_date)
streams(song_id, stream_date, stream_count)
*/

-- 🔹 SET 1 — JOIN Logic (Interview Traps)
-- Q1. LEFT JOIN + Filter Trap ⚠️
-- 👉 Return all singers
-- 👉 Show only albums released after 2020
-- 👉 Singers without albums must still appear
SELECT s.singer_name, a.album_name 
FROM singers s 
LEFT JOIN album a 
ON s.singer_id = a.singer_id
  AND a.release_year > '2020';

-- Q2. Anti-Join (Very Common)
-- 👉 Return singers who never released any album
-- ⚠️ Use JOIN
-- ⚠️ No NOT IN
SELECT s.singer_name 
FROM singers s 
LEFT JOIN album a 
ON s.singer_id = a.singer_id
WHERE a.album_id IS NULL;

-- Q3. Multi-Join Logic
-- 👉 Return:
-- singer_name | album_name | song_name
-- 👉 Include songs only if they belong to an album
SELECT s.singer_name, a.album_name, ss.song_name 
FROM songs ss 
JOIN album a ON ss.album_id = a.album_id
JOIN singers s ON a.singer_id = s.singer_id;

-- 🔹 SET 2 — JOIN + Aggregation (Business Logic)
-- Q4.
-- 👉 Return album_name and total number of songs
-- 👉 Only albums having more than 5 songs
SELECT a.album_name, COUNT(*) AS total_songs 
FROM album a 
JOIN songs ss 
ON a.album_id = ss.album_id 
GROUP BY a.album_name 
HAVING COUNT(*) > 5;

-- Q5. ⚠️ Interview Favorite
-- 👉 Return singers whose average song duration is greater than
-- 👉 overall average song duration across all songs
-- ⚠️ Window function required
-- ⚠️ No GROUP BY in outer query
SELECT DISTINCT singer_name 
FROM ( 
	SELECT s.singer_name, m.song_id, m.song_name, m.duration_seconds,
	  AVG(duration_seconds) OVER(PARTITION BY s.singer_name) AS singer_avg_sd,
	  AVG(duration_seconds) OVER() AS overall_avg_sd
	FROM songs m 
	JOIN album a ON m.album_id = a.album_id 
	JOIN singers s ON a.singer_id = s.singer_id
) t 
WHERE singer_avg_sd > overall_avg_sd;	

-- 🔹 SET 3 — WINDOW FUNCTIONS (Core)
-- Q6. Department-style Logic (Converted)
-- 👉 For each song return:
-- song_name | duration_seconds | album_max_duration | diff_from_album_max
-- ⚠️ No subqueries in WHERE
SELECT song_name, duration_seconds, album_max_duration, diff_from_album_max
FROM (
	SELECT song_name, duration_seconds,
	  MAX(duration_seconds) OVER(PARTITION BY album_id) AS album_max_duration,
	  (MAX(duration_seconds) OVER(PARTITION BY album_id) - duration_seconds) AS diff_from_album_max
	FROM songs 
) t;

-- Q7. Ranking Logic (Interview Gold)
-- 👉 Return top 2 longest songs per album
-- 👉 Handle ties correctly
SELECT album_id, song_id, song_name
FROM (
	SELECT song_id, album_id, song_name, duration_seconds,
	  DENSE_RANK() OVER(PARTITION BY album_id ORDER BY duration_seconds DESC) AS rnk 
	FROM songs 
) t 
WHERE rnk <= 2;	

-- Q8. Consecutive Days Logic ⚠️
-- 👉 Return songs that were streamed on at least 3 consecutive days
SELECT song_id
FROM (
	SELECT song_id, stream_date,
	  (stream_date - ROW_NUMBER() OVER(PARTITION BY song_id ORDER BY stream_date) AS gaps
	FROM streams
) t 
GROUP BY song_id, gaps 
HAVING COUNT(*) >= 3;

-- 🔹 SET 4 — DATE + WINDOW (Logic Heavy)
-- Q9.
-- 👉 For each song, return:
-- song_name | stream_date | daily_streams | running_total_streams
-- 👉 Running total ordered by stream_date
SELECT song_name, stream_date, daily_streams, 
  SUM(daily_streams) 
    OVER(PARTITION BY song_name ORDER BY stream_date) AS running_total_streams
FROM (
	SELECT m.song_name, x.stream_date, 
	  SUM(x.stream_count) OVER(PARTITION BY m.song_name, x.stream_date) AS daily_streams
	FROM songs m 
	JOIN streams x ON m.song_id = x.song_id
) t;

-- Q10. ⚠️ Logic Test
-- 👉 Return singers who released multiple albums in the same year
SELECT DISTINCT singer_id, singer_name 
FROM (
	SELECT s.singer_id, s.singer_name, 
	  COUNT(a.album_id) OVER(PARTITION BY s.singer_id, a.release_year) AS albums_per_year 
	FROM singers s 
	JOIN album a ON s.singer_id = a.singer_id
) t	
WHERE albums_per_year > 1;

-- 🔹 SET 5 — ADVANCED INTERVIEW QUESTIONS 💀
-- Q11.
-- 👉 Return singers whose latest album has more songs than their first album
-- ⚠️ Window functions required
WITH album_song_counts AS (
   SELECT a.singer_id, a.release_year,
          COUNT(s.song_id) AS song_count
   FROM albums a
   JOIN songs s ON a.album_id = s.album_id
   GROUP BY a.singer_id, a.release_year
),
ranked AS (
   SELECT *,
      FIRST_VALUE(song_count) OVER (PARTITION BY singer_id ORDER BY release_year) AS first_album_songs,
      FIRST_VALUE(song_count) OVER (PARTITION BY singer_id ORDER BY release_year DESC) AS last_album_songs
   FROM album_song_counts
)
SELECT DISTINCT singer_id
FROM ranked
WHERE last_album_songs > first_album_songs;


-- LIMIT not allowed in window functions

-- Q12. Final Boss 🔥
-- 👉 Return singers who:
-- released albums in exactly 3 consecutive years
-- and no other years
-- ⚠️ Window functions
-- ⚠️ No GROUP BY in outer query
SELECT singer_id
FROM (
   SELECT singer_id,
          release_year - ROW_NUMBER() OVER (PARTITION BY singer_id ORDER BY release_year) AS grp
   FROM albums
) t
GROUP BY singer_id, grp
HAVING COUNT(*) = 3
   AND COUNT(*) = (
      SELECT COUNT(*)
      FROM albums a2
      WHERE a2.singer_id = t.singer_id
   );
