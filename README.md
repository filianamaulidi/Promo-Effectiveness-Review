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
create table q3_q4_review (
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
```

**Insert Data with CTE and Insert with Select Statement**

Anyway, CTE is used to clearly structure the process of joining and transforming data from multiple tables. It made the query easier to read and allowed for a clean insertion into the Q3_Q4_Review table.

```js
--CTE
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


--Insert with Select
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
from data_promo;
```

**Display the table**
```js
select * from q3_q4_review;
```

## Task 3: Summarize and visualize key insights from Q3 and Q4
Export the Q3_Q4_Review table to csv file. By using Pivot Table and Pivot Chart, we can visualize the sales performance for Q3 and Q4 of 2022. Below are some charts that summarize the effectiveness of promo codes to sales performance.


**Sales Performance Dashboard**
<img width="1748" height="656" alt="dash (abu)" src="https://github.com/user-attachments/assets/f6f8be9f-023d-4a4b-ae85-647419e46dc9" />


This dashboard summarizes the sales performance of a marketplace during Q3–Q4 2022 (July to December), with a specific focus on evaluating the impact of promo codes across three key metrics: total revenue, quantity sold, and transaction count.

The visualizations clearly show that promo-driven sales consistently outperformed non-promo sales across all indicators. Notable peaks occurred in August, October and December, coinciding with seasonal momentum and a higher number of promo codes issued. The ratio-based charts also highlight how promo-related sales dominated in volume and value, particularly in December, where the gap was most significant.

A total of 7 promo campaigns were launched during Q3–Q4, contributing to Rp1.18 billion in promo-driven revenue with a conversion rate of 54.24%. It means, over half of all promo codes offered led to actual purchases. Among the three discount tiers, low-tier discounts contributed the most to revenue (78.92%), largely driven by Gratis_Ongkir, which alone accounted for 4 out of every 5 rupiah in that category due to its daily presence. The top 3 most-used promo codes were Gratis_Ongkir, End_Year, and Christmas, showing strong traction with customers and higher checkout rates during high-traffic periods.

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

Export data to CSV file, so that the label creation can be processed. Labels criteria is 2 across and 5 down. More detailed steps to create shipping label using Ms. Words is written below:
+ **Connect the worksheet label:**  Mailings > Start Mail Merge > Select Recipients > Use an Existing File > Select Data Source > Select excel file containing data for labels.
+ **Add mail merge:** Mailings > Write & Insert Fields > Address Block > Match Fields > Click ‘OK’ > Write & Insert Labels > Update Labels > Finish & Merge > Edit Individual Documents > Select All > Click ‘OK’.

The result:

![label final](https://github.com/user-attachments/assets/fd72a3e4-5f90-4be7-8196-35efc9606ba2)

**Note:** This preview displays only the first page of the full set of generated shipping labels.



# Market Strategy
From what we get from the analysis, there are several market strategies that can be applied to boost future sales performance:
+ **Optimize Year-End Campaigns**: Leverage high-impact periods like December by increasing promo code offerings. For example, create a bundle promo codes with year-end events (e.g., Christmas, New Year, school holidays) to maximize conversion.
+ **Double Down on High-Frequency, Low-Tier Promos**: Low-tier discounts like Gratis_Ongkir proved to be the most effective, contributing ~80% of promo-driven revenue. Their success lies in daily exposure and consistent usage. Keep these running as core offers to drive steady engagement at minimal cost.
+ **Maximize Social Media Exposure**: Focus on platforms where the target audience is most active (e.g., Instagram, TikTok) to drive engagement. Utilize targeted social media ads to promote active campaigns and seasonal promo codes. We can also collaborate with influencers to expand brand visibility, especially during high-potential months like August and December.
+ **Strategically Boost High-Tier Promos**: Although high-tier discounts are rarely used, they show strong potential. To avoid margin loss, run them as limited-time flash deals during peak shopping periods (e.g. Harbolnas or Payday) to create urgency and maximize impact.
+ **Leverage the Promo Conversion Rate**: With over half of buyers checking out using a promo, there’s strong interest to tap into. Consider launching follow-up deals, segmented re-offers, loyalty program, or exclusive vouchers to keep promo-driven users coming back.
+ **Expand Mid-Year Promotions**: August showed strong results with only three promo codes. Consider creating special campaigns (e.g., Back-to-School, Mid-Year Sale) during this time to boost Q3 performance.

# Conclusion
The analysis shows that promo codes significantly impact total sales and revenue, especially when aligned with seasonal moments like year-end events. Transactions, quantity sold, and revenue consistently increased with promo usage, reflecting their effectiveness in driving customer interest.

This growth also correlates with months offering more promo codes than the average, as seen in August, October, and December. Promo usage ratios further confirm that both the presence and volume of promos influence buyer behavior. 

Low-tier discounts contributed the most revenue, while high-tier offers showed potential when timed strategically. With a 54% promo conversion rate, customer responsiveness is evident and actionable.

With the right strategy and timing, promo campaigns can meaningfully boost performance. With these insights, the marketplace can better design future campaigns to drive both revenue and engagement.



# Additional Queries
```js
--Number of Promo Offered in Q3-Q4 2022
select distinct promo_name from q3_q4_review
where purchase_date between '2022-07-01' and '2022-12-31';


--Total Revenue with Promo
select sum(sales_after_promo) from q3_q4_review
where apply_promo='YES';


--Promo Conversion Rate
SELECT 
  COUNT(*) FILTER (WHERE apply_promo = 'YES') * 1.0 / COUNT(*) AS promo_conversion_rate
FROM q3_q4_review;


--Contribution per Discount Tier
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


-- Promo Usage Frequency
select promo_name, price_deduction, count(promo_name) as total_used,
case
	when price_deduction <= 10000 then 'Low'
	when price_deduction between 10001 and 15000 then 'Medium'
	else 'High'
end as discount_tier
from q3_q4_review
group by promo_name, price_deduction, discount_tier
order by total_used desc;
```
