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

-- Q2. Anti-Join (Must Know)
-- 👉 Return users who never listened to any track
-- ⚠️ Use JOIN
-- ⚠️ No NOT IN / NOT EXISTS

-- Q3. Multi-Join Accuracy
-- 👉 Return:
-- user_name | artist_name | total_listens
-- 👉 Count listens per user per artist

-- 🔹 SET 2 — JOIN + AGGREGATION (Business Logic)
-- Q4.
-- 👉 Return artists who have more than 3 unique listeners

-- Q5. ⚠️ Interview Favorite
-- 👉 Return users whose average track duration listened
-- 👉 is greater than overall average track duration
-- ⚠️ Window function required
-- ⚠️ No GROUP BY in outer query

-- 🔹 SET 3 — WINDOW FUNCTIONS (Core)
-- Q6. Ranking Logic
-- 👉 For each genre, return the longest track
-- ⚠️ Handle ties correctly
-- ⚠️ Window function only

-- Q7. Comparison Logic
-- 👉 Return tracks whose duration is less than genre maximum
-- ⚠️ No subquery in WHERE

-- Q8. Consecutive Days Logic ⚠️
-- 👉 Return users who listened to tracks on at least 4 consecutive days
-- 💡 Hint: date - row_number() pattern

-- 🔹 SET 4 — DATE + WINDOW (Logic Heavy)
-- Q9.
-- 👉 For each user, return:
-- user_id | listen_date | daily_listens | running_total_listens
-- 👉 Running total ordered by listen_date

-- Q10. ⚠️ Subscription Trap
-- 👉 Return users who were active yesterday but NOT active today
-- 📌 Active = listen exists AND subscription valid on that day

-- 🔹 SET 5 — ADVANCED INTERVIEW QUESTIONS 💀
-- Q11.
-- 👉 Return artists whose latest track duration
-- 👉 is greater than their first track duration
-- ⚠️ Window functions required
-- ⚠️ No GROUP BY in outer query

-- Q12. FINAL BOSS 🔥
-- 👉 Return users who:
-- listened on exactly 3 consecutive days
-- and no other days
-- ⚠️ Window functions only
-- ⚠️ No GROUP BY in outer query

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
