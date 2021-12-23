With tabela01 as
  (
  SELECT o.orderid, c.categoryname
  FROM orders o
  LEFT JOIN orderdetails od
    ON o.orderid=od.orderid
  LEFT JOIN products p
    ON od.productid = p.productid
  LEFT JOIN categories c
    ON p.categoryid = c.categoryid
  GROUP BY 1,2
  ),
  tabela02 as
  (
  SELECT 
    orderid,
    COUNT(DISTINCT CASE WHEN categoryname='Beverages' then orderid end) as Beverages,
    COUNT(DISTINCT CASE WHEN categoryname='Condiments' then orderid end) as Condiments,
    COUNT(DISTINCT CASE WHEN categoryname='Confections' then orderid end) as Confections,
    COUNT(DISTINCT CASE WHEN categoryname='Dairy Products' then orderid end) as Dairy_Products,
    COUNT(DISTINCT CASE WHEN categoryname='Grains/Cereals' then orderid end) as Grains_Cereals,
    COUNT(DISTINCT CASE WHEN categoryname='Meat/Poultry' then orderid end) as Meat_Poultry	,
    COUNT(DISTINCT CASE WHEN categoryname='Produce' then orderid end) as Produce,
    COUNT(DISTINCT CASE WHEN categoryname='Seafood' then orderid end) as Seafood
  FROM tabela01
  GROUP BY orderid
  ORDER BY orderid
  )
SELECT
  categoryname,
  SUM(Beverages),
  SUM(Condiments),
  SUM(Confections),
  SUM(Dairy_Products),
  SUM(Grains_Cereals),
  SUM(Meat_Poultry),
  SUM(Produce),
  SUM(Seafood)
FROM tabela01 t1
LEFT JOIN tabela02 t2
  ON t1.orderid=t2.orderid
GROUP BY categoryname
ORDER BY categoryname;
