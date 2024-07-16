SELECT User FROM mysql.user;

SHOW GRANTS FOR 'sys_temp'@'172.21.0.1';

SELECT CURRENT_USER();

-- --------------------------------------

SELECT * FROM  INFORMATION_SCHEMA.PARTITIONS
where TABLE_schema = 'sakila'

    
select table_name, column_name from information_schema.key_column_usage
where TABLE_schema = 'sakila' and CONSTRAINT_name = 'PRIMARY'    
    ;
    
   
--    SQL. Часть 1 ------------------------
-- 1)
   
SELECT distinct district from sakila.address a 
WHERE (district like 'K%a') and (district not like '% %');

select distinct district from sakila.address a 
WHERE district REGEXP '^K[a-zA-Z]*a$';

-- 2)
select * from sakila.payment c 
where amount > 10
and payment_date >= '2005-06-15 00:00:00' 
and payment_date < '2005-06-19 00:00:00';


select * from sakila.payment c 
where amount > 10
and payment_date BETWEEN '2005-06-15 00:00:00' and '2005-06-18 23:59:59'

-- 3)
select * from sakila.rental c
order by rental_date desc, rental_id desc
limit 5;

-- 4)

select REGEXP_REPLACE(LOWER(first_name), 'll','pp') first_name, 
REGEXP_REPLACE(LOWER(last_name), 'll','pp') last_name from sakila.customer
where active = 1 
and first_name REGEXP '(Kelly|Willie)' or last_name REGEXP '(Kelly|Willie)'

-- 5)
select SUBSTRING_INDEX(email, '@', 1) nick, SUBSTRING_INDEX(email, '@', -1) host from sakila.customer;

select  REGEXP_SUBSTR(email, '.*(?=@)') nick, REGEXP_SUBSTR(email, '(?<=@).*') host from sakila.customer;

-- 6)
with t as 
	(select
	REGEXP_SUBSTR(email, '.*(?=@)') nick,
	REGEXP_SUBSTR(email, '(?<=@).*') host
	from sakila.customer)
select *,
	CONCAT(LEFT(nick,1),
			REGEXP_SUBSTR(
				LOWER(nick), '(?<=[a-z]).*')) nick_modern_0, 
--
	CONCAT(LEFT(nick,1),
			LOWER(
				RIGHT(nick, LENGTH(nick)-1))) nick_modern_1
from t;

--    SQL. Часть 2 ------------------------
-- 1)

with t as 
	(select count(DISTINCT(customer_id)) count_c, store_id
	from sakila.customer c 
	group by store_id
	),
	store as 
	(select store_id, count_c from t
	 where count_c>300
	 )
select 
sf.first_name ,
sf.last_name ,
c.city ,
t.count_c customers_count
from store t
	left join sakila.store s on s.store_id = t.store_id
	left join sakila.address a on a.address_id = s.address_id 
	left join sakila.city c on c.city_id=a.city_id 
	left join sakila.staff sf on sf.store_id =t.store_id
	
-- 2)
with avg_length as	
	(
	select avg(length) avg_length from sakila.film
	)
select 
	count(DISTINCT(film_id)) count_long_films
from sakila.film f 
	where length > (select avg_length from avg_length)
	
-- 3)
with month_number as
	(
	select LAST_DAY(payment_date) mothday from sakila.payment p 
	group by LAST_DAY(payment_date)
	order by sum(amount) DESC limit 1
	)
select 
	(select DATE_ADD(mothday, interval 1-day(mothday) day) start_of_month from month_number) month,
	count(rental_id) rental_count
from sakila.rental r 
where LAST_DAY(rental_date) = (select mothday from month_number)

-- 4)
select 
staff_id, 
case 
	when
		cnt>8000 then "Да"
	else "Нет" 
end 'Премия'
from 
	(select staff_id, count(DISTINCT(payment_id)) cnt
	from sakila.payment p 
	group by staff_id ) t
	
-- 5)
explain(
with 
 rental_id as 
 	(select DISTINCT rental_id from sakila.payment p),
 inventory_id as
	 (select DISTINCT inventory_id from sakila.rental r where rental_id in (select * from rental_id)),
 film_id as
	 (select film_id from sakila.inventory i where i.inventory_id in (select * from inventory_id))
select * from sakila.film
where film_id not in (select * from film_id)
	)
	
	
explain(
with 
 rental_id as 
 	(select DISTINCT rental_id from sakila.payment p),
 inventory_id as
	 (select DISTINCT inventory_id from sakila.rental r inner join rental_id ri on ri.rental_id=r.rental_id),
 film_id as
	 (select film_id from sakila.inventory i inner join inventory_id ii on ii.inventory_id = i.inventory_id)
select * from sakila.film f
left join film_id fi on fi.film_id = f.film_id 
where fi.film_id IS NULL
	)

	
