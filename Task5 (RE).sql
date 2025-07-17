-- tabel dari file restore (Task5_DB)
select * from buyer_table;
select * from marketplace_table;
select * from sales_table;
select * from seller_table;
select * from shipping_table;

--buat tabel baru promo_code
create table promo_code (
promo_id int primary key,
promo_name varchar,
price_deduction int,
Description varchar,
Duration int
);

select * from promo_code;


--buat tabel Q3_Q4_Review 
create table q3_q4_Review (
purchase_date date,
item_name varchar,
category varchar,
price bigint,
quantity int,
total_price bigint,
apply_promo varchar,
promo_name varchar,
price_deduction bigint,
sales_after_promo bigint
);
select * from q3_q4_review;


--CTE buat Q3_Q4_Review 
with data_promo as (
select 
	s.purchase_date,
	m.item_name,
	m.category,
	m.price,
	s.quantity,
	sum(m.price * s.quantity) as total_price,
	coalesce (p.promo_name, 'NO') as apply_promo,
	p.promo_name,
	p.price_deduction,
	coalesce((sum (m.price * s.quantity) - (p.price_deduction)), 0) 
	as sales_after_promo
from sales_table s
left join marketplace_table m on s.item_id = m.item_id
left join promo_code p on s.promo_id = p.promo_id
where purchase_date >= '2022-07-01' and purchase_date <= '2022-12-31'
group by purchase_date, item_name, price, quantity, 
promo_name, price_deduction, category
order by purchase_date
)

insert into q3_q4_review
select purchase_date,
item_name,
category,
price,
quantity,
total_price,
case when apply_promo = 'NO' then 'NO' else 'YES'
end as promo_code,
promo_name,
price_deduction,
sales_after_promo
from data_promo4;

select * from q3_q4_review; 


--% kontribusi kategori ke total revenue (PAKE CTE)
 --ada dua CTE, kontribusi sama total
 --total revenue di kontribusi ngitung per kategori
 --total revenue di total jumlahin revenue di semua kategori (total)
 with kontribusi as (
 select 
 case
 	when price_deduction <= 10000 then 'Low'
	when price_deduction between 10001 and 15000 then 'Medium'
	else 'High'
 end as discount_tier,
 count (*) as transaction_count,
 sum(total_price) as total_revenue
 from q3_q4_review
 where price_deduction is not null
 group by discount_tier
 order by total_revenue desc
),
total as (
select sum(total_revenue) as grand_total from kontribusi
)
SELECT 
  k.discount_tier,
  k.transaction_count,
  k.total_revenue,
  ROUND((k.total_revenue::numeric / t.grand_total) * 100, 2) AS revenue_contribution_percent
FROM kontribusi k, total t
ORDER BY k.total_revenue DESC;


--promo conversion rate
SELECT 
  COUNT(*) FILTER (WHERE apply_promo = 'YES') * 1.0 / COUNT(*) AS promo_conversion_rate
FROM q3_q4_review;

--promo usage frequency
select promo_name, price_deduction, count(promo_name) as total_used,
case
	when price_deduction <= 10000 then 'Low'
	when price_deduction between 10001 and 15000 then 'Medium'
	else 'High'
end as discount_tier
from q3_q4_review
group by promo_name, price_deduction, discount_tier
order by total_used desc;

--promo impact on avg order value
select apply_promo, sum(total_price) as revenue from q3_q4_review
group by apply_promo;


----Kontribusi per promo_name
WITH kontribusi AS (
  SELECT 
    p.promo_name,
    COUNT(*) AS transaction_count,
    SUM(q.total_price) AS total_revenue
  FROM q3_q4_review q
  LEFT JOIN promo_code p ON q.promo_name = p.promo_name
  WHERE q.price_deduction IS NOT NULL
  GROUP BY p.promo_name
),
total AS (
  SELECT SUM(total_revenue) AS grand_total FROM kontribusi
)
SELECT 
  k.promo_name,
  k.transaction_count,
  k.total_revenue,
  ROUND((k.total_revenue::numeric / t.grand_total) * 100, 2) AS revenue_contribution_percent
FROM kontribusi k, total t
ORDER BY k.total_revenue DESC;


--itung jumlah promo
select distinct promo_name from q3_q4_review
where purchase_date between '2022-07-01' and '2022-12-31';

--itung total revenue with promo
select sum(sales_after_promo) from q3_q4_review
where apply_promo='YES';

--kategorisasi promo
select promo_name, price_deduction,
case
 when price_deduction < 10000 then 'Low'
 when price_deduction between 10001 and 15000 then 'Medium'
 else 'high'
end as discount_tier
from q3_q4_review
group by discount_tier, promo_name, price_deduction
order by discount_tier desc;


--buat tabel baru shipping_summary
create table shipping_summary (
shipping_date date,
seller_name varchar,
buyer_name varchar,
buyer_address varchar,
buyer_city varchar,
buyer_zipcode int,
kode_resi varchar
);
select * from shipping_summary;

--apply CTE untuk shipping_summary (khusus Desember 2022)
with shipping_summary2 as (
select
	sh.shipping_date,
	s.seller_name,
	b.buyer_name,
	b.address as buyer_address,
	b.city as buyer_city,
	b.zipcode as buyer_zipcode,
	concat(sh.shipping_id, '-', 
		to_char (sh.purchase_date, 'YYYYMMDD'), '-',
		to_char (sh.shipping_date, 'YYYYMMDD'), '-',
		b.buyer_id, '-', 
		s.seller_id) as kode_resi
from shipping_table sh
left join seller_table s on sh.seller_id = s.seller_id
left join buyer_table b on sh.buyer_id = b.buyer_id
where shipping_date between '2022-12-01' and '2022-12-31'
order by shipping_date
)

insert into shipping_summary
select * from shipping_summary2;

select * from shipping_summary;

