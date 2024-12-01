
CREATE table assign_db(date DATE, user_name TEXT, lifecycle_stage TEXT);

Insert into assign_db(date, user_name, lifecycle_stage)VALUES
   
    ('2022-06-10', 'user 1', 'LF_1'),
    ('2022-06-15', 'user 2', 'LF_1'),
    ('2022-06-21', 'user 2', 'LF_2'),
    ('2022-06-15', 'user 1', 'LF_2'),
    ('2022-06-30', 'user 6', 'LF_3'),
    ('2022-06-13', 'user 4', 'LF_1'),
    ('2022-06-18', 'user 5', 'LF_1'),
    ('2022-06-19', 'user 5', 'LF_2'),
    ('2022-06-30', 'user 2', 'LF_3'),
    ('2022-06-20', 'user 6', 'LF_1'),
    ('2022-06-22', 'user 6', 'LF_2'),
    ('2022-06-13', 'user 3', 'LF_1');
  
SELECT * FROM assign_db;

WITH RankedStages AS (
    SELECT
        user_name,
        lifecycle_stage,
        date AS stage_date,
        ROW_NUMBER() OVER (PARTITION BY user_name ORDER BY date DESC) AS stage_rank
    FROM
       assign_db
),
CurrentStage AS (
    SELECT
        user_name,
        lifecycle_stage AS current_lifecycle_stage,
        stage_date AS current_stage_date
    FROM
        RankedStages
    WHERE
        stage_rank = 1
),
StartStage AS (
    SELECT
        user_name,
        MIN(date) AS start_date
    FROM
        assign_db
    WHERE
        lifecycle_stage = 'LF_1'
    GROUP BY
        user_name
)
SELECT
    cs.user_name,
    cs.current_lifecycle_stage,
    cs.current_stage_date,
    COALESCE(cs.current_stage_date - ss.start_date, 0) AS duration_in_days
FROM
    CurrentStage cs
    JOIN StartStage ss ON cs.user_name = ss.user_name;
