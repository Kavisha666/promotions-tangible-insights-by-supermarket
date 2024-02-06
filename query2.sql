select * from fact_events;

Update fact_events         /* updating revenuee values in fact events table based on base price and quantity sold before discont  */
set Revenuee = base_price*`quantity_sold(before_promo)`;

alter table fact_events   /* add new discont column which holds a discount price for promotype*/
add column discount int;

update  fact_events       /*calculate discount price on every base price*/
set discount = base_price/2 where promo_type = "BOGOF" ;

update fact_events
set discount = base_price * 0.33 where promo_type = "33% OFF" ;

update fact_events
set discount = base_price * 0.25 where promo_type = "25% OFF" ;

update fact_events
set discount = base_price * 0.50 where promo_type = "50% OFF" ;

update fact_events
set discount = base_price - 500 where promo_type = "500 Cashback" ;

select* from fact_events;

alter table fact_events               /*Adding new column revenue ADP , which multiply the discount prices and quantity sold after promo*/
add column Revenue_ADP int;

update fact_events
set Revenue_ADP = discount * `quantity_sold(after_promo)`;

select* from fact_events;

alter table fact_events               /*Adding new column IR, which doing Revenue_ADP - Revenuee*/
add column IR int;

update fact_events
set IR = Revenue_ADP - Revenuee ;

select* from fact_events;

alter table fact_events               /*Adding new column IR, which doing `quantity_sold(after_promo)` - `quantity_sold(before_promo)`*/
add column ISU int;

update fact_events
set ISU =`quantity_sold(after_promo)` - `quantity_sold(before_promo)` ;

select* from fact_events;


SELECT product_code, product_name       /*1.List of products which has a base price >+500 and promotype as bogof */
FROM dim_products                         /*Which helps to identify the high value product that are heavily discounted*/
WHERE product_code IN (
    SELECT product_code
    FROM fact_events
    WHERE base_price >= 500 AND promo_type = 'BOGOF'
);


select city , count(store_id) as" Number_of_stores"   /*2. display a total number of stores in each city in desc order*/
from dim_stores
group by city
order by number_of_stores desc ;


 
select  dc.campaign_name,                /*3.Returns a revenue before and after promotion in the field of campaign name*/
    SUM(fe.Revenuee)/1000000 AS Revenue_BDP_Million,
    SUM(fe.Revenue_ADP)/1000000 AS Revenue_ADP_million
FROM 
    dim_campaigns dc
JOIN 
    fact_events fe ON dc.campaign_id = fe.campaign_id
GROUP BY 
    dc.campaign_name;
    
    
SELECT 
    dc.category,                /*4.Returns a revenue before and after promotion in the field of campaign name*/
    SUM(fe.IR)/1000000 AS Incremental_Revenue,
    RANK()OVER (ORDER BY sum(fe.IR) DESC)as ranks
FROM 
    dim_products dc
JOIN 
    fact_events fe ON dc.product_code = fe.product_code
    where fe.campaign_id ="CAMP_DIW_01"
GROUP BY 
    dc.category;
    


SELECT 
    dc.product_name,dc.category,                /*5.Returns a revenue before and after promotion in the field of campaign name*/
    SUM(fe.IR)/1000000 AS Incremental_Revenues
FROM 
    dim_products dc
JOIN 
    fact_events fe ON fe.product_code = dc.product_code
GROUP BY 
    dc.product_code;
    
 










