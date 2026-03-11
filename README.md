# Vehicle Sales & Inventory Analysis

<img width="1005" height="603" alt="dashboard" src="https://github.com/user-attachments/assets/17cb4437-0efc-498b-bca2-4c4f5a44cb0d" />


## Objectives

The primary goal of this project is to transform raw sales data into actionable business intelligence. Specifically, the objectives are:

**Data Aggregation:** To consolidate disparate sales data into a structured SQL database.

**Performance Tracking**: To measure Key Performance Indicators (KPIs) such as total revenue, unit sales, average deal size, and year-over-year growth.

**Trend Identification:** To visualize sales trends over time (monthly, quarterly, or yearly) and identify seasonality in vehicle purchases.

**Customer & Product Analysis:** To understand which vehicle models are top performers and identify customer segments that drive the most revenue.

**Decision Support:** To create an interactive dashboard that allows stakeholders to filter data by region, sales representative, or vehicle category.

## 📌 Project Overview

**Project Title**: Vehicle Sales & Inventory Analysis

**Database**: `vehicle_sales`

The database consists of four interconnected tables:

**`customers`**: Buyer details and transaction links.

**`vehicle_info`**: Specifications (Vehicle id, Model, Make, Year,Body Type, Fuel Type, MSRP).

**`vehicle_sold`**: Sales data (Sale id, Vehicle id, Sale Price, Days on Lot).

**`inventory_details`**: Logistical data (Sale id, Region, Mileage).


## 🛠️ Data Cleaning & Structural Integrity

The following steps were performed to ensure the data is accurate and the database is relational.

### 1. Handling Duplicates & Errors

```sql
-- Remove duplicates from customers table
DELETE c1 FROM customers c1
JOIN (SELECT sale_id FROM customers GROUP BY sale_id HAVING COUNT(*) > 1) c2 
ON c1.sale_id = c2.sale_id;

-- Standardize regions
UPDATE inventory_details SET region = CASE
    WHEN region = 'NORTH' THEN 'North'
    WHEN region = 'south' THEN 'South'
    WHEN region = 'EAST-Region' THEN 'East'
END;

-- Update vehicle info (fuel_type where model is GLC, year 2022, and body_type SUV)
UPDATE vehicle_info 
SET 
    fuel_type = 'Gasoline'
WHERE
    model = 'GLC' AND `year` = 2022
        AND body_type = 'SUV';

-- Update vehicle info (fuel_type where model is equinox, year 2022, and  body_type SUV )
UPDATE vehicle_info 
SET 
    fuel_type = 'Gasoline'
WHERE
    model = 'equinox' AND `year` = 2022
        AND body_type = 'SUV';

-- Handle Null/Blank values
UPDATE inventory_details
SET
     region = COALESCE(region, 'Unknown');

UPDATE inventory_details
SET
    mileage = 0
WHERE
    mileage = '';

-- Correct negative signs in days_on_lot
UPDATE vehicle_sold
SET
    days_on_lot = REPLACE(days_on_lot, '-', '')
WHERE
    days_on_lot LIKE '%-%';
```

### 2. Type Casting & Schema Definition

```sql
-- Convert text columns to integers
ALTER TABLE inventory_details MODIFY COLUMN mileage INT;
ALTER TABLE vehicle_info MODIFY msrp INT;
ALTER TABLE vehicle_sold MODIFY sale_price INT;

-- Define Primary and Foreign Keys
ALTER TABLE customers ADD PRIMARY KEY (sale_id);
ALTER TABLE vehicle_info ADD PRIMARY KEY (vehicle_id);

ALTER TABLE inventory_details ADD CONSTRAINT inventory_fk_customer FOREIGN KEY (sale_id) REFERENCES customers(sale_id);
ALTER TABLE vehicle_sold ADD CONSTRAINT VehicleSold_fk_customers FOREIGN KEY (sale_id) REFERENCES customers(sale_id);
ALTER TABLE vehicle_sold ADD CONSTRAINT vehicleSold_fk_vehicleInfo FOREIGN KEY (vehicle_id) REFERENCES vehicle_info(vehicle_id);
```

### 3. CRUD Operations

**Create:** Established database schema constraints (Primary/Foreign Keys) to allow for safe insertion of new customer, vehicle, and sale records.

**Read:** Performed extensive analytical queries across multiple joined tables to retrieve sales performance, profit margins, and inventory status.

**Update:** Standardized and corrected data across the entire database, including updating placeholder prices, fixing regional naming conventions, and cleaning mileage/fuel type values.

**Delete:** Cleaned up the database by removing duplicate information and fixing broken links.

## Section 1: Basic Analysis

**Task 1. Update placeholder sale prices (0-1 range):**

```sql
UPDATE vehicle_sold 
SET 
    sale_price = 58000
WHERE
    sale_price BETWEEN 0 AND 1;
         
```

**Task 2: Total revenue (in Millions):**

```sql
SELECT 
    CONCAT(ROUND(SUM(sale_price) / 1000000, 2), 'M') AS total_revenue
FROM
    vehicle_sold;
```
<img width="119" height="47" alt="image" src="https://github.com/user-attachments/assets/1e2a7dd5-a79c-4aee-9f00-dbe743b5f741" />


**Task 3: Model with highest sales volume:**
  
```sql
SELECT 
    model, SUM(sale_price) AS highest_sales_volume
FROM
    vehicle_info vi
        INNER JOIN
    vehicle_sold vs ON vs.vehicle_id = vi.vehicle_id
GROUP BY 1
ORDER BY highest_sales_volume DESC
LIMIT 1;
```

<img width="203" height="45" alt="image" src="https://github.com/user-attachments/assets/3c8f3f56-b223-49d3-8126-add61d46db5c" />


**Task 4: Average sale price of a vehicle:**
```sql
SELECT 
    ROUND(AVG(sale_price), 2) AS `avg _sale_price`
FROM
    vehicle_sold;
```

<img width="153" height="43" alt="image" src="https://github.com/user-attachments/assets/3782e1d5-ab08-4d82-8aba-8f0fcba897b5" />


**Task 5: Vehicle sales count in 'NORTH' region:**

```sql
SELECT 
    COUNT(vs.sale_id) AS vehicle_sold
FROM
    vehicle_sold vs
        INNER JOIN
    inventory_details id ON id.sale_id = vs.sale_id
WHERE
    region = 'North';
```

<img width="125" height="41" alt="image" src="https://github.com/user-attachments/assets/f6e0919d-55d8-4c81-a0b8-f6d5426cd9f9" />


- **Task 6: Most common body type in inventory:**

```sql
SELECT 
    body_type, COUNT(body_type) AS most_common_body_type
FROM
    vehicle_info
GROUP BY body_type
ORDER BY 2 DESC
LIMIT 1;
```

<img width="268" height="48" alt="image" src="https://github.com/user-attachments/assets/472ae278-923a-4490-85f7-9470a380c2e7" />


## Section 2: Intermediate Analysis

Task 7. **Region with highest average days on lot:**

```sql
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
```

<img width="98" height="45" alt="image" src="https://github.com/user-attachments/assets/74946020-10d7-4b97-9b07-419aec4a2d48" />


Task 8: **Average mileage in the 'WEST' region:**

```sql
 SELECT 
    ROUND(AVG(mileage), 2) AS avg_mileage
FROM
    inventory_details
WHERE
    region = 'west';
```

<img width="128" height="46" alt="image" src="https://github.com/user-attachments/assets/361a838a-8c7a-4f87-8756-b0416312729b" />


9. **Top 10 customers by total purchase value:**
```sql
SELECT 
    customer_name, SUM(sale_price) AS total_purchase
FROM
    customers c
        INNER JOIN
    vehicle_sold vs ON vs.sale_id = c.sale_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

```

<img width="251" height="196" alt="image" src="https://github.com/user-attachments/assets/d410df51-8598-477e-b26c-e4eeb9cd9e08" />


10. **Average Discount/Premium for Electric Vehicles:**

```sql
 SELECT
    ROUND(AVG(sale_price - msrp), 2) avg_price_difference
FROM
    vehicle_info vi
        INNER JOIN
    vehicle_sold vs ON vi.vehicle_id = vs.vehicle_id
WHERE
    fuel_type = 'Electric';
```

<img width="165" height="58" alt="image" src="https://github.com/user-attachments/assets/02cec1d7-b423-4fae-a4de-67c75553dec0" />


Task 11. **Fastest selling model year (Lowest avg days on lot):**
```sql
SELECT 
    `year`, AVG(days_on_lot) avg_days
FROM
    vehicle_sold vs
        INNER JOIN
    vehicle_info vi ON vi.vehicle_id = vs.vehicle_id
GROUP BY 1
ORDER BY 2 ASC;

```

<img width="194" height="135" alt="image" src="https://github.com/user-attachments/assets/748b3c89-b1dc-42d0-90bf-824b59a7d825" />


Task 12: List models sold for more than their MSRP:**
```sql
SELECT 
    model, msrp, sale_price
FROM
    vehicle_info vi
        INNER JOIN
    vehicle_sold vs ON vs.vehicle_id = vi.vehicle_id
WHERE
    sale_price > msrp
ORDER BY sale_price DESC;  

```

<img width="199" height="174" alt="image" src="https://github.com/user-attachments/assets/e1c8322d-e5f3-4f8b-b0fb-d1480a5e394e" />


**Task 13: Revenue contribution by fuel type:**  

```sql
SELECT 
    fuel_type, SUM(sale_price) total_revenue
FROM
    vehicle_sold vs
        INNER JOIN
    vehicle_info vi ON vi.vehicle_id = vs.vehicle_id
GROUP BY 1
ORDER BY 2 DESC;

```

<img width="175" height="136" alt="image" src="https://github.com/user-attachments/assets/706d33f9-f65c-4da1-a402-c3c6ffa79846" />


## Section 3: Advanced Business Intelligence

**Task 14: Cumulative revenue (Running Total):**  

```sql
select sale_id , sale_price,
     sum(sale_price) over(order by sale_id) as running_total 
from
     vehicle_sold;
```

<img width="208" height="153" alt="image" src="https://github.com/user-attachments/assets/d988972d-9a2e-48ad-b999-448e4e116c84" />


**Task 15: Combination of model and body type with highest profit margin:**  

```sql

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


```

<img width="253" height="42" alt="image" src="https://github.com/user-attachments/assets/a0f473b3-9623-4dc5-8b2c-334895d82b79" />


**Task 16: Overall Total Profit:**  

```sql
SELECT 
    (total.total_rev - cost.total_cost) AS profit
FROM
    (SELECT 
        SUM(sale_price) total_rev
    FROM
        vehicle_sold) AS total,
    (SELECT 
        SUM(msrp) total_cost
    FROM
        vehicle_info) AS cost;


```

<img width="155" height="52" alt="image" src="https://github.com/user-attachments/assets/1c16d206-2cbb-40f1-9152-e74a784753a6" />


**Task 17: Gross Profit Margin percentage:**  

```sql
SELECT 
    (totals.total_rev - costs.total_cost) / totals.total_rev AS gross_profit_margin
FROM
    (SELECT 
        SUM(sale_price) AS total_rev
    FROM
        `vehicle_sold`) AS totals,
    (SELECT 
        SUM(msrp) AS total_cost
    FROM
        `vehicle_info`) AS costs;

```

<img width="164" height="47" alt="image" src="https://github.com/user-attachments/assets/67d05fbb-667a-409d-8636-63323a361d54" />


**Task 18: High Mileage (>50k) vs Low Mileage (<50k) Lot Days:**  

```sql
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

```
<img width="234" height="75" alt="image" src="https://github.com/user-attachments/assets/ff7366c6-5e56-448b-a39e-9e23f5f20ea7" />


**Task 19: Identify Stale Inventory (>100 days):** Models that average more than 100 days on the lot

```sql
SELECT 
    model, ROUND(AVG(days_on_lot), 2) AS avg_lot_days
FROM
    vehicle_info vi
        INNER JOIN
    vehicle_sold vs ON vs.vehicle_id = vi.vehicle_id
GROUP BY 1
HAVING AVG(days_on_lot) > 100
ORDER BY avg_lot_days DESC;

```

<img width="153" height="173" alt="image" src="https://github.com/user-attachments/assets/74e1736a-b4a6-4e13-bbe9-2c98d9a14464" />


**Task 20: Sales Efficiency by Region (Revenue / Avg Days on Lot):**  

```sql
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

```

<img width="160" height="92" alt="image" src="https://github.com/user-attachments/assets/8d82c775-feec-4125-968a-f187e3741a41" />


**Task 21: What percentage of total sales come from Hybrid/Electric vehicles vs Gasoline?**   

```sql
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

```

<img width="205" height="79" alt="image" src="https://github.com/user-attachments/assets/4e69be3a-b7e3-4e5c-8608-081b91fec5e4" />


**Task 22: Identify potential data entry errors where the sale_price is less than 50% of the MSRP.**   

```sql
SELECT 
    sale_price, msrp
FROM
    vehicle_sold vs
        INNER JOIN
    vehicle_info vi ON vi.vehicle_id = vs.vehicle_id
WHERE
    sale_price < (msrp * 50) / 100;

```

<img width="126" height="92" alt="image" src="https://github.com/user-attachments/assets/4fd718bc-e931-44c6-b71c-1610a92e2a26" />

## How to Improve Sales (Next Steps):

**Predict Demand:** Use historical data to forecast which vehicles will be in high demand, ensuring you don't run out of stock.

**Targeted Marketing:** Identify your most profitable customer segments and create personalized offers for them.

**Optimize Pricing:** Use your data to run "what-if" scenarios—adjusting prices on slow-moving inventory to boost sales volume.

**Performance Training:** Analyze your top sales reps’ strategies and apply those techniques to the rest of the team.

## Conclusion

The analysis confirms that data visualization is essential for spotting sales gaps and understanding customer behavior, proving that centralizing data is the fastest way to improve business efficiency.

- **Instagram**: [Follow me on instagram for daily tips](https://www.instagram.com/bca_wale022/)
- **LinkedIn**: [Connect with me on linkedIn](https://www.linkedin.com/in/nasir-hussain022)
- **Contact**: [Send me an email](mailto:nasirhussainnk172@gmail.com)
