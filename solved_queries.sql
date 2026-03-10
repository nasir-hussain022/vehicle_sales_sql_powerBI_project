-- Basic Questions 
-- 1. update sale_price with 58000 where sale_price 0-1
UPDATE vehicle_sold 
SET 
    sale_price = 58000
WHERE
    sale_price BETWEEN 0 AND 1;


-- 2. What is the total revenue generated across all regions?

SELECT 
    CONCAT(ROUND(SUM(sale_price) / 1000000, 2), 'M') AS total_revenue
FROM
    vehicle_sold;


-- 3. Which car model has the highest total sales volume?

SELECT 
    model, SUM(sale_price) AS highest_sales_volume
FROM
    vehicle_info vi
        INNER JOIN
    vehicle_sold vs ON vs.vehicle_id = vi.vehicle_id
GROUP BY 1
ORDER BY highest_sales_volume DESC
LIMIT 1;

-- 4. What is the average sale_price of a vehicle?

SELECT 
    ROUND(AVG(sale_price), 2) AS `avg _sale_price`
FROM
    vehicle_sold;
    
-- 5. How many vehicles were sold in the 'NORTH' region? 

SELECT 
    COUNT(vs.sale_id) AS vehicle_sold
FROM
    vehicle_sold vs
        INNER JOIN
    inventory_details id ON id.sale_id = vs.sale_id
WHERE
    region = 'North';
    
-- 6. What is the most common body_type in the inventory?

SELECT 
    body_type, COUNT(body_type) AS most_common_body_type
FROM
    vehicle_info
GROUP BY body_type
ORDER BY 2 DESC
LIMIT 1;

-- Intermediate Questions
-- 7.Which region has the highest average days_on_lot?

SELECT 
    region
FROM
    inventory_details id
        INNER JOIN
    vehicle_sold vs ON vs.sale_id = id.sale_id
GROUP BY 1
HAVING AVG(days_on_lot) = (SELECT 
        MAX(avg_days_on_lot)
    FROM
        (SELECT 
            region, AVG(days_on_lot) AS avg_days_on_lot
        FROM
            vehicle_sold vs
        INNER JOIN inventory_details id ON id.sale_id = vs.sale_id
        GROUP BY region) AS max_days);
       
       
       
 -- 8. What is the average mileage of vehicles sold in the 'WEST' region?    
 
 SELECT 
    ROUND(AVG(mileage), 2) AS avg_mileage
FROM
    inventory_details
WHERE
    region = 'west';
    
 -- 9. Identify the top 10 customers by total purchase value.   
 
 select customer_name, sum(sale_price) as total_purchase
 from customers c inner join vehicle_sold vs 
 on vs.sale_id = c.sale_id
 group by 1
 order by 2 desc
 limit 10;

/* 10. What is the average discount/premium (Difference between MSRP and Sale Price) 
for Electric vehicles? */

 SELECT
    ROUND(AVG(sale_price - msrp), 2) avg_price_difference
FROM
    vehicle_info vi
        INNER JOIN
    vehicle_sold vs ON vi.vehicle_id = vs.vehicle_id
WHERE
    fuel_type = 'Electric';
 
-- 11. Which model year (e.g., 2024 models) is currently selling the fastest (lowest avg days on lot)?

SELECT 
    `year`, AVG(days_on_lot) avg_days
FROM
    vehicle_sold vs
        INNER JOIN
    vehicle_info vi ON vi.vehicle_id = vs.vehicle_id
GROUP BY 1
ORDER BY 2 ASC;

-- 12. List all vehicle models that sold for more than their MSRP

SELECT 
    model, msrp, sale_price
FROM
    vehicle_info vi
        INNER JOIN
    vehicle_sold vs ON vs.vehicle_id = vi.vehicle_id
WHERE
    sale_price > msrp
ORDER BY sale_price DESC;  

-- 13. Find the total revenue contributed by each fuel_type. 

SELECT 
    fuel_type, SUM(sale_price) total_revenue
FROM
    vehicle_sold vs
        INNER JOIN
    vehicle_info vi ON vi.vehicle_id = vs.vehicle_id
GROUP BY 1
ORDER BY 2 DESC;


UPDATE vehicle_info 
SET 
    fuel_type = 'Gasoline'
WHERE
    model = 'GLC' AND `year` = 2022
        AND body_type = 'SUV';

UPDATE vehicle_info 
SET 
    fuel_type = 'Gasoline'
WHERE
    model = 'equinox' AND `year` = 2022
        AND body_type = 'SUV';


-- Advanced Questions

-- 14. Calculate the cumulative revenue generated as sale_id increases.

select sale_id , sale_price,
     sum(sale_price) over(order by sale_id) as running_total 
from
     vehicle_sold;
     
 -- 15. Which combination of model and body_type yields the highest average profit margin?    

SELECT 
    model,
    body_type,
    ROUND(AVG((sale_price - msrp) / msrp) * 100, 2) AS avg_profit_margin
FROM
    vehicle_info vi
        INNER JOIN
    vehicle_sold vs ON vs.vehicle_id = vi.vehicle_id
GROUP BY 1 , 2
ORDER BY avg_profit_margin DESC
LIMIT 1;

-- 16. Total Profit
SELECT 
(total.total_rev - cost.total_cost) AS profit
 from
(select sum(sale_price) total_rev from vehicle_sold) as total,
(select sum(msrp) total_cost from vehicle_info) as cost;


-- 17. Gross Profit Margin
SELECT 
    (totals.total_rev - costs.total_cost) / totals.total_rev AS gross_profit_margin
FROM 
    (SELECT SUM(sale_price) AS total_rev FROM `vehicle_sold`) AS totals,
    (SELECT SUM(msrp) AS total_cost FROM `vehicle_info`) AS costs;

-- 18. Compare average days_on_lot for "High Mileage" (>50k) vs "Low Mileage" (<50k) vehicles.

SELECT 
    CASE
        WHEN mileage > 50000 THEN 'High Mileage'
        ELSE 'Low Mileage'
    END 'mileage category',
    ROUND(AVG(days_on_lot), 2) avg_days_on_lot
FROM
    vehicle_sold vs
        INNER JOIN
    inventory_details id ON id.sale_id = vs.sale_id
GROUP BY 1;

-- 19. Identify "Stale Inventory": Models that average more than 100 days on the lot.

SELECT 
    model, ROUND(AVG(days_on_lot), 2) AS avg_lot_days
FROM
    vehicle_info vi
        INNER JOIN
    vehicle_sold vs ON vs.vehicle_id = vi.vehicle_id
GROUP BY 1
HAVING AVG(days_on_lot) > 100
ORDER BY avg_lot_days DESC;

-- 20. Rank regions by their "Sales Efficiency" (Revenue divided by average Days on Lot).

SELECT 
    region,
    ROUND((SUM(sale_price)) / (AVG(days_on_lot)),
            2) AS sale_efficiency
FROM
    inventory_details id
        INNER JOIN
    vehicle_sold vs ON vs.sale_id = id.sale_id
GROUP BY 1
ORDER BY sale_efficiency DESC;

-- 21. What percentage of total sales come from Hybrid/Electric vehicles vs Gasoline?

SELECT 
    fuel_type,
    ROUND((SUM(sale_price) / (SELECT SUM(sale_price) FROM vehicle_sold)) * 100,
            2) AS `total_sale_percentage`
FROM
    vehicle_info AS vi
        INNER JOIN
    vehicle_sold vs ON vs.vehicle_id = vi.vehicle_id
WHERE 
    fuel_type IN ('hybrid', 'electric', 'gasoline')
GROUP BY fuel_type
ORDER BY `total_sale_percentage` DESC;


-- 22. Identify potential data entry errors where the sale_price is less than 50% of the MSRP.

select sale_price, msrp from vehicle_sold vs
inner join vehicle_info vi on vi.vehicle_id = vs.vehicle_id
where sale_price< (msrp*50)/100;











