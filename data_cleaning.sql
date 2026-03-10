-- check duplicates in customer table
 
SELECT 
    sale_id, COUNT(*)
FROM
    vehicle_sales.customers
GROUP BY 1
HAVING COUNT(*) > 1;
 
 
 -- check how many duplicates are there in customer table
 
   SELECT 
    COUNT(sale_id)
FROM
    (SELECT 
        sale_id
    FROM
        vehicle_sales.customers
    GROUP BY 1
    HAVING COUNT(*) > 1) customers;
 
 
 -- delete duplicates from customer table
 
DELETE c1 FROM customers c1
        JOIN
    (SELECT 
        sale_id
    FROM
        customers
    GROUP BY sale_id
    HAVING COUNT(*) > 1) c2 ON c1.sale_id = c2.sale_id;
 
 
 -- check empty fields in customer table
 
SELECT 
    *
FROM
    vehicle_sales.customers
WHERE
    sale_id = '' OR customer_name = ''
        OR contact_info = '';
 
 
 -- Standardize region in inventory_details table
 
UPDATE inventory_details 
SET 
    region = CASE
        WHEN region = 'NORTH' THEN 'North'
        WHEN region = 'south' THEN 'South'
        WHEN region = 'EAST-Region' THEN 'East'
    END;
 
 
 
 -- Check how many null count are there in region (inventory_details )
 
SELECT 
    COUNT(*)
FROM
    inventory_details
WHERE
    region IS NULL;
 
 
 
  -- Deal with null values
 
    SELECT 
    region, COALESCE(region, 'Unknown') AS region
FROM
    inventory_details;
 
 
 -- Update null values with Unknown
 
    UPDATE inventory_details 
SET 
    region = COALESCE(region, 'Unknown');
    
    
-- Clean Mileage (Remove 'km' and handle non-numeric)

UPDATE inventory_details 
SET 
    mileage = REPLACE(LOWER(mileage), 'km', '')
WHERE
    mileage LIKE '%km%';


-- Update blank values with 0 

UPDATE inventory_details 
SET 
    mileage = 0
WHERE
    mileage = '';

-- TYPE CASTING
-- Text to integer
alter table inventory_details
modify column mileage int;

-- Text to integer
alter table vehicle_info
modify msrp int;

-- Text to integer
alter table vehicle_sold
modify sale_price int;

-- check negative (-) values in  vehicle sold table.

SELECT 
    days_on_lot
FROM
    vehicle_sold
WHERE
    days_on_lot LIKE '%-%';

 -- Standardize days on lot (remove negative sign from vehicle sold table).

UPDATE vehicle_sold 
SET 
    days_on_lot = REPLACE((days_on_lot), '-', '')
WHERE
    days_on_lot LIKE '%-%';

-- Delete sale_id from inventory details which are not present in customers. 

 DELETE FROM inventory_details 
WHERE
    sale_id NOT IN (SELECT 
        sale_id
    FROM
        customers);
 
 -- Delete sale_id from vehicle sold which are not present in customers.
 
 DELETE FROM vehicle_sold 
WHERE
    sale_id NOT IN (SELECT 
        sale_id
    FROM
        customers);

-- Add Primary Key in customers table (sale_id).

alter table customers
add primary key (sale_id);

-- Add foreign Key in inventory details table (sale_id).

alter table inventory_details
add constraint inventory_fk_customer foreign key (sale_id)
references customers(sale_id);
 
-- Add foreign Key in vehicle sold table (sale_id).

 alter table vehicle_sold
 add constraint VehicleSold_fk_customers foreign key (sale_id) references customers(sale_id);
 
 -- Add Primary Key in vehicle info table (vehicle_id).
 alter table vehicle_info
 add primary key (vehicle_id);
 
 -- Add foreign Key in vehicle sold table (vehicle_id).
 
 alter table vehicle_sold
 add constraint vehicleSold_fk_vehicleInfo foreign key (vehicle_id) references vehicle_info(vehicle_id);

 
 
 
 


