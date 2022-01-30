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
    finaltable as -- convert dates into months
    (
    SELECT 
      customerid, 
      MONTH(orderdate) as MonthOrder, 
      MONTH(firstorder) as FirstMonth
    FROM basetable
    )
SELECT -- create cohort analysis
  FirstMonth, 
  count (distinct case when firstmonth=monthorder then customerid end) as M0, 
  count (distinct case when firstmonth+1=monthorder then customerid end) as M1,
  count (distinct case when firstmonth+2=monthorder then customerid end) as M2,
  count (distinct case when firstmonth+3=monthorder then customerid end) as M3
FROM finaltable
GROUP BY Firstmonth
ORDER BY Firstmonth
