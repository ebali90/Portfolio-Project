/* This is a transnational data set which contains all the transactions occurring 
between 01/12/2010 and 09/12/2011 for a UK-based and registered non-store online retail.

Source : https://archive.ics.uci.edu/ml/machine-learning-databases/00352/
*/
--- Used SSIS to import the data into MySQL

--- Cleaning this Data (541,909 Total Records)
--- Only 406,829 records have customerID


With online_retail as 
(
	SELECT [InvoiceNo]
		  ,[StockCode]
		  ,[Description]
		  ,[Quantity]
		  ,[InvoiceDate]
		  ,[UnitPrice]
		  ,[CustomerID]
		  ,[Country]
	  FROM [Cleaning UCI_ML Data].[dbo].[Online_Retail]
	  Where CustomerID <> 0
), 

quantityandprice as    -- CTE2

--- 397,882 records with quantity and unitprice
(
Select *
From online_retail
Where Quantity > 0 and  unitprice > 0
),

-- Checking for duplicates
-- 5,194 duplicates
-- 392,668 Clean Data
rownum as                 -- CTE3
(
Select *,
	ROW_NUMBER() over(PARTITION BY invoiceno, stockcode, quantity, unitprice, invoicedate ORDER by unitprice) dup_flag
	from quantityandprice
)
select *
into #online_retail_main
FROM rownum
where dup_flag = 1


-- Clean Data
Select *
from #online_retail_main

-- Unique ID (CustomerID)
-- Initial Start Date
-- Revenu Data

Select
	CustomerID,
	min(InvoiceDate) initial_startdate,
	DATEFROMPARTS(year(min(invoicedate)), month(min(invoicedate)), 1) Cohort_date
into #cohort
from #online_retail_main
group by customerID

Select *
from #cohort

-- Craete Cohort Index

Select
	mmm.*,
	cohort_index = year_diff * 12 + month_diff + 1
into #cohort_retention
From
(
	Select
		mm.*,
		year_diff  = invoice_year - cohort_year,
		month_diff = invoice_month - cohort_month

	From
	(
		Select 
			m.*, 
			c.Cohort_date, 
			year(m.invoicedate) invoice_year,
			month(m.invoicedate) invoice_month,
			year(c.Cohort_date) cohort_year,
			month(c.Cohort_date) cohort_month

		From #online_retail_main m
		left join #cohort c
			on m.CustomerID = c.CustomerID
	) mm

) mmm

Select 
*
INTO #Cohort_pivot
From
(
	Select distinct
		CustomerID,
		Cohort_date,
		cohort_index
	from #cohort_retention
) tbl
Pivot (
		Count(customerID)
		for Cohort_index in
		(
		 [1],
		 [2],
		 [3],
		 [4],
		 [5],
		 [6],
		 [7],
		 [8],
		 [9],
		 [10],
		 [11],
		 [12],
		 [13]
		)
	  ) as pivot_table
order by Cohort_date


Select 
	*,
	1.0 * [1]/[1] * 100 as [1],
	1.0 * [2]/[1] * 100 as [2],
	1.0 * [3]/[1] * 100 as [3],
	1.0 * [4]/[1] * 100 as [4],
	1.0 * [5]/[1] * 100 as [5],
	1.0 * [6]/[1] * 100 as [6],
	1.0 * [7]/[1] * 100 as [7],
	1.0 * [8]/[1] * 100 as [8],
	1.0 * [9]/[1] * 100 as [9],
	1.0 * [10]/[1] * 100 as [10],
	1.0 * [11]/[1] * 100 as [11],
	1.0 * [12]/[1] * 100 as [12],
	1.0 * [13]/[1] * 100 as [13]
FROM #Cohort_pivot
Order by Cohort_date