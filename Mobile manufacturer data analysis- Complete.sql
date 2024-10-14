--SQL Advance Case Study
SELECT * FROM DIM_LOCATION
SELECT * FROM DIM_CUSTOMER
SELECT * FROM DIM_DATE
SELECT * FROM DIM_MANUFACTURER
SELECT * FROM DIM_MODEL
SELECT * FROM FACT_TRANSACTIONS

--Q1--BEGIN 
select distinct(State) from FACT_TRANSACTIONS A
inner join DIM_LOCATION B on 
a.IDLocation = b.IDLocation
where Date between '01/01/2005' and GETDATE()
--Q1--END

--Q2--BEGIN
	select top 1 State from DIM_LOCATION A
	inner join FACT_TRANSACTIONS B on
	a.IDLocation=b.IDLocation
	inner join DIM_MODEL C on c.IDModel=b.IDModel
	inner join DIM_MANUFACTURER D on c.IDManufacturer=d.IDManufacturer
	where Country= 'US' and d.Manufacturer_Name= 'Samsung'
	group by State
	order by SUM(Quantity) desc
--Q2--END

--Q3--BEGIN      
	select ZipCode,State,Model_Name,COUNT(IDCustomer) as no_of_transactions from FACT_TRANSACTIONS A
	inner join DIM_LOCATION B on a.IDLocation=b.IDLocation
	inner join DIM_MODEL c on a.IDModel=c.IDModel
	group by ZipCode,State,Model_Name
--Q3--END

--Q4--BEGIN
select top 1 Model_Name, a.IDModel, a.Unit_price as price from DIM_MODEL A
order by Unit_price asc
--Q4--END

--Q5--BEGIN
SELECT MODEL_NAME, AVG(UNIT_PRICE) AS AVG_PRICE FROM DIM_MODEL
INNER JOIN DIM_MANUFACTURER ON DIM_MANUFACTURER.IDMANUFACTURER = DIM_MODEL.IDMANUFACTURER
WHERE MANUFACTURER_NAME IN 
(
SELECT TOP 5 MANUFACTURER_NAME FROM FACT_TRANSACTIONS 
INNER JOIN DIM_MODEL ON FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDMODEL
INNER JOIN DIM_MANUFACTURER ON DIM_MANUFACTURER.IDMANUFACTURER = DIM_MODEL.IDMANUFACTURER
GROUP BY MANUFACTURER_NAME
ORDER BY SUM(QUANTITY) DESC
)
GROUP BY MODEL_NAME
ORDER BY AVG(UNIT_PRICE) DESC


--Q5--END

--Q6--BEGIN
SELECT CUSTOMER_NAME, AVG(TOTALPRICE) AVG_SPENT
FROM DIM_CUSTOMER
INNER JOIN FACT_TRANSACTIONS ON DIM_CUSTOMER.IDCUSTOMER = FACT_TRANSACTIONS.IDCUSTOMER
WHERE YEAR(Date) = 2009 
GROUP BY CUSTOMER_NAME
HAVING AVG(TOTALPRICE)>500


--Q6--END
	
--Q7--BEGIN  
	WITH Top5ModelsPerYear AS (
    -- Get top 5 models for 2008
    SELECT TOP 5 b.Model_Name, YEAR(a.Date) AS Year_
    FROM FACT_TRANSACTIONS AS a
    JOIN DIM_MODEL AS b
    ON a.IDModel = b.IDModel
    WHERE YEAR(a.Date) = 2008
    GROUP BY b.Model_Name, YEAR(a.Date)
    ORDER BY SUM(a.Quantity) DESC
    
    UNION ALL
    
    -- Get top 5 models for 2009
    SELECT TOP 5 b.Model_Name, YEAR(a.Date) AS Year_
    FROM FACT_TRANSACTIONS AS a
    JOIN DIM_MODEL AS b
    ON a.IDModel = b.IDModel
    WHERE YEAR(a.Date) = 2009
    GROUP BY b.Model_Name, YEAR(a.Date)
    ORDER BY SUM(a.Quantity) DESC
    
    UNION ALL
    
    -- Get top 5 models for 2010
    SELECT TOP 5 b.Model_Name, YEAR(a.Date) AS Year_
    FROM FACT_TRANSACTIONS AS a
    JOIN DIM_MODEL AS b
    ON a.IDModel = b.IDModel
    WHERE YEAR(a.Date) = 2010
    GROUP BY b.Model_Name, YEAR(a.Date)
    ORDER BY SUM(a.Quantity) DESC
)
SELECT Model_Name
FROM Top5ModelsPerYear
GROUP BY Model_Name
HAVING COUNT(DISTINCT Year_) = 3
--Q7--END	

--Q8--BEGIN
WITH manufacturertopsales AS(SELECT MANUFACTURER_NAME, YEAR(Date) as year_
FROM DIM_MANUFACTURER T1
INNER JOIN DIM_MODEL T2 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONS T3 ON T2.IDMODEL= T3.IDMODEL
GROUP BY MANUFACTURER_NAME, YEAR(Date) 
having YEAR(Date) = 2010
ORDER BY SUM(TOTALPRICE) DESC
offset 2 row
fetch next 1 row only
union all
SELECT MANUFACTURER_NAME, YEAR(Date) as year_
FROM DIM_MANUFACTURER T1
INNER JOIN DIM_MODEL T2 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONS T3 ON T2.IDMODEL= T3.IDMODEL
GROUP BY MANUFACTURER_NAME, YEAR(Date) 
having YEAR(Date) = 2009
ORDER BY SUM(TOTALPRICE) DESC
offset 2 row
fetch next 1 row only)

select Manufacturer_Name, year_ from manufacturertopsales as A

 
--Q8--END
--Q9--BEGIN
SELECT distinct(MANUFACTURER_NAME) FROM DIM_MANUFACTURER T1
INNER JOIN DIM_MODEL T2 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONS T3 ON T2.IDMODEL= T3.IDMODEL
WHERE YEAR(Date) = 2010 
EXCEPT 
SELECT distinct(MANUFACTURER_NAME) FROM DIM_MANUFACTURER T1
INNER JOIN DIM_MODEL T2 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONS T3 ON T2.IDMODEL= T3.IDMODEL
WHERE YEAR(Date) = 2009
--Q9--END

--Q10--BEGIN
Select *, ((avg_spend-last_yr_spend)/avg_spend)*100 as perc_change from
(select *,LAG(avg_spend)over (partition by IDCustomer order by Year_) as last_yr_spend from	
	(select IDCustomer, avg(TotalPrice) as avg_spend  , avg(Quantity) as avg_quantity , year(date) as Year_
 from FACT_TRANSACTIONS
 where IDCustomer in 
 
 (select top 10 IDCustomer 
 from FACT_TRANSACTIONS
 group by IDCustomer
 order by sum(TotalPrice) desc)

group by IDCustomer, year(date))T ) T1
--Q10--END