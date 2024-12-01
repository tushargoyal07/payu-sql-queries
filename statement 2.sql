create table Sales(id int, SalesDate date, SaleAmount float);

insert into Sales(id, SalesDate, SaleAmount) Values
(1, '2021-06-04', 23000),
(2,	'2021-06-05',	13000),
(3,	'2021-06-05',	11000),
(4,	'2021-06-07',	25000),
(5,	'2021-06-08',	26000),
(6,	'2021-06-09',	24500),
(4,	'2021-06-07',	25000),
(5,	'2021-06-08',	26000),
(6,	'2021-06-09',	24500);


select * from Sales;

-- Remove duplicates based on 'id', keeping only the first occurrence per 'id'
WITH DistinctSales AS (
    SELECT DISTINCT ON (id) id, SalesDate, SaleAmount
    FROM Sales
    ORDER BY id, SalesDate -- Assumes you want to keep the first sales entry per 'id' ordered by 'SalesDate'
),

-- Calculate daily total sales
DailySales AS (
    SELECT
        SalesDate,
        SUM(SaleAmount) AS TotalSales
    FROM
        DistinctSales
    GROUP BY
        SalesDate
),


-- Compare total sales with the previous day's sales
SalesWithLag AS (
    SELECT
        SalesDate,
        TotalSales,
        LAG(TotalSales) OVER (ORDER BY SalesDate) AS PreviousDaySales
    FROM
        DailySales
)

-- Select days when sales were higher than the previous day
SELECT
    SalesDate,
    TotalSales
FROM
    SalesWithLag
WHERE
    TotalSales > PreviousDaySales;

