


mysql> SHOW VARIABLES LIKE 'local_infile';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| local_infile  | ON    |
+---------------+-------+
1 row in set (0.00 sec)

mysql> USE retail_db;
Database changed

mysql> LOAD DATA LOCAL INFILE 'C:/superstore.csv'
    -> INTO TABLE superstore
    -> CHARACTER SET latin1
    -> FIELDS TERMINATED BY ','
    -> ENCLOSED BY '"'
    -> LINES TERMINATED BY '\n'
    -> IGNORE 1 ROWS
    -> (Row_ID, Order_ID, @Order_Date, @Ship_Date, Ship_Mode, Customer_ID, Customer_Name, Segment, Country, City, State, Postal_Code, Region, Product_ID, Category, Sub_Category, Product_Name, Sales, Quantity, Discount, Profit)
    -> SET
    -> Order_Date = STR_TO_DATE(@Order_Date, '%m/%d/%Y'),
    -> Ship_Date = STR_TO_DATE(@Ship_Date, '%m/%d/%Y');
Query OK, 9994 rows affected, 13213 warnings (0.39 sec)
Records: 9994  Deleted: 0  Skipped: 0  Warnings: 13213



mysql> DESCRIBE superstore;


mysql> ALTER TABLE superstore
    -> MODIFY Sales DECIMAL(10,2),
    -> MODIFY Profit DECIMAL(10,2);
Query OK, 0 rows affected (0.04 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE superstore
    -> MODIFY Sales DECIMAL(12,2),
    -> MODIFY Quantity INT,
    -> MODIFY Discount DECIMAL(5,2),
    -> MODIFY Profit DECIMAL(12,2),
    -> MODIFY Postal_Code VARCHAR(20);
Query OK, 9994 rows affected (0.23 sec)
Records: 9994  Duplicates: 0  Warnings: 0

mysql> SELECT
    ->     COUNT(*) AS total_rows,
    ->     SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
    ->     SUM(CASE WHEN Ship_Date IS NULL THEN 1 ELSE 0 END) AS missing_ship_date,
    ->     SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS missing_sales,
    ->     SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS missing_profit
    -> FROM superstore;


mysql> -- Option 1: Remove rows with critical nulls
mysql> DELETE FROM superstore
    -> WHERE Order_Date IS NULL OR Ship_Date IS NULL OR Sales IS NULL OR Profit IS NULL;
Query OK, 0 rows affected (0.02 sec)

mysql>
mysql> -- Option 2: Replace missing numerical values with 0
mysql> UPDATE superstore
    -> SET Sales = 0 WHERE Sales IS NULL;
Query OK, 0 rows affected (0.01 sec)
Rows matched: 0  Changed: 0  Warnings: 0

mysql> UPDATE superstore
    -> SET Profit = 0 WHERE Profit IS NULL;
Query OK, 0 rows affected (0.01 sec)
Rows matched: 0  Changed: 0  Warnings: 0

mysql> SELECT Order_ID, COUNT(*) AS cnt
    -> FROM superstore
    -> GROUP BY Order_ID
    -> HAVING cnt > 1;


mysql> -- Total sales and profit by Category
mysql> SELECT
    ->     Category,
    ->     SUM(Sales) AS total_sales,
    ->     SUM(Profit) AS total_profit,
    ->     ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin_percentage
    -> FROM superstore
    -> GROUP BY Category
    -> ORDER BY profit_margin_percentage ASC; -- helps identify low-margin categories


mysql> -- Detailed Sub-Category Analysis
mysql> SELECT
    ->     Category, Sub_Category,
    ->     SUM(Sales) AS total_sales,
    ->     SUM(Profit) AS total_profit,
    ->     ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin_percentage
    -> FROM superstore
    -> GROUP BY Category, Sub_Category
    -> ORDER BY profit_margin_percentage ASC;


mysql> ALTER TABLE superstore
    -> ADD COLUMN Days_To_Ship INT;
Query OK, 0 rows affected (0.06 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql>
mysql> UPDATE superstore
    -> SET Days_To_Ship = DATEDIFF(Ship_Date, Order_Date);
Query OK, 9994 rows affected (1.00 sec)
Rows matched: 9994  Changed: 9994  Warnings: 0


mysql> SELECT *
    -> INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/superstore_clean.csv'
    -> FIELDS TERMINATED BY ','
    -> ENCLOSED BY '"'
    -> LINES TERMINATED BY '\n'
    -> FROM superstore;
Query OK, 9994 rows affected (0.04 sec)

mysql>