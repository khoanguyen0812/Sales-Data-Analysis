-- Let's perform some analysis on the dataset we created.

CREATE DATABASE all_data_analysis; -- Create the database.
USE all_data_analysis; -- Use the database.


-- Loading the CSV file into MySQL Workbench.
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/all_data_complete_modified_1.csv'
INTO TABLE sales_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(OrderID, Product, QuantityOrdered, PriceEach, @OrderDate, @OrderTime, PurchaseAddress, Month, Sales, City, State, Hour, Minute)
SET OrderDate = STR_TO_DATE(@OrderDate, '%m/%d/%Y'),
    OrderTime = STR_TO_DATE(@OrderTime, '%h:%i:%s %p');

-- Checking to see if everything is in order.
SELECT *
FROM sales_data;

DESCRIBE sales_data;

/* Okay let's tackle the first question.

What is the most purchased item for each month?*/

WITH MonthlyProductSales AS (
    SELECT Month, Product, COUNT(QuantityOrdered) AS Total_Amt_Sold,
        ROW_NUMBER() OVER (PARTITION BY Month ORDER BY COUNT(QuantityOrdered) DESC) AS AmtRank
    FROM sales_data
    GROUP BY Month, Product)

SELECT
    Month,
    Product,
    Total_Amt_Sold
FROM
    MonthlyProductSales
WHERE
    AmtRank = 1
ORDER BY
    Month;


/* So now we can see the products that were sold the most for each month.

The question then becomes, which item is the most popular for the company to sell year-round?*/

SELECT Product, COUNT(QuantityOrdered) AS TotalAmtSold
FROM sales_data
GROUP BY Product
ORDER BY TotalAmtSold DESC;

/* It seems like Lightning Charging Cable is the most popular item. Now,
let's try to figure out what month does the lighting charging cable sold the most
so that we know to really advertise it during that month to increase revenue.*/

/* With that said, what is the 

SELECT COUNT(Product) AS Lightning_Charging_Cable_Amt, Month
FROM sales_data
WHERE Product = 'Lightning Charging Cable'
GROUP BY Month
ORDER BY Lightning_Charging_Cable_Amt DESC;

/* From this, we can tell that December and October should be when we try to increase
our revenue by putting out advertisement for our charging cable. */


/*
Okay, what is the item that was sold the least and what was its price? We would
love to know this to see if the product we have on-hand should be discontinued
or not.
*/
SELECT 
    Product, SUM(QuantityOrdered) AS TotalQuantity, PriceEach
FROM sales_data
GROUP BY Product, PriceEach
ORDER BY 
    TotalQuantity DESC;
    
/* It looks like Washing and Drying machines are the least sold items from our
product line, they are also quite expensive. With that information, we can now
bring this up to our next meeting to discuss the potential to discontinue the
products to spend our resource elsewhere.*/

-- End of project.
