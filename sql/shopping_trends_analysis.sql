USE shopping_trends_db;

-- =====================================================
-- DATA STRUCTURE UNDERSTANDING
-- =====================================================

	-- TOTAL RECORDS
SELECT COUNT(*) AS total_records
FROM shopping_trends_updated;

	-- TOTAL COLUMNS
SELECT COUNT(*) AS total_columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'shopping_trends_updated';
  
	-- COLUMN NAMES
SELECT ORDINAL_POSITION, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'shopping_trends_updated'
ORDER BY ORDINAL_POSITION;

	-- DATA TYPES
SELECT ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'shopping_trends_updated'
ORDER BY ORDINAL_POSITION;
-- =============================================================================================== --

-- =====================================================
-- BASIC DATA EXPLORATION
-- =====================================================

	-- FIRST 5 RECORDS
SELECT *FROM shopping_trends_updated
LIMIT 5;

	-- LAST 5 RECORDS
SELECT * FROM shopping_trends_updated
ORDER BY `Customer ID` DESC
LIMIT 5;

	-- TOTAL PURCHASE AMOUNT
SELECT SUM(`Purchase Amount (USD)`) AS total_purchase_amount
FROM shopping_trends_updated;
-- =============================================================================================== --

-- =====================================================
-- STATISTICAL SUMMARY
-- =====================================================

	-- STATISTICAL QUERIES
SELECT
    COUNT(*) AS total_records,
    MIN(Age) AS min_age,
    MAX(Age) AS max_age,
    ROUND(AVG(Age), 2) AS avg_age,
    MIN(`Purchase Amount (USD)`) AS min_purchase_amount,
    MAX(`Purchase Amount (USD)`) AS max_purchase_amount,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS avg_purchase_amount,
    MIN(`Review Rating`) AS min_review_rating,
    MAX(`Review Rating`) AS max_review_rating,
    ROUND(AVG(`Review Rating`), 2) AS avg_review_rating
FROM shopping_trends_updated;
-- =============================================================================================== --

-- =====================================================
-- DATA QUALITY CHECK
-- =====================================================

	-- NULL VALUES CHECK
SELECT
    SUM(`Customer ID` IS NULL) AS customer_id_nulls,
    SUM(Age IS NULL) AS age_nulls,
    SUM(Gender IS NULL) AS gender_nulls,
    SUM(`Item Purchased` IS NULL) AS item_purchased_nulls,
    SUM(Category IS NULL) AS category_nulls,
    SUM(`Purchase Amount (USD)` IS NULL) AS purchase_amount_nulls,
    SUM(Location IS NULL) AS location_nulls,
    SUM(Size IS NULL) AS size_nulls,
    SUM(Color IS NULL) AS color_nulls,
    SUM(Season IS NULL) AS season_nulls,
    SUM(`Review Rating` IS NULL) AS review_rating_nulls,
    SUM(`Subscription Status` IS NULL) AS subscription_status_nulls,
    SUM(`Shipping Type` IS NULL) AS shipping_type_nulls,
    SUM(`Discount Applied` IS NULL) AS discount_applied_nulls,
    SUM(`Promo Code Used` IS NULL) AS promo_code_used_nulls,
    SUM(`Previous Purchases` IS NULL) AS previous_purchases_nulls,
    SUM(`Payment Method` IS NULL) AS payment_method_nulls,
    SUM(`Frequency of Purchases` IS NULL) AS frequency_nulls
FROM shopping_trends_updated;

	-- CATEGORICAL VALUE CHECK
SELECT
    SUM(Gender IS NOT NULL AND Gender NOT IN ('Male', 'Female')) AS invalid_gender,
    SUM(Category IS NOT NULL AND Category NOT IN ('Clothing', 'Footwear', 'Outerwear', 'Accessories')) AS invalid_category,
    SUM(Size IS NOT NULL AND Size NOT IN ('S', 'M', 'L', 'XL')) AS invalid_size,
    SUM(Season IS NOT NULL AND Season NOT IN ('Spring', 'Summer', 'Fall', 'Winter')) AS invalid_season,
    SUM(`Subscription Status` IS NOT NULL AND `Subscription Status` NOT IN ('Yes', 'No')) AS invalid_subscription_status,
    SUM(`Discount Applied` IS NOT NULL AND `Discount Applied` NOT IN ('Yes', 'No')) AS invalid_discount_applied,
    SUM(`Promo Code Used` IS NOT NULL AND `Promo Code Used` NOT IN ('Yes', 'No')) AS invalid_promo_code_used
FROM shopping_trends_updated;

	-- DUPLICATE RECORDS CHECK
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT `Customer ID`) AS unique_customer_ids,
    COUNT(*) - COUNT(DISTINCT `Customer ID`) AS duplicate_customer_ids
FROM shopping_trends_updated;

	-- NUMERIC RANGE CHECK
SELECT
    MIN(Age) AS min_age,
    MAX(Age) AS max_age,
    MIN(`Purchase Amount (USD)`) AS min_purchase_amount,
    MAX(`Purchase Amount (USD)`) AS max_purchase_amount,
    MIN(`Review Rating`) AS min_review_rating,
    MAX(`Review Rating`) AS max_review_rating,
    MIN(`Previous Purchases`) AS min_previous_purchases,
    MAX(`Previous Purchases`) AS max_previous_purchases
FROM shopping_trends_updated;

	-- CUSTOMER ID UNIQUENESS CHECK
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT `Customer ID`) AS unique_customer_ids,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT `Customer ID`)
        THEN 'UNIQUE'
        ELSE 'DUPLICATES FOUND'
    END AS uniqueness_status
FROM shopping_trends_updated;

	-- OUTLIER CHECK
WITH ranked AS (
    SELECT
        `Purchase Amount (USD)`,
        ROW_NUMBER() OVER (
            ORDER BY `Purchase Amount (USD)` ASC
        ) AS rn,
        COUNT(*) OVER () AS total_rows
    FROM shopping_trends_updated
),
quartiles AS (
    SELECT
        MAX(
            CASE
                WHEN rn = FLOOR(0.25 * total_rows)
                THEN `Purchase Amount (USD)`
            END
        ) AS q1,
        MAX(
            CASE
                WHEN rn = FLOOR(0.75 * total_rows)
                THEN `Purchase Amount (USD)`
            END
        ) AS q3
    FROM ranked
)
SELECT
    COUNT(*) AS total_outliers
FROM shopping_trends_updated, quartiles
WHERE `Purchase Amount (USD)` < q1 - 1.5 * (q3 - q1)
   OR `Purchase Amount (USD)` > q3 + 1.5 * (q3 - q1);

	-- OVERALL DATA QUALITY SUMMARY
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT `Customer ID`) AS unique_customers,
    SUM(
        `Customer ID` IS NULL OR
        Age IS NULL OR
        Gender IS NULL OR
        `Item Purchased` IS NULL OR
        Category IS NULL OR
        `Purchase Amount (USD)` IS NULL OR
        Location IS NULL OR
        Size IS NULL OR
        Color IS NULL OR
        Season IS NULL OR
        `Review Rating` IS NULL OR
        `Subscription Status` IS NULL OR
        `Shipping Type` IS NULL OR
        `Discount Applied` IS NULL OR
        `Promo Code Used` IS NULL OR
        `Previous Purchases` IS NULL OR
        `Payment Method` IS NULL OR
        `Frequency of Purchases` IS NULL
    ) AS records_with_nulls,
    COUNT(*) - COUNT(DISTINCT `Customer ID`) AS duplicate_customer_ids
FROM shopping_trends_updated;
-- =============================================================================================== --

-- =====================================================
-- BUSINESS QUESTIONS & QUERIES USING ARITHMETIC OPERATORS
-- =====================================================
-- ADDITION (+)
	-- Q1. What is the purchase amount after adding a $10 service charge?
SELECT
    `Purchase Amount (USD)`,
    `Purchase Amount (USD)` + 10 AS amount_with_service_charge
FROM shopping_trends_updated;

-- SUBTRACTION (-)
	-- Q2. What is the purchase amount after applying a $5 reduction?
SELECT
    `Purchase Amount (USD)`,
    `Purchase Amount (USD)` - 5 AS amount_after_reduction
FROM shopping_trends_updated;

-- MULTIPLICATION (*)
	-- Q3. What is the total amount when the purchase amount is doubled?
SELECT
    `Purchase Amount (USD)`,
    `Purchase Amount (USD)` * 2 AS doubled_purchase_amount
FROM shopping_trends_updated;

-- DIVISION (/)
	-- Q4. What is the average purchase amount per two equal parts?
SELECT
    `Purchase Amount (USD)`,
    `Purchase Amount (USD)` / 2 AS half_purchase_amount
FROM shopping_trends_updated;

-- MODULUS (%)
	-- Q5. Which purchase amounts are divisible by 5?
SELECT
    `Purchase Amount (USD)`,
    `Purchase Amount (USD)` % 5 AS remainder
FROM shopping_trends_updated;
-- =============================================================================================== --

-- =====================================================
-- BUSINESS QUESTIONS & QUERIES USING COMPARISON OPERATORS 
-- =====================================================
-- EQUAL TO (=)
	-- Q1. How many female customers are present in the dataset?
SELECT
    Gender,
    COUNT(*) AS total_customers
FROM shopping_trends_updated
WHERE Gender = 'Female'
GROUP BY Gender;

-- GREATER THAN (>)
	-- Q2. Which customers made purchases above $60?
SELECT
    `Customer ID`,
    `Item Purchased`,
    Category,
    `Purchase Amount (USD)`
   FROM shopping_trends_updated
WHERE `Purchase Amount (USD)` > 60
ORDER BY `Purchase Amount (USD)` DESC;

-- LESS THAN (<)
    -- Q3. Which customers gave review ratings below 3.5?
SELECT
    `Customer ID`,
    `Item Purchased`,
    `Review Rating`
FROM shopping_trends_updated
WHERE `Review Rating` < 3.5
ORDER BY `Review Rating` ASC;

-- GREATER THAN OR EQUAL TO (>=)
    -- Q4. Which customers have made 10 or more previous purchases?
SELECT
    `Customer ID`,
    Age,
    `Previous Purchases`
FROM shopping_trends_updated
WHERE `Previous Purchases` >= 10
ORDER BY `Previous Purchases` DESC;

-- LESS THAN OR EQUAL TO (<=)
    -- Q5. How many customers are aged 25 or below?
SELECT
    Age,
    COUNT(*) AS total_customers
FROM shopping_trends_updated
WHERE Age <= 25
GROUP BY Age
ORDER BY Age;

-- NOT EQUAL TO (<>)
    -- Q6. Which categories are different from Clothing?
SELECT
    Category,
    COUNT(*) AS total_orders,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
FROM shopping_trends_updated
WHERE Category <> 'Clothing'
GROUP BY Category
ORDER BY total_orders DESC;

-- NOT EQUAL TO (!=)
    -- Q7. How many customers are not subscribed?
SELECT
    `Subscription Status`,
    COUNT(*) AS total_customers
FROM shopping_trends_updated
WHERE `Subscription Status` != 'Yes'
GROUP BY `Subscription Status`;
-- =============================================================================================== --

-- =====================================================
--  BUSINESS QUESTIONS & QUERIES USING LOGICAL OPERATORS
-- =====================================================
-- AND
	-- Q1. Which customers are female and made purchases above $60?
SELECT
    `Customer ID`,
    Gender,
    `Purchase Amount (USD)`
FROM shopping_trends_updated
WHERE Gender = 'Female'
  AND `Purchase Amount (USD)` > 60;

-- OR
	-- Q2. Which customers are from California or Texas?
SELECT
    `Customer ID`,
    Location
FROM shopping_trends_updated
WHERE Location = 'California'
   OR Location = 'Texas';

-- NOT
	-- Q3. Which customers are not subscribed?
SELECT
    `Customer ID`,
    `Subscription Status`
FROM shopping_trends_updated
WHERE NOT `Subscription Status` = 'Yes';
-- =============================================================================================== --

-- =====================================================
-- BUSINESS QUESTIONS & QUERIES USING LIKE OPERATORS
-- =====================================================
-- LIKE 'S%'
	-- Q1. Which customers purchased items starting with the letter 'S'?
SELECT
    `Customer ID`,
    `Item Purchased`
FROM shopping_trends_updated
WHERE `Item Purchased` LIKE 'S%';

-- LIKE '%s'
	-- Q2. Which customers purchased items ending with the letter 's'?
SELECT
    `Customer ID`,
    `Item Purchased`
FROM shopping_trends_updated
WHERE `Item Purchased` LIKE '%s';

-- LIKE '%Jeans%'
	-- Q3. Which customers purchased items containing the word 'Jeans'?
SELECT
    `Customer ID`,
    `Item Purchased`
FROM shopping_trends_updated
WHERE `Item Purchased` LIKE '%Jeans%';
-- =============================================================================================== --

-- =====================================================
-- BUSINESS QUESTIONS & QUERIES USING AGGREGATE FUNCTIONS
-- =====================================================
-- COUNT()
	-- Q1. How many total orders are in the dataset?
SELECT COUNT(*) AS total_orders
FROM shopping_trends_updated;

-- SUM()
	-- Q2. What is the total purchase amount?
SELECT ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_purchase_amount
FROM shopping_trends_updated;

-- AVG()
	-- Q3. What is the average purchase amount?
SELECT ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
FROM shopping_trends_updated;

-- MIN()
	-- Q4. What is the minimum purchase amount?
SELECT MIN(`Purchase Amount (USD)`) AS minimum_purchase_amount
FROM shopping_trends_updated;

-- MAX()
	-- Q5. What is the maximum purchase amount?
SELECT MAX(`Purchase Amount (USD)`) AS maximum_purchase_amount
FROM shopping_trends_updated;
-- =============================================================================================== --

-- =====================================================
-- BUSINESS QUESTIONS & QUERIES USING GROUP BY AND HAVING
-- =====================================================
-- GROUP BY
	-- Q1. How many orders are there in each category?
SELECT
    Category,
    COUNT(*) AS total_orders
FROM shopping_trends_updated
GROUP BY Category;

-- GROUP BY + HAVING
	-- Q2. Which categories have more than 500 orders?
SELECT
    Category,
    COUNT(*) AS total_orders
FROM shopping_trends_updated
GROUP BY Category
HAVING COUNT(*) > 500;
-- =============================================================================================== --

-- =====================================================
-- BUSINESS QUESTIONS & QUERIES USING CASE EXPRESSION
-- =====================================================
-- CASE WHEN - Purchase Amount Classification
	-- Q1. How can customers be classified based on their purchase amount?
SELECT
    `Customer ID`,
    `Purchase Amount (USD)`,
    CASE
        WHEN `Purchase Amount (USD)` >= 75 THEN 'High'
        WHEN `Purchase Amount (USD)` >= 50 THEN 'Medium'
        ELSE 'Low'
    END AS purchase_category
FROM shopping_trends_updated;

-- CASE WHEN - Discount Classification
	-- Q2. How can orders be classified based on discount status?
SELECT
    `Customer ID`,
    `Discount Applied`,
    CASE
        WHEN `Discount Applied` = 'Yes' THEN 'Discounted Order'
        ELSE 'Non-Discounted Order'
    END AS discount_category
FROM shopping_trends_updated;
-- =============================================================================================== --

-- =====================================================
-- BUSINESS QUESTIONS & QUERIES USING STRING FUNCTIONS
-- =====================================================
-- UPPER() + LOWER()
	-- Q1. How can product names be displayed in uppercase and lowercase?
SELECT
    `Item Purchased`,
    UPPER(`Item Purchased`) AS uppercase_item,
    LOWER(`Item Purchased`) AS lowercase_item
FROM shopping_trends_updated;

-- LENGTH()
	-- Q2. How many characters are present in each product name?
SELECT
    `Item Purchased`,
    LENGTH(`Item Purchased`) AS item_name_length
FROM shopping_trends_updated;

-- CONCAT()
	-- Q3. How can customer and product information be combined into one label?
SELECT
    CONCAT(`Customer ID`, ' - ', `Item Purchased`) AS customer_item_label
FROM shopping_trends_updated;

-- SUBSTRING()
	-- Q4. How can the first three characters of each product name be extracted?
SELECT
    `Item Purchased`,
    SUBSTRING(`Item Purchased`, 1, 3) AS first_three_characters
FROM shopping_trends_updated;
-- =============================================================================================== --

-- =====================================================
-- BUSINESS QUESTIONS & QUERIES USING NUMERIC FUNCTIONS
-- =====================================================
-- ROUND()
	-- Q1. How can purchase amounts be rounded to 1 decimal place?
SELECT
    `Purchase Amount (USD)`,
    ROUND(`Purchase Amount (USD)`, 1) AS rounded_amount
FROM shopping_trends_updated;

-- CEIL()
	-- Q2. What is the next whole-number value of each purchase amount?
SELECT
    `Purchase Amount (USD)`,
    CEIL(`Purchase Amount (USD)`) AS ceiling_amount
FROM shopping_trends_updated;

-- FLOOR()
	-- Q3. What is the previous whole-number value of each purchase amount?
SELECT
    `Purchase Amount (USD)`,
    FLOOR(`Purchase Amount (USD)`) AS floor_amount
FROM shopping_trends_updated;

-- ABS()
	-- Q4. What is the absolute difference between each purchase amount and $60?
SELECT
    `Purchase Amount (USD)`,
    ABS(`Purchase Amount (USD)` - 60) AS difference_from_60
FROM shopping_trends_updated;
-- =============================================================================================== --

-- =====================================================
-- BUSINESS QUESTIONS & QUERIES USING SUBQUERIES
-- =====================================================
-- SUBQUERY WITH AVG()
	-- Q1. Which orders have a purchase amount higher than the overall average?
SELECT
    `Customer ID`,
    `Item Purchased`,
    `Purchase Amount (USD)`
FROM shopping_trends_updated
WHERE `Purchase Amount (USD)` > (
    SELECT AVG(`Purchase Amount (USD)`)
    FROM shopping_trends_updated)
ORDER BY `Purchase Amount (USD)` DESC;

-- SUBQUERY WITH AVG()
	-- Q2. Which customers have made more previous purchases than the average?
SELECT
    `Customer ID`,
    `Previous Purchases`
FROM shopping_trends_updated
WHERE `Previous Purchases` > (
    SELECT AVG(`Previous Purchases`)
    FROM shopping_trends_updated)
ORDER BY `Previous Purchases` DESC;
-- =============================================================================================== --

-- =====================================================
-- BUSINESS QUESTIONS & QUERIES USING COMMON TABLE EXPRESSIONS (CTEs)
-- =====================================================
-- CTE WITH AVG()
	-- Q1. Which categories have an average purchase amount above $60?
WITH category_summary AS (
    SELECT
        Category,
        ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
    FROM shopping_trends_updated
    GROUP BY Category)
SELECT
    Category,
    average_purchase_amount
FROM category_summary
WHERE average_purchase_amount > 60
ORDER BY average_purchase_amount DESC;

-- CTE WITH SUM()
	-- Q2. Which seasons have total purchase amounts above $58,000?
WITH season_summary AS (
    SELECT
        Season,
        ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_purchase_amount
    FROM shopping_trends_updated
    GROUP BY Season)
SELECT
    Season,
    total_purchase_amount
FROM season_summary
WHERE total_purchase_amount > 58000
ORDER BY total_purchase_amount DESC;
-- =============================================================================================== --

-- =====================================================
-- BUSINESS QUESTIONS & QUERIES USING WINDOW FUNCTIONS
-- =====================================================
-- ROW_NUMBER()
	-- Q1. What is the sequential ranking of customers based on purchase amount?
SELECT
    `Customer ID`,
    `Purchase Amount (USD)`,
    ROW_NUMBER() OVER (
        ORDER BY `Purchase Amount (USD)` DESC
    ) AS purchase_row_number
FROM shopping_trends_updated;

-- RANK()
	-- Q2. How are customers ranked based on their purchase amount, including ties?
SELECT
    `Customer ID`,
    `Purchase Amount (USD)`,
    RANK() OVER (
        ORDER BY `Purchase Amount (USD)` DESC
    ) AS purchase_rank
FROM shopping_trends_updated;

-- DENSE_RANK() WITH PARTITION BY
	-- Q3. How can customers be ranked within each category?
SELECT
    `Customer ID`,
    Category,
    `Purchase Amount (USD)`,
    DENSE_RANK() OVER (
        PARTITION BY Category
        ORDER BY `Purchase Amount (USD)` DESC
    ) AS category_rank
FROM shopping_trends_updated;

-- SUM() OVER()
	-- Q4. What is the cumulative purchase amount across all orders?
SELECT
    `Customer ID`,
    `Purchase Amount (USD)`,
    SUM(`Purchase Amount (USD)`) OVER (
        ORDER BY `Customer ID`
    ) AS cumulative_purchase_amount
FROM shopping_trends_updated;
-- =============================================================================================== --

-- =====================================================
-- BUSINESS QUESTIONS & QUERIES USING SET OPERATORS
-- =====================================================
-- UNION
	-- Q1. Which locations are represented in the dataset from two different groups?
SELECT Location
FROM shopping_trends_updated
WHERE Gender = 'Female'
UNION
SELECT Location
FROM shopping_trends_updated
WHERE Gender = 'Male';

-- UNION ALL
	-- Q2. How can the locations from two groups be combined while keeping duplicates?
SELECT Location
FROM shopping_trends_updated
WHERE Gender = 'Female'
UNION ALL
SELECT Location
FROM shopping_trends_updated
WHERE Gender = 'Male';
-- =============================================================================================== --

-- =====================================================
-- REAL WORLD BUSINESS QUESTIONS AND KEY FINDINGS
-- =====================================================
-- LOCATION PERFORMANCE
-- Q1. Why are some locations generating significantly lower purchase amounts than others?
	
    -- Total Purchase Amount by Location
SELECT
    Location,
    COUNT(*) AS total_orders,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_purchase_amount,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
FROM shopping_trends_updated
GROUP BY Location
ORDER BY total_purchase_amount DESC;
-- =====================================================
-- RESULTS
-- =====================================================
-- 1. Montana generated the highest total purchase amount with $5,784 from 96 orders.
-- 2. Kansas generated the lowest total purchase amount with $3,437 from 63 orders.
-- 3. Kansas also had a lower average purchase amount of $54.56 per order.
-- =====================================================
-- KEY FINDINGS
-- =====================================================
-- Therefore, the lower purchase amount in Kansas appears to be associated with fewer orders
-- and lower average spending per order.
-- ============================================================================================== --

-- PRODUCT & CATEGORY PERFORMANCE
-- Q2. Which categories/products have the highest review ratings?

	-- Average Review Rating by Category
SELECT
    Category,
    COUNT(*) AS total_reviews,
    ROUND(AVG(`Review Rating`), 2) AS average_review_rating
FROM shopping_trends_updated
GROUP BY Category
ORDER BY average_review_rating DESC;

	-- Average Review Rating by Product
SELECT
    `Item Purchased`,
    COUNT(*) AS total_reviews,
    ROUND(AVG(`Review Rating`), 2) AS average_review_rating
FROM shopping_trends_updated
GROUP BY `Item Purchased`
ORDER BY average_review_rating DESC;
-- =====================================================
-- RESULTS
-- =====================================================
-- 1. Footwear had the highest average review rating of 3.79 from 599 reviews.
-- 2. Accessories had an average review rating of 3.77 from 1,240 reviews.
-- 3. Clothing had the lowest average review rating of 3.72 from 1,737 reviews.
-- =====================================================
-- KEY FINDINGS
-- =====================================================
-- Therefore, Footwear appears to have the highest customer satisfaction based on
-- average review rating, while Clothing has the lowest average review rating.
-- =============================================================================================== --

-- CATEGORY PERFORMANCE
-- Q3. Why is one product category underperforming compared with other categories?

	-- Category Performance Analysis
SELECT
    Category,
    COUNT(*) AS total_orders,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_purchase_amount,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
FROM shopping_trends_updated
GROUP BY Category
ORDER BY total_purchase_amount DESC;
-- =====================================================
-- RESULTS
-- =====================================================
-- 1. Clothing generated the highest total purchase amount of $104,264 from 1,737 orders.
-- 2. Outerwear generated the lowest total purchase amount of $18,524 from 324 orders.
-- 3. Outerwear also had the lowest average purchase amount of $57.17 per order.
-- =====================================================
-- KEY FINDINGS
-- =====================================================
-- Therefore, Outerwear appears to be the underperforming category due to fewer orders and 
-- lower average spending per order compared with other categories.
-- =============================================================================================== --

-- DISCOUNT PERFORMANCE
-- Q4. Why are some customers still spending less even after receiving discounts?

	-- Purchase Performance by Discount Status
SELECT
    `Discount Applied`,
    COUNT(*) AS total_orders,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_purchase_amount,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
FROM shopping_trends_updated
GROUP BY `Discount Applied`
ORDER BY average_purchase_amount DESC;
-- =====================================================
-- RESULTS
-- =====================================================
-- 1. Customers without discounts had a higher average purchase amount of $60.13 from 2,223 orders.
-- 2. Customers with discounts had a lower average purchase amount of $59.28 from 1,677 orders.
-- 3. The discounted group generated $99,411 in total purchase amount compared with $133,670 
-- for the non-discounted group.
-- =====================================================
-- KEY FINDINGS
-- =====================================================
-- Therefore, customers who received discounts appear to spend slightly less on average than
-- customers who did not receive discounts.
-- =============================================================================================== --

-- SUBSCRIPTION PERFORMANCE
-- Q5. Do subscribed customers spend more than non-subscribed customers?

	-- Purchase Performance by Subscription Status
SELECT
    `Subscription Status`,
    COUNT(*) AS total_customers,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_purchase_amount,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
FROM shopping_trends_updated
GROUP BY `Subscription Status`
ORDER BY average_purchase_amount DESC;
-- =====================================================
-- RESULTS
-- =====================================================
-- 1. Non-subscribed customers had a higher average purchase amount of $59.87 from 2,847 customers.
-- 2. Subscribed customers had a lower average purchase amount of $59.49 from 1,053 customers.
-- 3. Non-subscribed customers generated a higher total purchase amount of $170,436.
-- =====================================================
-- KEY FINDINGS
-- =====================================================
-- Therefore, subscribed customers do not appear to spend more than non-subscribed customers,
-- as their average purchase amount is slightly lower.
-- =============================================================================================== --

-- SEASONAL PERFORMANCE
-- Q6. Why does a particular season show lower purchase activity than other seasons?

-- Purchase Performance by Season
SELECT
    Season,
    COUNT(*) AS total_orders,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_purchase_amount,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
FROM shopping_trends_updated
GROUP BY Season
ORDER BY total_orders DESC;
-- =====================================================
-- RESULTS
-- =====================================================
-- 1. Spring had the highest number of orders with 999 orders and a total purchase amount of $58,679.
-- 2. Summer had the lowest number of orders with 955 orders and a total purchase amount of $55,777.
-- 3. Summer also had the lowest average purchase amount of $58.41 per order.
-- =====================================================
-- KEY FINDINGS
-- =====================================================
-- Therefore, Summer shows the lowest purchase activity, which appears to be associated
-- with fewer orders and lower average spending per order compared with the other seasons.
-- =============================================================================================== --

-- PRODUCT PURCHASE FREQUENCY
-- Q7. Why are some products purchased much less frequently than similar products?

	-- Product Purchase Frequency Analysis
SELECT
    `Item Purchased`,
    COUNT(*) AS total_orders,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
FROM shopping_trends_updated
GROUP BY `Item Purchased`
ORDER BY total_orders DESC;
-- =====================================================
-- RESULTS
-- =====================================================
-- 1. Blouse had the highest purchase frequency with 171 orders.
-- 2. Jeans had the lowest purchase frequency with 124 orders.
-- 3. Jeans had an average purchase amount of $60.87 per order,
--    which is not significantly lower than most other products.
-- =====================================================
-- KEY FINDINGS
-- =====================================================
-- Therefore, Jeans appears to have lower purchase frequency mainly due to fewer orders,
-- rather than a significantly lower average purchase amount.
-- =============================================================================================== --

-- CUSTOMER CHARACTERISTICS
-- Q8. Which customer characteristics are associated with higher purchase amounts?

-- Purchase Amount by Gender

SELECT
    Gender,
    COUNT(*) AS total_customers,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
FROM shopping_trends_updated
GROUP BY Gender
ORDER BY average_purchase_amount DESC;


-- Purchase Amount by Age Group

SELECT
    CASE
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        WHEN Age BETWEEN 56 AND 65 THEN '56-65'
        ELSE '66+'
    END AS age_group,
    COUNT(*) AS total_customers,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
FROM shopping_trends_updated
GROUP BY age_group
ORDER BY average_purchase_amount DESC;
-- =====================================================
-- RESULTS
-- =====================================================
-- 1. Female customers had a higher average purchase amount of $60.25
--    compared with $59.54 for male customers.
-- 2. The 18-25 age group had the highest average purchase amount of $60.65.
-- 3. The 66+ age group had the lowest average purchase amount of $58.88.
-- =====================================================
-- KEY FINDINGS
-- =====================================================
-- Therefore, female customers and younger customers, particularly the 18-25 age group,
-- appear to be associated with slightly higher average purchase amounts.
-- =============================================================================================== --

-- SIZE DEMAND
-- Q9. Which sizes have the highest purchase demand?

	-- Purchase Demand by Size
SELECT
    Size,
    COUNT(*) AS total_orders,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_purchase_amount
FROM shopping_trends_updated
GROUP BY Size
ORDER BY total_orders DESC;
-- =====================================================
-- RESULTS
-- =====================================================
-- 1. M size had the highest purchase demand with 1,755 orders.
-- 2. XL size had the lowest purchase demand with 429 orders.
-- 3. M size generated the highest total purchase amount of $105,167.
-- =====================================================
-- KEY FINDINGS
-- =====================================================
-- Therefore, M size appears to have the highest customer demand, while XL size has the
-- lowest purchase demand among the available sizes.
-- =============================================================================================== --

-- CATEGORY & SEASON PERFORMANCE
-- Q10. Which product categories perform best in each season?

	-- Category Performance by Season
SELECT
    Season,
    Category,
    COUNT(*) AS total_orders,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_purchase_amount,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
FROM shopping_trends_updated
GROUP BY Season, Category
ORDER BY Season, total_purchase_amount DESC;
-- =====================================================
-- RESULT
-- =====================================================
-- 1. Clothing had the highest total purchase amount in Fall ($26,220),
--    Spring ($27,692), Summer ($23,078), and Winter ($27,274).
-- 2. Clothing also had the highest number of orders in every season.
-- 3. Footwear had the highest average purchase amount in Fall at $63.71.
-- =====================================================
-- KEY FINDINGS
-- =====================================================
-- Therefore, Clothing consistently performs best across all seasons based on total purchase amount
-- and order volume, making it the strongest-performing category throughout the year.

-- ================================================================================================ --
-- ================================"SQL PROJECT COMPLETED SUCCESFULLY"================================
-- ================================================================================================ --
