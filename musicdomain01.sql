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
-- 👉 Return all singers, album
-- 👉 Show only albums released after 2020
-- 👉 Singers without albums must still appear


-- Q2. Anti-Join (Very Common)
-- 👉 Return singers who never released any album
-- ⚠️ Use JOIN
-- ⚠️ No NOT IN

-- Q3. Multi-Join Logic
-- 👉 Return:
-- singer_name | album_name | song_name
-- 👉 Include songs only if they belong to an album

-- 🔹 SET 2 — JOIN + Aggregation (Business Logic)
-- Q4.
-- 👉 Return album_name and total number of songs
-- 👉 Only albums having more than 5 songs

-- Q5. ⚠️ Interview Favorite
-- 👉 Return singers whose average song duration is greater than
-- 👉 overall average song duration across all songs
-- ⚠️ Window function required
-- ⚠️ No GROUP BY in outer query

-- 🔹 SET 3 — WINDOW FUNCTIONS (Core)
-- Q6. Department-style Logic (Converted)
-- 👉 For each song return:
-- song_name | duration_seconds | album_max_duration | diff_from_album_max
-- ⚠️ No subqueries in WHERE

-- Q7. Ranking Logic (Interview Gold)
-- 👉 Return top 2 longest songs per album
-- 👉 Handle ties correctly

-- Q8. Consecutive Days Logic ⚠️
-- 👉 Return songs that were streamed on at least 3 consecutive days

-- 🔹 SET 4 — DATE + WINDOW (Logic Heavy)
-- Q9.
-- 👉 For each song, return:
-- song_name | stream_date | daily_streams | running_total_streams
-- 👉 Running total ordered by stream_date

-- Q10. ⚠️ Logic Test
-- 👉 Return singers who released multiple albums in the same year

-- 🔹 SET 5 — ADVANCED INTERVIEW QUESTIONS 💀
-- Q11.
-- 👉 Return singers whose latest album has more songs than their first album
-- ⚠️ Window functions required

-- Q12. Final Boss 🔥
-- 👉 Return singers who:
-- released albums in exactly 3 consecutive years
-- and no other years
-- ⚠️ Window functions
-- ⚠️ No GROUP BY in outer query
