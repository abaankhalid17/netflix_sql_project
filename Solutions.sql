-- Netflix Project --
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id      VARCHAR(6),
    type         VARCHAR(10),
    title        VARCHAR(150),
    director     VARCHAR(208),
    casts        VARCHAR(1000),
    country      VARCHAR(150),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(15),
    listed_in    VARCHAR(100),
    description  VARCHAR(250)
);

SELECT * FROM netflix;

-- Chekcing imported data --
SELECT 
	COUNT(*) as total_content
FROM netflix;

SELECT 
	DISTINCT type
FROM netflix;

-- Extracting Business Insights --

-- Total number of movies vs TV shows --

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1

-- Finding the most common rating for movies and TV shows --

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- Listing all movies released in a specific year (e.g., 2020) --

SELECT * 
FROM netflix
WHERE release_year = 2020


-- Finding the top 5 countries with the most content on Netflix --

SELECT * 
FROM
(
	SELECT 
		-- country,
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5


--Identifying the longest movie --

SELECT 
	*
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC


-- Finding content added in the last 5 years --
SELECT
*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


-- Find all the movies/TV shows by director 'Christopher Nolan'! --

SELECT *
FROM
(

SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM 
netflix
)
WHERE 
	director_name = 'Christopher Nolan'



-- Listing all TV shows with more than 5 seasons --

SELECT *
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5


-- Counting the number of content items in each genre --

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1


-- Finding each year and the average numbers of content release by the United States on netflix and returning the Top 5 --

SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'United States')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'United States' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5


-- Listing all movies that are documentaries --

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'



-- Finding all content without a director --

SELECT * FROM netflix
WHERE director IS NULL


-- Find how many movies actor 'Ryan Reynolds' appeared in last 10 years --

SELECT * FROM netflix
WHERE 
	casts LIKE '%Ryan Reynolds%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- Finding the top 10 actors who have appeared in the highest number of movies produced in the United States --

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'United States'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- Categorizing the content based on the presence of the keywords 'kill' and 'violence' in  
-- the description field. Then labeling the content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Finally, counting how many items fall into each category.


SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2




-- End of Report --
