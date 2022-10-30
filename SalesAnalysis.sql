-- Inspecting Data

select *
from [Project - Sales Data].[dbo].sales_data_sample

-- Checking for unique values

select distinct STATUS from sales_data_sample -- Great one to plot
select distinct YEAR_ID from sales_data_sample
select distinct PRODUCTLINE from sales_data_sample -- Great to plot
select distinct COUNTRY from sales_data_sample -- Great to plot
select distinct DEALSIZE from sales_data_sample -- Great to plot
select distinct TERRITORY from sales_data_sample -- Great to plot


----------------------------- ANALYSIS
-- Group Sales by Product Line
-- Classic Cars are the best selling

Select productline, sum(sales) revenue
from [Project - Sales Data].[dbo].sales_data_sample
group by productline
order by revenue desc
------------------------------------------------------------------------------------------------------
-- Big drop in sales for year 2005, after running a distinct query on month_id in 2005,
-- they only operated for 5 months in 2005 where in 2003 and 2004 they operated for the whole year

Select year_id, sum(sales) revenue
from [Project - Sales Data].[dbo].sales_data_sample
group by year_id
order by revenue desc
-------------------------------------------------------------------------------------------------------
Select DEALSIZE, sum(sales) revenue
from [Project - Sales Data].[dbo].sales_data_sample
group by DEALSIZE
order by revenue desc


-------------------------------------------------------------------------------------------------------
-- What was the best month for sales in a specific year? How much was earned that month?

select month_id, sum(sales) revenue, count(ORDERNUMBER) Frequency
from [Project - Sales Data].[dbo].sales_data_sample
where year_id = 2003 -- Change this to see the rest
group by month_id
order by revenue desc

-- November seems to be the best month
-- What product do they sell most in November, possibly classic cars

select month_id, productline, sum(sales) revenue, count(ORDERNUMBER) Frequency
from [Project - Sales Data].[dbo].sales_data_sample
where year_id = 2003 and month_id = 11 -- Change this to see the rest
group by month_id, productline
order by revenue desc

-- Who is our best customer? Using Recency, Frequency and Monetary (RFM)
DROP TABLE IF EXISTS #RFM
;with RFM as
(
	select 
		customername Customer, 
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ordernumber) Frequency,
		Max(orderdate) last_time_ordered,
		(select max(orderdate) from [Project - Sales Data].[dbo].sales_data_sample) as max_order_date,
		DATEDIFF(DD,Max(orderdate),(select max(orderdate) from [Project - Sales Data].[dbo].sales_data_sample)) as RecencyInDays
	from [Project - Sales Data].[dbo].sales_data_sample
	group by customername
),
rfm_calc as 
(
	select r.*,
		NTILE(4) OVER (order by RecencyInDays DESC) as RFM_Recency,
		NTILE(4) OVER (order by Frequency) as RFM_Frequency,
		NTILE(4) OVER (order by MonetaryValue) as RFM_Monetary
	from RFM r
)
select c.*, 
	RFM_Recency + RFM_Frequency + RFM_Monetary as RFM_CELL,
	cast(RFM_Recency as varchar) + cast(RFM_Frequency as varchar) + cast(RFM_Monetary as varchar) as RFM_String
into #rfm
from rfm_calc c

Select Customer, RFM_Recency, RFM_Frequency, RFM_Monetary,
	Case
		when RFM_String in (111, 112, 121, 122, 132, 211, 212, 114, 141) then 'lost costumer'
		when RFM_String in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping awawy, Can not lose'
		when RFM_String in (311, 411, 331) then 'new customers'
		when RFM_String in (222, 223, 233, 322) then 'potential customers'
		when RFM_String in (323, 333, 321, 422, 332, 432) then 'active'
		when RFM_String in (433, 434, 443, 444) then 'loyal'
	end RMF_Segment
from #RFM


-- What products are often sold together?
select DISTINCT ordernumber, stuff(
	(Select ',' + productcode
	from [Project - Sales Data].[dbo].sales_data_sample p
	where ordernumber in 
		(
			Select Ordernumber
			From
			(
 				Select ordernumber, count(*) rn
				from [Project - Sales Data].[dbo].sales_data_sample
				where status = 'shipped'
				group by ordernumber
			)n
			where rn = 2 -------------------------- Change this to see the number of prodcuts ordered together.
		) AND p.ORDERNUMBER = s.ORDERNUMBER
		for xml path ('')), 1, 1,'') ProductCodes

from [Project - Sales Data].[dbo].sales_data_sample s
order by ProductCodes DESC
