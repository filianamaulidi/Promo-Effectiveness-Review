# Promo Effectivenes Review
This portfolio project was created as part of a project-based internship program by Rakamin Academy in collaboration with Jubelio Omnichannel. The goal of the project is to analyze the effectiveness of promo codes on marketplace sales performance during Q3 and Q4 of 2022, and provide strategic recommendations based on data-driven insights.

## Project Background
Every six months, Jubelio Omnichannel conducts a Promo Effectiveness Review to evaluate how promo codes impact total transactions and sales on a specific marketplace. This initiative helps the marketplace assess how effective the promo codes have been throughout months in driving sales and providing valuable insights to guide promo-based sales strategies in the following years.
For this particular review, the company chose to focus the analysis on sales data from the third and fourth quarters (Q3 and Q4), as these periods represent the most active promo campaigns of the year. By narrowing the scope, the analysis aims to capture more accurate insights into how promotional efforts translated into customer activity and sales performance.

## Solution
This analysis was driven by several key objectives aimed at evaluating how promotional efforts contributed to the marketplace performance. Below are the core goals that shaped our analysis.
+ Apply promo codes provided by the Budgeting Team.
+ Create specialized reports for Q3 and Q4.
+ Summarize and visualize key insights from Q3 and Q4 data tables.
+ Generate custom shipping labels for December.

## Tools Used
+ **PostgreSQL:** Used for extracting relevant datasets from multiple tables, including retrieving transaction records for specific dates and generating shipping receipt. It served as the foundation for pulling accurate and filtered data needed for further analysis.
+ **Microsoft Excel:** Used for further process and refine the dataset. Excel’s Pivot Table and Pivot Chart features allowed us to summarize the information clearly and present key trends and metrics through easy-to-read visualizations.


## Database Preparation
Before moving forward with the analysis, we first prepared the necessary database. This preparation stage involved several steps, such as:
+ Database Restore
+ Table Checking
+ ERD Creation


This is the view of final ERD for Database Task5.
![ERD jadi](https://github.com/user-attachments/assets/1acee6ba-372e-42f5-ac77-4b8fbab382b6)

# Solving The Challenges
## Task 1: Apply promo codes provided by the Budgeting Team
**Create promo_code table**
```js
create table promo_code (
promo_id int primary key,
promo_name varchar,
price_deduction int,
Description varchar,
Duration int
);
```
**Importing data**
+ Click database Task5 > Schema > Tables. Right-click on promo_code and click ‘Import/Export Data’. (If the promo_code hasn’t shown up, right-click on Tables and choose ‘Refresh’).
+ On ‘Filename’, choose the file that should be imported.
+ Move to ‘Options’ section. Turn on the ‘Header’ and choose the right delimiter as in the csv file. Then, click ‘OK’.
+ Run this query to view the table:
```js
select * from promo_code;
```

## Task 2: Create specialized reports for Q3 and Q4
**Create Q3_Q4_Review table**
```js
create table q3_q4_Review (
purchase_date date,
item_name varchar,
price bigint,
quantity int,
total_price bigint,
apply_promo varchar,
sales_after_promo bigint
);
```

**Insert Data with CTE and Insert with Select Statement**
```js
with data_promo as (
select 
	s.purchase_date,
	m.item_name,
	m.price,
	s.quantity,
	sum(m.price * s.quantity) as total_price,
	coalesce (p.promo_name, 'NO') as apply_promo,
	coalesce((sum (m.price * s.quantity) - (p.price_deduction)), 0) 
	as sales_after_promo
from sales_table s
left join marketplace_table m on s.item_id = m.item_id
left join promo_code p on s.promo_id = p.promo_id
where purchase_date >= '2022-07-01' and purchase_date <= '2022-12-31'
group by purchase_date, item_name, price, quantity, promo_name, 
price_deduction
order by purchase_date
)

insert into q3_q4_review
select purchase_date,
item_name,
price,
quantity,
total_price,
case when apply_promo = 'NO' then 'NO' else 'YES'
end as promo_code,
sales_after_promo
from data_promo;
```

**Display the table**
```js
select * from q3_q4_review;
```

## Task 3: Summarize and visualize key insights from Q3 and Q4
Export the Q3_Q4_Review table to csv file. By using Pivot Table and Pivot Chart, we can visualize the sales performance for Q3 and Q4 of 2022. Below are some charts that summarize the effectiveness of promo codes to sales performance.


**Sales Performance Dashboard**
![Dashboard Promo](https://github.com/user-attachments/assets/b4643acc-85ac-43dd-becc-ffa6c165cdb6)
This dashboard summarizes the sales performance of a marketplace during Q3–Q4 2022 (July to December), with a specific focus on evaluating the impact of promo codes across three key metrics: total revenue, quantity sold, and transaction count.

The visualizations clearly show that promo-driven sales consistently outperformed non-promo sales across all indicators. Notable peaks occurred in August, October and December, coinciding with seasonal momentum and a higher number of promo codes issued. The ratio-based charts also highlight how promo-related sales dominated in volume and value, particularly in December, where the gap was most significant.

These insights suggest that well-executed promo campaigns, especially when aligned with high-traffic periods, can significantly boost both customer engagement and business performance.

## Task 4: Generate custom shipping labels for December
**Create shipping_summary table**
```js
create table shipping_summary (
shipping_date date,
seller_name varchar,
buyer_name varchar,
buyer_address varchar,
buyer_city varchar,
buyer_zipcode int,
kode_resi varchar
);
```

**Insert Data with CTE and Insert with Select Statement**
```js
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
```

**Display the table**
```js
select * from shipping_summary;
```

Export data to CSV file, so that the label creation can be processed.


# Market Strategy
From what we get from the analysis, there are several market strategies that can be applied to boost future sales performance:
+ **Optimize Year-End Campaigns**: Leverage high-impact periods like December by increasing promo code offerings. For example, create a bundle promo codes with year-end events (e.g., Christmas, New Year, school holidays) to maximize conversion.
+ **Exclusice Loyalty Voucher**: Reward customers who shop consistently over multiple months long-term engagement. For example, customers who make at least five purchases per month for three consecutive months, with a minimum monthly spend of IDR 500,000, will receive an exclusive 50% discount voucher applicable to their next five transactions.
+ **Maximize Social Media Exposure**: Focus on platforms where the target audience is most active (e.g., Instagram, TikTok) to drive engagement. Utilize targeted social media ads to promote active campaigns and seasonal promo codes. We can also collaborate with influencers to expand brand visibility, especially during high-potential months like August and December.
+ **Implement Time-Limited & Quota-Based Promo Codes**: Offer promo codes valid for a limited number of transactions per day (e.g., first 200 checkouts), especially during peak user activity hours such as 12:00–14:00 (lunch break) or 19:00–21:00 (evening screen time). Plus, add real-time reminders or countdowns on the product page or checkout screen (e.g., “Only 20 promo codes left!”) to create urgency and drive faster conversions.
+ **Expand Mid-Year Promotions**: August showed strong results with only three promo codes. Consider creating special campaigns (e.g., Back-to-School, Mid-Year Sale) during this time to boost Q3 performance.

# Conclusion
The analysis clearly shows that promo codes have a strong impact on the marketplace’s total sales and revenue, especially when aligned with seasonal moments like year-end events. The number of transactions, the quantity of items sold, and total revenue all showed consistently higher results with the use of promo codes, highlighting their effectiveness in attracting customer interest and encouraging purchases. Besides seasonal factors, this sales growth also corresponds with the higher number of promo codes issued during those months that is exceeding the average of two promo codes per month.
With the right combination of promo strategies and timing, sales performance can increase significantly. To further optimize future sales performance, several marketing strategies can be considered: enhancing end-of-year campaigns, introducing exclusive loyalty programs, increasing social media exposure, launching time-limited and quota-based promo codes, and expanding mid-year promotional efforts.


