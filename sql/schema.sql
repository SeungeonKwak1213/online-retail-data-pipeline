CREATE TABLE online_retail(
    InvoiceNo VARCHAR(50) NOT NULL,
    StockCode VARCHAR(50) NOT NULL,
    Description VARCHAR(500),
    Quantity INT NOT NULL, 
    InvoiceDate TIMESTAMP NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    CustomerID INT,
    Country VARCHAR(50),
    is_cancelled BOOLEAN NOT NULL,
    TotalPrice DECIMAL(12,2) NOT NULL,
    VIP_Customer BOOLEAN NOT NULL
);