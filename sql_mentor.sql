-- SQL Mini Project 10/10
-- SQL Mentor User Performance

-- DROP TABLE user_submissions; 

CREATE TABLE user_submissions (
    id SERIAL PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    username VARCHAR(50)
);

-- View the tables
SELECT * FROM user_submissions;

-- Please note for each questions return current stats for the users
-- user_name, total points earned, correct submissions, incorrect submissions no

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
SELECT DISTINCT username, 
	   COUNT(*) AS total_submissions, 
	   sum(points) AS points_earned 
	   FROM user_submissions
GROUP BY 1;


-- Q.2 Calculate the daily average points for each user.
-- extract (day from submitted_at)
SELECT username,
	   TO_CHAR(submitted_at, 'DD-MM') AS day,
	   ROUND(AVG(points), 2) AS avg_points
	   FROM user_submissions
GROUP BY 1,2
ORDER BY username;



-- Q.3 Find the top 3 users with the most positive (+ points) submissions for each day. 
-- to use window functions, 'WITH' and DENSE_RANK
WITH daily_submissions
AS
(SELECT TO_CHAR(submitted_at, 'DD-MM') as daily,
		username,
		SUM(CASE 
			WHEN points > 0 THEN 1 ELSE 0
		END) as correct_submissions
	FROM user_submissions
	GROUP BY 1, 2
),
users_rank
as
(SELECT 
	daily,
	username,
	correct_submissions,
	DENSE_RANK() OVER(PARTITION BY daily ORDER BY correct_submissions DESC) as rank
FROM daily_submissions
)

SELECT 
	daily,
	username,
	correct_submissions
FROM users_rank
WHERE rank <= 3;


-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
SELECT username,
	   SUM(CASE 
	   			WHEN points < 0 THEN 1 ELSE 0
		END) AS incorrect_submission
	   FROM user_submissions
GROUP BY 1
ORDER BY incorrect_submission DESC
LIMIT 5;

-- Q.4a Find the top 5 users with the highest number of incorrect & correct submissions & points earned.
SELECT username, 
	   SUM(CASE
	   		   WHEN points < 0 THEN 1 ELSE 0
				  END) AS incorrect_submissions,
		SUM(CASE
				WHEN points > 0 THEN 1 ELSE 0
					END) AS correct_submissions,
		SUM(points) AS points_earned_correct_submissions FROM user_submissions
		GROUP BY 1
		ORDER BY points_earned_correct_submissions DESC;



-- Q.5 Find the top 10 performers for each week. to use Sub-queries & window functions: RANK, DENSE_RANK
-- using function: ROW_NUMBER(), have to write equations in full, does not have any 'Gap' in its ranking
SELECT * FROM

(SELECT EXTRACT(WEEK FROM submitted_at) AS week_no,
	   username,
	   SUM(points) AS total_points_earn,
	   ROW_NUMBER() OVER(PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) as RN
	   FROM user_submissions
	   GROUP BY 1,2
	   ORDER BY week_no)
	   WHERE RN <= 10;

	   
-- using function: RANK(), return 22 queries, 
--RANK() produces a 'Gap' in its ranking within the same week
SELECT * FROM

(SELECT EXTRACT(WEEK FROM submitted_at) AS week_no,
	    username,
		SUM(points) AS total_points_earned,
		RANK() OVER(PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) as rank
		FROM user_submissions
GROUP BY 1,2
ORDER BY week_no)
WHERE rank <= 10;


-- using function: DENSE_RANK(), returns 25 queries, it does not leave any 'Gap' in its ranking
SELECT * FROM 

(SELECT EXTRACT(WEEK FROM submitted_at) AS week_no,
       username, 
	   SUM(points) AS total_points_earned,
	   DENSE_RANK() OVER(PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) AS DR
	   FROM user_submissions
	   GROUP BY 1, 2
	   ORDER BY week_no)
WHERE DR <= 10;



		
		





