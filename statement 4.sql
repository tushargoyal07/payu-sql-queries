create table credit(
user_id text,
activity_date date, 
activity_week date
);
insert into credit values
('U1',	TO_DATE('27-12-2022', 'DD/MM/YYYY'), TO_DATE('01-01-2023', 'DD/MM/YYYY')),
('U2',	TO_DATE('05-01-2023', 'DD/MM/YYYY'), TO_DATE('08-01-2023', 'DD/MM/YYYY')),
('U2',	TO_DATE('10-01-2023', 'DD/MM/YYYY'), TO_DATE('15-01-2023', 'DD/MM/YYYY')),
('U1',	TO_DATE('08-01-2023', 'DD/MM/YYYY'), TO_DATE('08-01-2023', 'DD/MM/YYYY')),
('U1',	TO_DATE('09-01-2023', 'DD/MM/YYYY'), TO_DATE('15-01-2023', 'DD/MM/YYYY')),
('U3',	TO_DATE('07-02-2023', 'DD/MM/YYYY'), TO_DATE('12-02-2023', 'DD/MM/YYYY')),
('U4',	TO_DATE('04-01-2023', 'DD/MM/YYYY'), TO_DATE('08-01-2023', 'DD/MM/YYYY')),
('U3',	TO_DATE('19-02-2023', 'DD/MM/YYYY'), TO_DATE('19-02-2023', 'DD/MM/YYYY')),
('U4',	TO_DATE('20-01-2023', 'DD/MM/YYYY'), TO_DATE('22-01-2023', 'DD/MM/YYYY')),
('U3',	TO_DATE('01-03-2023', 'DD/MM/YYYY'), TO_DATE('05-03-2023', 'DD/MM/YYYY')),
('U3',	TO_DATE('05-03-2023', 'DD/MM/YYYY'), TO_DATE('05-03-2023', 'DD/MM/YYYY')),
('U2',	TO_DATE('21-01-2023', 'DD/MM/YYYY'), TO_DATE('22-01-2023', 'DD/MM/YYYY')),
('U1',	TO_DATE('30-01-2023', 'DD/MM/YYYY'), TO_DATE('05-02-2023', 'DD/MM/YYYY')),
('U2',	TO_DATE('22-01-2023', 'DD/MM/YYYY'), TO_DATE('22-01-2023', 'DD/MM/YYYY')),
('U1',	TO_DATE('29-12-2022', 'DD/MM/YYYY'), TO_DATE('01-01-2023', 'DD/MM/YYYY')),
('U3',	TO_DATE('16-03-2023', 'DD/MM/YYYY'), TO_DATE('19-03-2023', 'DD/MM/YYYY')),
('U1',	TO_DATE('19-01-2023', 'DD/MM/YYYY'), TO_DATE('22-01-2023', 'DD/MM/YYYY'));
select * from credit;

WITH Streaks AS (
    -- Step 1: Remove duplicate logins in the same week (count only one login per week)
    SELECT DISTINCT user_id, activity_date, activity_week
    FROM credit
),
ConsecutiveWeeks AS (
    -- Step 2: Assign consecutive week groups for each user
    SELECT 
        user_id,
        activity_date,
        activity_week,
        -- Track consecutive weeks: streak_group will reset when weeks are not consecutive
        DENSE_RANK() OVER (PARTITION BY user_id ORDER BY activity_week) - 
        RANK() OVER (PARTITION BY user_id ORDER BY activity_week) AS streak_group
    FROM Streaks
),
WeekStreaks AS (
    -- Step 3: Count the streak number for each user within each consecutive week group
    SELECT
        user_id,
        activity_date,
        activity_week,
        streak_group,
        ROW_NUMBER() OVER (PARTITION BY user_id, streak_group ORDER BY activity_week) AS streak_number
    FROM ConsecutiveWeeks
),
Credited AS (
    -- Step 4: Mark users as credited when they complete the 4th week of their streak
    SELECT
        user_id,
        activity_date,
        activity_week,
        streak_number,
        CASE 
            WHEN streak_number = 4 THEN 1
            ELSE 0
        END AS credited
    FROM WeekStreaks
)
-- Final output: Users' progress up to the 4th week
SELECT
    user_id,
    activity_date,
    activity_week,
    streak_number,
    credited
FROM Credited
WHERE streak_number <= 4
ORDER BY user_id, activity_week;
