## sum of totalprice by month
Select DATE_TRUNC('month', InvoiceDate), ROUND(SUM(TotalPrice),2) From online_retail
WHERE is_cancelled = FALSE
GROUP BY DATE_TRUNC('month', InvoiceDate)
ORDER BY DATE_TRUNC('month', InvoiceDate) ASC ;

# totalprice top 10
SELECT StockCode, MAX(Description) AS description, SUM(Quantity) AS Quantity, SUM(TotalPrice) AS TotalPrice FROM online_retail
WHERE is_cancelled = False
GROUP BY StockCode
ORDER BY SUM(TotalPrice) DESC
LIMIT 10;