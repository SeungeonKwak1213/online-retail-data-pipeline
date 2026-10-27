## sum of totalprice by month
Select DATE_TRUNC('month', InvoiceDate), ROUND(SUM(TotalPrice),2) From online_retail
WHERE is_cancelled = FALSE
GROUP BY DATE_TRUNC('month', InvoiceDate)
ORDER BY DATE_TRUNC('month', InvoiceDate) ASC ;

# totalprice top 10
SELECT StockCode, MAX(Description) AS description, SUM(Quantity) AS Quantity, ROUND(SUM(TotalPrice),2) AS TotalPrice FROM online_retail
WHERE is_cancelled = False
GROUP BY StockCode
ORDER BY SUM(TotalPrice) DESC
LIMIT 10;

# totalsale by country
SELECT Country, ROUND(SUM(TotalPrice),2) AS TotalPrice From online_retail
WHERE is_cancelled = False
GROUP BY Country
ORDER BY SUM(TotalPrice) DESC;

# cancelledRate
SELECT StockCode,
       MAX(description),
       COUNT(DISTINCT invoiceNo) AS totalOrder,
	   COUNT(DISTINCT invoiceNo) FILTER (WHERE is_cancelled = True) AS cancelledOrder,
	   ROUND(100.0 * COUNT(DISTINCT invoiceNo) FILTER (WHERE is_cancelled = True)  / COUNT(DISTINCT invoiceNo), 2) AS cancelledRate
FROM online_retail
GROUP BY StockCode
HAVING COUNT(DISTINCT invoiceno) >= 100
ORDER BY cancelledRate DESC
Limit 10;