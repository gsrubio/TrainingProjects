-- Project created using SQL Server functions; database from W3Schools (https://www.w3schools.com/sql/trysqlserver.asp?filename=trysql_func_sqlserver_month)
-- Objective: create Cohort Analysis using the Orders table (dates from aug 96 to nov 96)

With customerorders as -- create table with customer ID and date of each order 
    (
    SELECT 
      customerid, 
      orderdate
    FROM orders
    WHERE orderdate between '1996-08-01' and '1996-11-30'
    GROUP BY customerid, orderdate
    ),
    firstorders as -- create table with customer ID and date of first purchase 
    (
    SELECT 
      customerid, 
      MIN(orderdate) as FirstOrder
    FROM orders
    WHERE orderdate between '1996-08-01' and '1996-11-30'
    GROUP BY customerid
    ),
    basetable as -- join both tables
    (
    SELECT 
      a.customerid, 
      orderdate, 
      FirstOrder
    FROM customerorders a
    LEFT JOIN firstorders b
    ON a.customerid = b.customerid
    ),
	difftable as -- convert all dats into month; calculate difference between first order month and order month
	(
	SELECT 
		customerid, 
		MONTH(orderdate) as MonthOrder, 
		MONTH(firstorder) as FirstMonth,
	  MONTH(orderdate)-Month(firstorder) as MonthDiff
	FROM basetable
	),
	finaltable as -- for each month and month diff count distinct customers
	(
	SELECT 
	    FirstMonth,
	    MonthDiff,
	    COUNT(distinct customerid) as CountCustomers
	FROM difftable
	GROUP BY FirstMonth, MonthDiff
	)
SELECT -- create cohort analysis using Pivot function
	FirstMonth,
    [0] as M0,
    [1] as M1,
    [2] as M2,
    [3] as M3
FROM finaltable
PIVOT 
	(
    SUM(CountCustomers)
    FOR MonthDiff IN ([0],[1],[2],[3])
    ) as pivottable
ORDER BY 1
