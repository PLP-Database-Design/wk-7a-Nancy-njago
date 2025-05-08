-- Step 1: Create the database
CREATE DATABASE ProductDB;

-- Step 2: Use the newly created database
USE ProductDB;

-- Step 3: Create the original ProductDetail table
CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

-- Step 4: Insert sample data into ProductDetail
INSERT INTO ProductDetail (OrderID, CustomerName, Products)
VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Step 5: Create a helper numbers table (used to split comma-separated product lists)
CREATE TABLE numbers (n INT);

-- Step 6: Populate the numbers table with values 1 to 5
-- Add more rows if any order contains more than 5 products
INSERT INTO numbers (n)
VALUES (1), (2), (3), (4), (5);

-- Step 7: Create a temporary view or CTE-like structure to hold 1NF result
-- This is needed to build normalized tables
CREATE TEMPORARY TABLE FirstNF AS
SELECT 
    pd.OrderID,
    pd.CustomerName,
    TRIM(SUBSTRING_INDEX(
        SUBSTRING_INDEX(pd.Products, ',', n.n), 
        ',', -1)) AS Product
FROM 
    ProductDetail pd
JOIN 
    numbers n ON 
    CHAR_LENGTH(pd.Products) - CHAR_LENGTH(REPLACE(pd.Products, ',', '')) >= n.n - 1
ORDER BY 
    pd.OrderID;

-- Step 8: Create the Orders table for order-level data (2NF)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Step 9: Populate the Orders table with distinct order info
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM FirstNF;

-- Step 10: Create the OrderItems table for product-level data (2NF)
CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(100),
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Step 11: Populate the OrderItems table with normalized data
INSERT INTO OrderItems (OrderID, Product)
SELECT OrderID, Product
FROM FirstNF;

-- Step 12 (Optional): Display results
-- Show Orders
SELECT * FROM Orders;

-- Show OrderItems
SELECT * FROM OrderItems;


