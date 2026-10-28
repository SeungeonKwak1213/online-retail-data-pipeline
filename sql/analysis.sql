-- sum of totalprice by month
Select DATE_TRUNC('month', InvoiceDate), ROUND(SUM(TotalPrice),2) From online_retail
GROUP BY DATE_TRUNC('month', InvoiceDate)
ORDER BY ROUND(SUM(TotalPrice),2) DESC ;

-- totalprice top 10
SELECT StockCode, MAX(Description) AS description, SUM(Quantity) AS total_Quantity, ROUND(SUM(TotalPrice),2) AS Total_Price FROM online_retail
WHERE StockCode NOT IN('DOT', 'M', 'POST', 'D', 'AMAZONFEE', 'CRUK', 'BANK CHARGES')
GROUP BY StockCode
ORDER BY SUM(TotalPrice) DESC
LIMIT 10;

-- totalsale by country
SELECT Country, ROUND(SUM(TotalPrice),2) AS TotalPrice From online_retail
GROUP BY Country
ORDER BY SUM(TotalPrice) DESC;

-- cancelledRate
SELECT StockCode,
       MAX(description),
       COUNT(DISTINCT invoiceNo) AS totalOrder,
	   COUNT(DISTINCT invoiceNo) FILTER (WHERE is_cancelled = True) AS cancelledOrder,
	   ROUND(100.0 * COUNT(DISTINCT invoiceNo) FILTER (WHERE is_cancelled = True)  / COUNT(DISTINCT invoiceNo), 2) AS cancelledRate
FROM online_retail
WHERE StockCode NOT IN ('DOT', 'M', 'POST', 'D', 'AMAZONFEE', 'CRUK', 'BANK CHARGES')
GROUP BY StockCode
HAVING COUNT(DISTINCT invoiceno) >= 100
ORDER BY cancelledRate DESC
Limit 10;

-- findVIPTotalprice
SELECT CustomerID, SUM(TotalPrice) AS VIP_TotalPrice FROM online_retail
WHERE VIP_Customer = True and is_cancelled = False
GROUP BY CustomerID
ORDER BY SUM(TotalPrice) DESC
LIMIT 10;