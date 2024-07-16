# Домашнее задание к занятию «SQL. Часть 2»

---

Задание можно выполнить как в любом IDE, так и в командной строке.

### Задание 1

Одним запросом получите информацию о магазине, в котором обслуживается более 300 покупателей, и выведите в результат следующую информацию: 
- фамилия и имя сотрудника из этого магазина;
- город нахождения магазина;
- количество пользователей, закреплённых в этом магазине.

```
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
```

![01](https://github.com/SeSloup/DB_requests_2/blob/main/screens/01.png)

### Задание 2

Получите количество фильмов, продолжительность которых больше средней продолжительности всех фильмов.

```
with avg_length as	
	(
	select avg(length) avg_length from sakila.film
	)
select 
	count(DISTINCT(film_id)) count_long_films
from sakila.film f 
	where length > (select avg_length from avg_length)
```
![02](https://github.com/SeSloup/DB_requests_2/blob/main/screens/02.png)

### Задание 3

Получите информацию, за какой месяц была получена наибольшая сумма платежей, и добавьте информацию по количеству аренд за этот месяц.

```
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
```
![03](https://github.com/SeSloup/DB_requests_2/blob/main/screens/03.png)

## Дополнительные задания (со звёздочкой*)
Эти задания дополнительные, то есть не обязательные к выполнению, и никак не повлияют на получение вами зачёта по этому домашнему заданию. Вы можете их выполнить, если хотите глубже шире разобраться в материале.

### Задание 4*

Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 8000, то значение в колонке будет «Да», иначе должно быть значение «Нет».

```
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
```
![04](https://github.com/SeSloup/DB_requests_2/blob/main/screens/04.png)

### Задание 5*

Найдите фильмы, которые ни разу не брали в аренду.

```
with 
 rental_id as 
 	(select rental_id from sakila.payment p),
 inventory_id as
	 (select inventory_id from sakila.rental r where rental_id in (select * from rental_id)),
 film_id as
	 (select film_id from sakila.inventory i where i.inventory_id in (select * from inventory_id))
select * from sakila.film
where film_id not in (select * from film_id)	
```

```
with 
 rental_id as 
 	(select rental_id from sakila.payment p),
 inventory_id as
	 (select inventory_id from sakila.rental r inner join rental_id ri on ri.rental_id=r.rental_id),
 film_id as
	 (select film_id from sakila.inventory i inner join inventory_id ii on ii.inventory_id = i.inventory_id)
select * from sakila.film f
left join film_id fi on fi.film_id = f.film_id 
where fi.film_id IS NULL
```

```
with 
 rental_id as 
 	(select rental_id from sakila.payment p),
 inventory_id as
	 (select inventory_id from sakila.rental r inner join rental_id ri on ri.rental_id=r.rental_id),
 film_id as
	 (select film_id from sakila.inventory i inner join inventory_id ii on ii.inventory_id = i.inventory_id)
select * from 
	(select film_id from sakila.film f
	except
	select film_id from film_id fi) t 
left join sakila.film f on t.film_id = f.film_id;
```
![05](https://github.com/SeSloup/DB_requests_2/blob/main/screens/05.png)


-----------------------------------------------------------
Спасибо за проверку! 🍊
