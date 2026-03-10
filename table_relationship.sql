alter table customers
add primary key (sale_id);


alter table inventory_details
add constraint inventory_fk_customer foreign key (sale_id)
 references customers(sale_id);
 
 select count(sale_id) from inventory_details
 where sale_id not in (select sale_id from customers);
 
 delete from inventory_details
 where sale_id not in (select sale_id from customers);
 
 alter table vehicle_sold
 add constraint VehicleSold_fk_customers foreign key (sale_id) references customers(sale_id);
 
  select sale_id from vehicle_sold
 where sale_id not in (select sale_id from customers);
 
delete from vehicle_sold
where sale_id not in (select sale_id from customers);


select count(*) from
  (select vehicle_id, count(vehicle_id) from vehicle_sold
  group by 1
 having count(vehicle_id)>1) as duplicates;
 
 
 alter table vehicle_info
 add primary key (vehicle_id);
 
 
 alter table vehicle_sold
 add constraint vehicleSold_fk_vehicleInfo foreign key (vehicle_id) references vehicle_info(vehicle_id);
 
 
 
 
 
 
 
 


