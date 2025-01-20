Select * From credit_card;

select 
	SUM(case when Index_no IS NULL THEN 1 ELSE 0 END) AS index_null_count
	,sum(case when City IS NULL THEN 1 ELSE 0 END) AS city_null_count
	,sum(case when Date IS NULL THEN 1 ELSE 0 END) AS date_null_count
	,sum(case when Card_Type IS NULL THEN 1 ELSE 0 END) AS card_null_count
	,sum(case when Exp_Type IS NULL THEN 1 ELSE 0 END) AS exp_null_count
	,sum(case when Gender IS NULL THEN 1 ELSE 0 END) AS gender_null_count
	,sum(case when Amount IS NULL THEN 1 ELSE 0 END) AS Amt_null_count
from credit_card;


Select count(1) from credit_card

#--1.write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends

with cte1 as
(Select top 5 City,SUM(Amount) as Citywise_Spent_Amount
From credit_card
group by City
order by Citywise_Spent_Amount desc
),

cte2 as (
Select SUM(Amount) as total_amt
from credit_card)

Select c1.City,c1.Citywise_Spent_Amount,(100.0*c1.Citywise_Spent_Amount/c2.total_amt) as Percentage_Contribution
From cte1 c1
cross join cte2 c2;

--2. write a query to print highest spend month and amount spent in that month for each card type

Select DATEPART(MONTH,Date) as trans_month,
Card_Type,SUM(Amount) as spent_amt
From credit_card
group by DATEPART(MONTH,Date),Card_Type
order by spent_amt desc


--3. write a query to print the transaction details(all columns from the table) for each card type
--   when it reaches a cumulative of 10,00,000 total spends(We should have 4 rows in the o/p one for each card type)
with cte1 as
(Select City,Date,Card_Type,Exp_Type,Gender,Amount,
SUM(Amount) over(partition by Card_Type order by Date,Amount) as cumulative_sum
From credit_card),

cte2 as (
Select *,
DENSE_RANK() over(Partition by Card_Type order by cumulative_sum) as drank
From cte1
Where cumulative_sum >= 1000000)

Select City,Date,Card_Type,Exp_Type,Gender,Amount
From cte2
where drank = 1

--4. write a query to find city which had lowest percentage spend for gold card type

with cte1 as
 (SELECT City, SUM(Amount) AS spend_amt_ingold_citywise
 FROM credit_card
 WHERE Card_Type = 'Gold'
 GROUP BY City),

cte2 as(
 SELECT City, SUM(Amount) AS spent_amt_citywise
 FROM credit_card
 GROUP BY City)

 Select c1.City,c1.spend_amt_ingold_citywise,c2.spent_amt_citywise as Citywise_Spent_money,
 (100.0*spend_amt_ingold_citywise/spent_amt_citywise) as perc_contribution
 From cte1 c1
 join cte2 c2 on c1.City=c2.City

 --5. write a query to print 3 columns: city, highest_expense_type , lowest_expense_type 

 with cte1 as
 (Select City,Exp_Type,SUM(Amount) as spent_amt
 From credit_card
 Group by City,Exp_Type),

 cte2 as(
 Select City,MIN(spent_amt) as lowest_spent_amount,MAX(spent_amt) as highest_spent_amount
 From cte1
 Group by City)

 Select c1.City,max(case when c1.spent_amt=c2.highest_spent_amount then c1.Exp_Type end) as highest_expense_type,
 max(case when c1.spent_amt=c2.lowest_spent_amount then c1.Exp_Type end) as lowest_expense_type
 from cte1 c1
 join cte2 c2 on c1.City=c2.City
 Group by c1.City

 -- 6. Write a query to find percentage contribution of spends by females for each expense type.

 with cte1 as (
 Select Exp_Type,SUM(Amount) as Exp_Type_Spent_Amount
 from credit_card
 where Gender = 'F'
 group by Exp_Type),

 cte2 as(
 SELECT SUM(Amount) AS Total_Spent
 From credit_card
 WHERE Gender = 'F')

 SELECT c1.Exp_Type,
 (100.0 * c1.Exp_Type_Spent_Amount /c2.Total_Spent) AS Perc_Contribution_Spent_Female
FROM cte1 c1
CROSS JOIN 
cte2 c2; 

--7. which card and expense type combination saw highest month over month growth in january 2014?

WITH MonthlyTotals AS (
Select Card_Type,Exp_Type,
DATEPART(YEAR, Date) as Trans_Year,
DATEPART(MONTH, Date) as Trans_Month,
SUM(Amount) as total_amount
From credit_card
group by Card_Type,Exp_Type,DATEPART(YEAR, Date), DATEPART(MONTH, Date)
),

PreviousMonthTotals AS (
 SELECT *,
 LAG(total_amount, 1) OVER (PARTITION BY Card_Type, Exp_Type ORDER BY Trans_Year, Trans_Month) AS prev_month_trans_amount
 FROM MonthlyTotals),

 GrowthAnalysis AS (
 SELECT *,
 100.0 * (total_amount - prev_month_trans_amount) / prev_month_trans_amount AS growth_per_month
 FROM PreviousMonthTotals
 WHERE Trans_Year = 2014 AND Trans_Month = 1)

SELECT TOP 1 *
FROM GrowthAnalysis
ORDER BY growth_per_month DESC;

--8. during weekends which city has highest total spend to total no of transcations ratio 

select top 1 city,sum(Amount) as total_spent,
count(1) as Count_of_transaction,
ratio = sum(Amount)/count(1) 
from credit_card
where DATEPART(weekday,Date)  in (7,1)
group by City
order by 4 desc;

--9. which city took least number of days to reach its 500th transaction after first transaction in that city

WITH CityTransactionCounts AS (
Select City,min(Date) as MIN_DATE,max(Date) as MAX_DATE
From credit_card
group by City
having count(*)>=500
),
TransactionRanked AS (
SELECT City,Date,
ROW_NUMBER() OVER (PARTITION BY City ORDER BY Date) AS ROW_NM
FROM credit_card
WHERE City IN (SELECT City FROM CityTransactionCounts)
)

SELECT CTC.City,CTC.MIN_DATE AS TRANS_START_DATE,
TR.Date AS TRANS_DATE_FOR500TH_TRANS,
DATEDIFF(DAY, CTC.MIN_DATE, TR.Date) AS DAYS_TO_REACH_500TH_TRANS
FROM CityTransactionCounts AS CTC
INNER JOIN TransactionRanked AS TR ON CTC.City = TR.City 
WHERE TR.ROW_NM = 500
ORDER BY DAYS_TO_REACH_500TH_TRANS;
