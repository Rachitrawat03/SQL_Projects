SELECT * FROM email_subject;
    
SELECT * FROM emails;
    
SELECT * FROM products;
    
SELECT * FROM sales;

-- There are total 37711 records in sales table, we only need the data for Sprint Electic Scooter. After the first 2 weeks, sales began to decline by 20 %. 

SELECT 
    DATE(sales_transaction_date) AS date,
    TIME(sales_transaction_date) AS time
FROM
    sales;


-- Creating a table where product is Sprint Electric Scooter and Sales transaction date ranges from 10-10-2016 to 31-10-2016 

CREATE TABLE sprint_sales (SELECT * FROM
    sales
WHERE
    sales_transaction_date >= '2016-10-10'
        AND sales_transaction_date < '2016-10-10' + INTERVAL 22 DAY
        AND product_id = 7);
  

SELECT * FROM sprint_sales;

  
-- Creating  table for quantity sold

CREATE TABLE quantity (SELECT sales_transaction_date,
    COUNT(sales_transaction_date) AS quantity_sold FROM
    sprint_sales
GROUP BY sales_transaction_date
ORDER BY sales_transaction_date);


SELECT * FROM quantity;


-- Creating a view for calculating current period sales, prior period sales and sales growth of sprint electric scooter

Create view  final_output1  as ( SELECT
    *,ROW_NUMBER() OVER (ORDER BY sales_transaction_date) AS row_no,
    concat(round((current_period_sales - prior_period_sales) / prior_period_sales* 100),"%")  AS percentage_growth
FROM (
    SELECT
        *,
        SUM(quantity_sold) OVER (
            ORDER BY sales_transaction_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS current_period_sales,
        SUM(quantity_sold) OVER (
            ORDER BY sales_transaction_date
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) AS prior_period_sales
    FROM quantity
) AS subquery
ORDER BY sales_transaction_date);

SELECT * FROM final_output1;


-- Creating a table where product is Sprint Limited Edition electric scooter and sales transaction date ranges from 10-10-2016 to 31-10-2016 

CREATE TABLE sprint_le_sales (SELECT * FROM
    sales
WHERE
    sales_transaction_date >= '2017-02-17'
        AND sales_transaction_date < '2017-02-17' + INTERVAL 22 DAY
        AND product_id = 8);
  
  
SELECT * FROM sprint_le_sales;


-- Creating  table for quantity for sprint Electric Limited Edition

CREATE TABLE quantity_le (SELECT sales_transaction_date,
    COUNT(sales_transaction_date) AS quantity_sold FROM
    sprint_le_sales
GROUP BY sales_transaction_date
ORDER BY sales_transaction_date);


SELECT * FROM quantity_le;


-- Creating a view for calculating current period sales, prior period sales and sales growth for sprint electric scooter limited edition


create view final_output2 as (SELECT
    *,ROW_NUMBER() OVER (ORDER BY sales_transaction_date) AS row_no,
    concat(round((current_period_sales - prior_period_sales) / prior_period_sales* 100),"%")  AS percentage_growth
FROM (
    SELECT
        *,
        SUM(quantity_sold) OVER (
            ORDER BY sales_transaction_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS current_period_sales,
        SUM(quantity_sold) OVER (
            ORDER BY sales_transaction_date
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) AS prior_period_sales
    FROM quantity_le
) AS subquery
ORDER BY sales_transaction_date );


SELECT * FROM final_output1;
SELECT * FROM final_output2;


-- Summarizing the Sprint and Sprint Limited Edition growth rate

SELECT
    fo1.row_no, fo1.percentage_growth, fo2.percentage_growth
    from final_output1 fo1
    join final_output2 fo2
    on fo1.row_no = fo2.row_no;

-- EMAIL ANALYSIS 

SELECT * FROM email_subject;
SELECT * FROM emails;
SELECT * FROM products;

-- Cleaning the Table 

ALTER TABLE emails
MODIFY COLUMN sent_date DATE;

-- Email data only for sprint electric scooter and data is of only 2 months 

CREATE TABLE sprint_emails (SELECT ss.customer_id,
    ss.product_id,
    e.email_id,
    e.opened,
    e.clicked,
    e.bounced,
    e.sent_date,
    e.opened_date,
    e.clicked_date,
    e.email_subject_id FROM
    sprint_sales ss
        JOIN
    emails e ON ss.customer_id = e.customer_id
WHERE
    email_subject_id = 7);

SELECT * FROM sprint_emails;

 
SELECT 
    'click rate',
    k.EmailsClicked * 100 / (k.EmailsSent - k.BouncedEmails) AS ClickRate,
    ' email_opening_rate ',
    (k.emails_opened / k.EmailsSent) * 100 AS Email_opening_Rate
FROM
    (SELECT 
        COUNT(*) AS EmailsSent,
            SUM(CASE
                WHEN onee.clicked = 't' THEN 1
                ELSE 0
            END) AS EmailsClicked,
            SUM(CASE
                WHEN onee.bounced = 't' THEN 1
                ELSE 0
            END) AS BouncedEmails,
            SUM(CASE
                WHEN onee.opened = 't' THEN 1
                ELSE 0
            END) AS emails_opened
    FROM
        (SELECT 
        e.opened, e.clicked, e.bounced
    FROM
        emails AS e
    JOIN email_subject AS es ON e.email_subject_id = es.email_subject_id
    JOIN sales AS s ON e.customer_id = s.customer_id
    JOIN products AS p ON p.product_id = s.product_id
    WHERE
        p.model = 'sprint'
            AND sent_date > '2016-09-01'
            AND sent_date < '2016-10-31'
    ORDER BY sales_transaction_date ASC) AS onee) AS k;