
-- CASE STUDY 1: JOB DATA

-- 1. What is the average distinct number of jobs reviewed per hour in November 2020?
SELECT ROUND(SUM(distinct_jobs_per_hour)/COUNT(DISTINCT hour)) AS avg_distinct_jobs_reviewed_per_hour
FROM (
    SELECT HOUR(timestamp) AS hour, COUNT(DISTINCT job_id) AS distinct_jobs_per_hour
    FROM job_data
    WHERE MONTH(timestamp) = 11 AND YEAR(timestamp) = 2020
    GROUP BY HOUR(timestamp)
) AS hourly_data;

-- 2. What is the 7-day rolling average of daily distinct jobs reviewed?
SELECT review_date,
       AVG(daily_jobs_reviewed) OVER (ORDER BY review_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_7_days
FROM (
    SELECT DATE(timestamp) AS review_date, COUNT(DISTINCT job_id) AS daily_jobs_reviewed
    FROM job_data
    GROUP BY DATE(timestamp)
) AS daily_data;

-- 3. What is the percentage share of each language in the job data?
SELECT language, 
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM job_data), 2) AS language_percentage
FROM job_data
GROUP BY language;

-- 4. Detect duplicate job entries (same job_id, timestamp, and user_id)
SELECT job_id, timestamp, user_id, COUNT(*) AS duplicate_count
FROM job_data
GROUP BY job_id, timestamp, user_id
HAVING COUNT(*) > 1;

-- CASE STUDY 2: USER ENGAGEMENT

-- 1. Weekly active user count (based on events table)
SELECT YEAR(event_time) AS year, WEEK(event_time) AS week, COUNT(DISTINCT user_id) AS weekly_active_users
FROM events
GROUP BY YEAR(event_time), WEEK(event_time)
ORDER BY year, week;

-- 2. Cumulative user growth
SELECT sign_up_date, 
       COUNT(user_id) AS users_signed_up,
       SUM(COUNT(user_id)) OVER (ORDER BY sign_up_date) AS cumulative_users
FROM users
GROUP BY sign_up_date;

-- 3. Weekly retention - how many users return each week after signup
SELECT u.user_id, u.sign_up_date, e.event_time,
       TIMESTAMPDIFF(WEEK, u.sign_up_date, e.event_time) AS weeks_since_signup
FROM users u
JOIN events e ON u.user_id = e.user_id
WHERE TIMESTAMPDIFF(WEEK, u.sign_up_date, e.event_time) BETWEEN 1 AND 3;

-- 4. Email engagement: Open & Click rates
SELECT campaign_id,
       ROUND(SUM(CASE WHEN action = 'open' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS open_rate,
       ROUND(SUM(CASE WHEN action = 'click' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS click_rate
FROM email_events
GROUP BY campaign_id;

-- 5. Weekly device engagement breakdown
SELECT WEEK(event_time) AS week,
       device_type,
       COUNT(DISTINCT user_id) AS users_by_device
FROM events
GROUP BY WEEK(event_time), device_type
ORDER BY week, device_type;
