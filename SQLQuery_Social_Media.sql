select * from content;
Select * From locations;
Select * From reaction_types;
Select * From reactions
Select * From sessions
Select * From user_profiles
Select * From users
---------------------------------------
#Age analysis

WITH age_individual AS (
    SELECT
        age,
        COUNT(age) AS num_of_users
    FROM user_profiles
    GROUP BY age
)
Select
    Case
	   when age between 0 and 25 then 'Gen Z'
	   when age between 26 and 41 then 'Millennials'
	   when age between 42 and 44 then 'Gen X'
    End as generation,
	SUM(num_of_users) as total_user
From age_individual
group by Case
	   when age between 0 and 25 then 'Gen Z'
	   when age between 26 and 41 then 'Millennials'
	   when age between 42 and 44 then 'Gen X'
    End

-------------------------------------------------------------

WITH age_individual AS (
    SELECT
        age,
        COUNT(age) AS num_of_users
    FROM user_profiles
    GROUP BY age
)
SELECT
    CASE 
        WHEN age <= 1 THEN 'Infant' 
        WHEN age BETWEEN 2 AND 4 THEN 'Toddler'
        WHEN age BETWEEN 5 AND 12 THEN 'Children'
        WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
        WHEN age BETWEEN 20 AND 39 THEN 'Young Adult'
        WHEN age >= 40 THEN 'Middle Age Adult'
    END AS age_groups,
    CASE 
        WHEN age <= 1 THEN '0 - 1' 
        WHEN age BETWEEN 2 AND 4 THEN '2 - 4'
        WHEN age BETWEEN 5 AND 12 THEN '5 - 12'
        WHEN age BETWEEN 13 AND 19 THEN '13 - 19'
        WHEN age BETWEEN 20 AND 39 THEN '20 - 39'
        WHEN age >= 40 THEN '40 & over'
    END AS age_range,
    SUM(num_of_users) AS user_count
FROM age_individual
GROUP BY CASE 
        WHEN age <= 1 THEN 'Infant' 
        WHEN age BETWEEN 2 AND 4 THEN 'Toddler'
        WHEN age BETWEEN 5 AND 12 THEN 'Children'
        WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
        WHEN age BETWEEN 20 AND 39 THEN 'Young Adult'
        WHEN age >= 40 THEN 'Middle Age Adult'
    END, 
	case 
	    WHEN age <= 1 THEN '0 - 1' 
        WHEN age BETWEEN 2 AND 4 THEN '2 - 4'
        WHEN age BETWEEN 5 AND 12 THEN '5 - 12'
        WHEN age BETWEEN 13 AND 19 THEN '13 - 19'
        WHEN age BETWEEN 20 AND 39 THEN '20 - 39'
        WHEN age >= 40 THEN '40 & over'
    END

-----------------------------------------

WITH twnty_to_39s AS (
    SELECT * 
    FROM user_profiles
    WHERE age BETWEEN 20 AND 39
),
twnty_to_39s_activity_time AS (
    SELECT 
        r.Datetime, 
        r.Content_ID, 
        t_t_39s.User_ID
    FROM reactions r
    JOIN twnty_to_39s t_t_39s
        ON t_t_39s.User_ID = r.User_ID
    )
SELECT 
    DATEPART(HOUR, Datetime) AS hr,
    COUNT(USER_ID) AS num_of_users
FROM twnty_to_39s_activity_time
GROUP BY DATEPART(HOUR, Datetime)
ORDER BY hr;

------------------------------------------

-- Create temporary table for 20-39 year olds
with  twnty_to_39s AS
(SELECT * 
FROM user_profiles
WHERE age BETWEEN 20 AND 39),

twnty_to_39s_activity_time AS(
SELECT  
    r.Datetime, 
    r.Content_ID, 
    t_t_39s.User_ID
FROM reactions r
    JOIN twnty_to_39s t_t_39s
        ON t_t_39s.User_ID = r.User_ID)


-- Analyze activity by day of the week for 20-39 year olds
SELECT
    CASE
        WHEN DATEPART(WEEKDAY, Datetime) = 1 THEN 'Sun'
        WHEN DATEPART(WEEKDAY, Datetime) = 2 THEN 'Mon'
        WHEN DATEPART(WEEKDAY, Datetime) = 3 THEN 'Tue'
        WHEN DATEPART(WEEKDAY, Datetime) = 4 THEN 'Wed'
        WHEN DATEPART(WEEKDAY, Datetime) = 5 THEN 'Thu'
        WHEN DATEPART(WEEKDAY, Datetime) = 6 THEN 'Fri'
        WHEN DATEPART(WEEKDAY, Datetime) = 7 THEN 'Sat'
    END AS day_name,
    COUNT(User_ID) AS num_of_users
FROM twnty_to_39s_activity_time
GROUP BY DATEPART(WEEKDAY, Datetime)
ORDER BY DATEPART(WEEKDAY, Datetime)

---------------------------------------
# Category analysis

Select Category,
count(Category) as total_count
From content
Group by Category
order by total_count desc

----------------------------------------

SELECT 
	content_type,
    COUNT(User_ID) AS engagement_count
FROM (
SELECT 
	r.Content_ID, c.Type AS content_type,
    r.User_ID, r.Type as reaction_type
FROM content c
	LEFT JOIN reactions r
		ON r.Content_ID = c.Content_ID ) agg
GROUP BY content_type

----------------------------------------

SELECT
    YEAR(r.Datetime) AS yr,
    MONTH(r.Datetime) AS mo,
    COUNT(c.Content_ID) AS content_count
FROM reactions r
    LEFT JOIN content c
        ON c.Content_ID = r.Content_ID
GROUP BY YEAR(r.Datetime), MONTH(r.Datetime)
ORDER BY yr, mo;

-----------------------------------------
-- Total popularity score for each category
SELECT
	Category,
    SUM(Score) AS total_score
FROM reactions r
	LEFT JOIN content c
		ON c.content_id = r.content_id
	LEFT JOIN reaction_types rt
		ON rt.type = r.Type
GROUP BY Category
order by total_score desc

-----------------------------------
#Reaction analysis
-- Top 5 reactions
SELECT 
    TOP 5 Type,
    COUNT(Type) AS total_reactions
FROM reactions
GROUP BY Type
ORDER BY total_reactions DESC;

-------------------------------------
select * from content;
Select * From locations;
Select * From reaction_types;
Select * From reactions
select * from content;

-- Reactions and Scores for the "animals" category
Select r.Type,
COUNT(r.Type) as total_reaction,
SUM(rt.Score) as total_score
From reactions r
left join content c on r.Content_ID=c.Content_ID
left join reaction_types rt on rt.Type=r.Type
where c.Category='Animals'
group by r.Type
order by total_score desc

------------------------------------------------------
Select r.Type,
COUNT(r.Type) as total_reaction,
SUM(rt.Score) as total_score
From reactions r
left join content c on r.Content_ID=c.Content_ID
left join reaction_types rt on rt.Type=r.Type
where c.Category='Science'
group by r.Type
order by total_score desc
---------------------------------------------------
Select r.Type,
COUNT(r.Type) as total_reaction,
SUM(rt.Score) as total_score
From reactions r
left join content c on r.Content_ID=c.Content_ID
left join reaction_types rt on rt.Type=r.Type
where c.Category='healthy eating'
group by r.Type
order by total_score desc
-------------------------------------------------
Select r.Type,
COUNT(r.Type) as total_reaction,
SUM(rt.Score) as total_score
From reactions r
left join content c on r.Content_ID=c.Content_ID
left join reaction_types rt on rt.Type=r.Type
where c.Category='food'
group by r.Type
order by total_score desc

----------------------------------------------------------
#Content analysis
-- Find the number of posts made based on each content type
SELECT 
    type,
    COUNT(type) AS total_count
FROM content
GROUP BY type
ORDER BY total_count DESC;		
------------------------------------------
-- Most popular content type by engagement
SELECT 
    content_type,
    COUNT(Type) AS engagement_count
FROM (
    SELECT 
        r.content_id, c.type AS content_type,
        r.user_id, r.Type
    FROM content c
    LEFT JOIN reactions r
        ON r.content_id = c.content_id
) agg
GROUP BY content_type
ORDER BY engagement_count DESC;

#Sentiment analysis
with cte as 
(SELECT 
    r.Datetime,
    r.content_id, c.category, 
    r.user_id, r.Type, rt.sentiment, rt.score
FROM reactions r
	LEFT JOIN reaction_types rt
		ON rt.Type = r.Type
	LEFT JOIN content c		
		ON c.content_id = r.content_id)

Select Category,
Sentiment,
count(Sentiment) as sentiment_count
From cte
group by Category,Sentiment
order by  sentiment_count desc