create table Contact(
  id int,
  email text
);
Insert into Contact Values
(1,	'abc@xyz.com'),
(2,	'def@x.com'),
(3,	'hij@y.com'),
(4,	'jkl@dcom'),
(1,	'a@b.com'),
(6,	'b@d.com'),
(7,	'abc123');

select * from Contact;


WITH Duplicates AS (
    SELECT
        id,
        email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS rn
    FROM Contact
)
DELETE FROM Contact
WHERE id IN (
    SELECT id
    FROM Duplicates
    WHERE rn > 1
);
-- wrong emails

SELECT *
FROM Contact
WHERE email NOT LIKE '%@%' 
   OR email LIKE '%@%@%'  -- Multiple "@" symbols
   OR email NOT LIKE '%._%' -- Common email domain issues
   OR email LIKE '% %';    -- Spaces in the email

